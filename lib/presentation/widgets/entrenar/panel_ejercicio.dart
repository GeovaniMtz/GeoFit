import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/database.dart';
import '../../providers/providers.dart';
import '../comunes.dart';
import 'boton_stepper.dart';
import 'caja_referencia.dart';
import 'punto_serie.dart';

/// Panel de UN ejercicio dentro de la sesión activa: registra series (peso y
/// reps), corre el timer de descanso entre series, y avisa cuando el
/// ejercicio queda completo.
class PanelEjercicio extends ConsumerStatefulWidget {
  final RutinaEjercicio objetivo;
  final RutinaEjercicio? proximoObjetivo;
  final int sesionId;
  final int numeroEjercicio;
  final int totalEjercicios;
  final bool esUltimoEjercicio;
  final VoidCallback? onSiguienteEjercicio;
  final VoidCallback? onAplazarEjercicio;
  final VoidCallback onRutinaCompletada;

  const PanelEjercicio({
    super.key,
    required this.objetivo,
    this.proximoObjetivo,
    required this.sesionId,
    required this.numeroEjercicio,
    required this.totalEjercicios,
    required this.esUltimoEjercicio,
    required this.onSiguienteEjercicio,
    this.onAplazarEjercicio,
    required this.onRutinaCompletada,
  });

  @override
  ConsumerState<PanelEjercicio> createState() => _PanelEjercicioState();
}

class _PanelEjercicioState extends ConsumerState<PanelEjercicio>
    with TickerProviderStateMixin {
  int _numeroSet = 1;
  // Siempre en kg (como se guarda); la unidad elegida solo cambia cómo se
  // muestra y de cuánto en cuánto suben los botones −/+.
  double _peso = 20;
  int _reps = 8;

  // Esfuerzo percibido (RPE 6–10) de la serie que se va a registrar.
  // Opcional: null si el usuario no lo marca. Se limpia tras cada serie.
  double? _rpe;
  bool _guardando = false;
  Timer? _timerDescanso;
  int _segundosRestantes = 0;

  // Al registrar la última serie del ejercicio, se avanza solo tras una
  // breve celebración en vez de esperar a que el usuario toque el botón.
  // Se usa un AnimationController (en vez de un Timer suelto) para que su
  // ticker mantenga "viva" la animación durante toda la espera: así
  // pumpAndSettle() en los tests no la da por terminada a medio camino,
  // como pasaría con un Timer que no programa frames por sí solo.
  AnimationController? _controladorCelebracion;
  bool _celebrando = false;
  bool _avanzado = false;

  bool _historialCapturado = false;
  List<RegistroConFecha> _historialPrevio = const [];

  final List<({int numeroSet, double peso, int reps, double? rpe})>
      _registrados = [];

  @override
  void initState() {
    super.initState();
    _reps = widget.objetivo.repsMin;
    final unidad = ref.read(unidadPesoProvider);
    _peso = unidad.aKg(unidad.pesoInicial);
    _cargarSetsPrevios();
  }

  /// Si esta sesión ya tenía sets registrados para este ejercicio (se salió
  /// de "Entrenar" a mitad del ejercicio y se volvió a entrar), retoma el
  /// conteo de series y la lista de "sets registrados" en vez de reiniciar
  /// desde la serie 1.
  Future<void> _cargarSetsPrevios() async {
    final db = ref.read(databaseProvider);
    final previos =
        await db.setsDeEjercicioEnSesion(widget.sesionId, widget.objetivo.id);
    if (!mounted) return;
    if (previos.isNotEmpty) {
      setState(() {
        _numeroSet = previos.last.numeroSet + 1;
        _registrados.addAll(previos.reversed.map((s) => (
              numeroSet: s.numeroSet,
              peso: s.peso,
              reps: s.reps,
              rpe: s.rpe,
            )));
      });
      // Se salió de "Entrenar" justo después de la última serie, antes de
      // que el avance automático llegara a dispararse: lo retoma ahora.
      if (_numeroSet > widget.objetivo.seriesObjetivo) {
        _iniciarCelebracion();
      }
    }
    unawaited(_actualizarNotificacion());
  }

  /// Muestra u oculta la notificación de progreso según el estado actual de
  /// este ejercicio: la actualiza mientras queden series por registrar, o la
  /// retira si esta era la última serie del último ejercicio (sesión
  /// completa). Resuelve el nombre con una lectura puntual del catálogo —no
  /// con el provider reactivo— porque esto es un efecto secundario que solo
  /// debe dispararse desde puntos concretos (carga inicial y tras registrar
  /// una serie), no en cada rebuild del widget.
  Future<void> _actualizarNotificacion() async {
    final servicio = ref.read(notificationServiceProvider);
    final totalSeries = widget.objetivo.seriesObjetivo;

    if (widget.esUltimoEjercicio && _numeroSet > totalSeries) {
      await servicio.cancelar();
      return;
    }

    final catalogo = await ref.read(databaseProvider).catalogoDeEjercicios();
    if (!mounted) return;
    final coincidencias =
        catalogo.where((e) => e.id == widget.objetivo.ejercicioId);
    final nombre =
        coincidencias.isEmpty ? 'Ejercicio' : coincidencias.first.nombre;

    await servicio.mostrarProgreso(
      rutinaDiaId: widget.objetivo.rutinaDiaId,
      nombreEjercicio: nombre,
      numeroEjercicio: widget.numeroEjercicio,
      totalEjercicios: widget.totalEjercicios,
      numeroSet: _numeroSet > totalSeries ? totalSeries : _numeroSet,
      totalSets: totalSeries,
    );
  }

  @override
  void dispose() {
    _timerDescanso?.cancel();
    // stop() antes de dispose(): un AnimationController no puede
    // destruirse mientras sigue animando (lanza un assert en debug/test).
    _controladorCelebracion?.stop();
    _controladorCelebracion?.dispose();
    super.dispose();
  }

  /// La primera vez que llega el historial se usa para sugerir el peso y las
  /// reps de partida, y se congela como referencia de "sesión anterior" —
  /// así no se confunde con los sets que se van registrando hoy mismo.
  void _capturarHistorial(List<RegistroConFecha> historial) {
    if (_historialCapturado) return;
    _historialCapturado = true;
    _historialPrevio = historial;
    if (historial.isNotEmpty) {
      // Se redondea al medio más cercano en la unidad actual, por si el
      // registro se hizo en la otra (60 kg → 132.5 lb, no 132.28).
      final unidad = ref.read(unidadPesoProvider);
      _peso =
          unidad.aKg(unidad.desdeKgRedondeado(historial.first.registro.peso));
      _reps = historial.first.registro.reps;
    }
  }

  double get _pasoKg {
    final unidad = ref.read(unidadPesoProvider);
    return unidad.aKg(unidad.paso);
  }

  void _incPeso() => setState(() => _peso += _pasoKg);
  void _decPeso() => setState(() => _peso = math.max(0, _peso - _pasoKg));
  void _incReps() => setState(() => _reps = math.min(50, _reps + 1));
  void _decReps() => setState(() => _reps = math.max(1, _reps - 1));

  void _iniciarDescanso() {
    _timerDescanso?.cancel();
    setState(() => _segundosRestantes = widget.objetivo.descansoSeg);
    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundosRestantes <= 1) {
        t.cancel();
        setState(() => _segundosRestantes = 0);
        // El descanso termina en silencio si no avisamos de alguna forma:
        // con el teléfono bocabajo o guardado, nadie ve la cuenta llegar a
        // cero. La vibración no depende de que la pantalla esté visible.
        HapticFeedback.heavyImpact();
      } else {
        setState(() => _segundosRestantes -= 1);
      }
    });
  }

  /// Permite terminar el descanso antes de tiempo cuando el usuario toca la
  /// card: cancela el timer y libera el botón de la siguiente serie.
  void _saltarDescanso() {
    if (_segundosRestantes <= 0) return;
    _timerDescanso?.cancel();
    HapticFeedback.mediumImpact();
    setState(() => _segundosRestantes = 0);
  }

  /// Muestra la celebración de "ejercicio completado" y, tras una pausa
  /// breve, avanza solo — sin esperar un toque del usuario. El toque sobre
  /// el overlay (o sobre el botón principal, que queda con la misma acción
  /// como respaldo) puede adelantar el avance llamando a [_avanzar] antes.
  void _iniciarCelebracion() {
    if (_celebrando || _avanzado) return;
    setState(() => _celebrando = true);
    HapticFeedback.mediumImpact();
    final controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _controladorCelebracion = controlador;
    controlador.forward().whenComplete(_avanzar);
  }

  /// El ejercicio actual no se puede hacer justo ahora (p. ej. la máquina
  /// está ocupada): lo manda al final de la cola de esta sesión y pasa al
  /// siguiente. Los sets que ya llevaba registrados no se pierden — se
  /// retoman cuando le vuelva a tocar.
  void _aplazar() {
    final onAplazar = widget.onAplazarEjercicio;
    if (onAplazar == null) return;
    HapticFeedback.selectionClick();
    onAplazar();
  }

  void _avanzar() {
    if (_avanzado) return;
    _avanzado = true;
    // stop() antes de dispose(): si se adelanta el avance con un toque, el
    // controlador todavía puede seguir animando en ese momento.
    _controladorCelebracion?.stop();
    _controladorCelebracion?.dispose();
    _controladorCelebracion = null;
    if (widget.esUltimoEjercicio) {
      widget.onRutinaCompletada();
    } else {
      widget.onSiguienteEjercicio?.call();
    }
  }

  Future<void> _registrarSet() async {
    if (_guardando) return;
    setState(() => _guardando = true);

    final db = ref.read(databaseProvider);
    final servicio = ref.read(progresionServiceProvider);

    final historial =
        await db.historialPorEjercicio(widget.objetivo.ejercicioId);
    final e1rmPrevio = historial.isEmpty
        ? null
        : historial
            .map((h) => servicio.e1rm(h.registro.peso, h.registro.reps))
            .reduce((a, b) => a > b ? a : b);
    final e1rmNuevo = servicio.e1rm(_peso, _reps);
    final esPr =
        servicio.esNuevoPr(e1rmNuevo: e1rmNuevo, e1rmMaximoPrevio: e1rmPrevio);

    await db.registrarSet(RegistrosSetCompanion.insert(
      sesionId: widget.sesionId,
      rutinaEjercicioId: widget.objetivo.id,
      numeroSet: _numeroSet,
      peso: _peso,
      reps: _reps,
      esPr: Value(esPr),
      rpe: Value(_rpe),
    ));
    await db.actualizarDuracionSesion(widget.sesionId);

    // MainShell mantiene Historial y Rutinas vivos todo el tiempo (usa
    // IndexedStack), así que sin esto sus datos se quedan tal cual estaban
    // la primera vez que se leyeron, aunque acabes de registrar esta serie.
    ref.invalidate(historialPorEjercicioProvider(widget.objetivo.ejercicioId));
    ref.invalidate(historialDeSesionesProvider);
    final dia = await db.obtenerDia(widget.objetivo.rutinaDiaId);
    ref.invalidate(ultimoDiaEntrenadoProvider(dia.rutinaId));

    if (!mounted) return;

    final esUltimaSerie = _numeroSet >= widget.objetivo.seriesObjetivo;
    setState(() {
      _registrados.insert(
          0, (numeroSet: _numeroSet, peso: _peso, reps: _reps, rpe: _rpe));
      _rpe = null;
      _numeroSet += 1;
      _guardando = false;
    });
    unawaited(_actualizarNotificacion());

    if (!esUltimaSerie) {
      _iniciarDescanso();
    } else {
      _iniciarCelebracion();
    }

    if (esPr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏆 ¡Nuevo PR en este ejercicio!')),
      );
    }
  }

  /// Kilos guardados → texto en la unidad elegida por el usuario.
  String _formatearPeso(double pesoKg) =>
      ref.read(unidadPesoProvider).formatear(pesoKg);

  String _formatearTiempo(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final catalogoAsync = ref.watch(catalogoDeEjerciciosProvider);
    final ejercicioAsync = catalogoAsync.whenData((lista) =>
        lista.where((e) => e.id == widget.objetivo.ejercicioId).toList());
    final proximoObjetivo = widget.proximoObjetivo;
    final nombreProximo = proximoObjetivo == null
        ? null
        : catalogoAsync.whenOrNull(
            data: (lista) {
              for (final e in lista) {
                if (e.id == proximoObjetivo.ejercicioId) return e.nombre;
              }
              return null;
            },
          );
    ref
        .watch(historialPorEjercicioProvider(widget.objetivo.ejercicioId))
        .whenData(_capturarHistorial);

    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final totalSeries = widget.objetivo.seriesObjetivo;
    final sesionCompleta = _numeroSet > totalSeries;
    final descansando = _segundosRestantes > 0;

    VoidCallback? accionBoton;
    if (_guardando || descansando) {
      accionBoton = null;
    } else if (sesionCompleta) {
      // Sirve de respaldo tocable por si el avance automático no llegó a
      // dispararse (o el usuario no quiere esperar la celebración).
      accionBoton = _avanzar;
    } else {
      accionBoton = _registrarSet;
    }

    String textoBoton;
    if (sesionCompleta) {
      textoBoton =
          widget.esUltimoEjercicio ? 'FINALIZAR RUTINA' : 'SIGUIENTE EJERCICIO';
    } else if (descansando) {
      textoBoton = 'DESCANSANDO…';
    } else {
      textoBoton = 'REGISTRAR SERIE';
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
              GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ejercicioAsync.when(
                loading: () => const Text('Cargando…'),
                error: (e, _) => const Text('No se pudo cargar.'),
                data: (lista) => Text(
                  lista.isEmpty ? 'Ejercicio' : lista.first.nombre,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: GeoLiftSpacing.md),
              Wrap(
                spacing: GeoLiftSpacing.sm,
                runSpacing: GeoLiftSpacing.sm,
                children: [
                  _ChipObjetivo(
                    icono: Icons.layers_outlined,
                    texto: '$totalSeries series',
                  ),
                  _ChipObjetivo(
                    icono: Icons.repeat_rounded,
                    texto: '${widget.objetivo.repsMin}-'
                        '${widget.objetivo.repsMax} reps',
                  ),
                  _ChipObjetivo(
                    icono: Icons.timer_outlined,
                    texto: '${widget.objetivo.descansoSeg}s',
                  ),
                ],
              ),
              if (nombreProximo != null) ...[
                const SizedBox(height: GeoLiftSpacing.md),
                Row(
                  children: [
                    Icon(Icons.arrow_forward_rounded,
                        size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: GeoLiftSpacing.xs),
                    Expanded(
                      child: Text(
                        'Próximo ejercicio: $nombreProximo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              if (_historialPrevio.isNotEmpty) ...[
                const SizedBox(height: GeoLiftSpacing.lg),
                CajaReferencia(
                  peso: _formatearPeso(_historialPrevio.first.registro.peso),
                  unidad: unidad.name,
                  reps: _historialPrevio.first.registro.reps,
                ),
              ],
              const SizedBox(height: GeoLiftSpacing.xl),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 1; i <= totalSeries; i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.5),
                            child: PuntoSerie(
                              estado: i < _numeroSet
                                  ? EstadoPunto.hecho
                                  : (i == _numeroSet
                                      ? EstadoPunto.actual
                                      : EstadoPunto.pendiente),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SERIE ${sesionCompleta ? totalSeries : _numeroSet}/'
                      '$totalSeries',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GeoLiftSpacing.lg),
              // Peso y reps comparten la misma "consola": una tarjeta con el
              // peso al centro en grande y las reps abajo, ambos con sus
              // steppers −/+ a los lados.
              Container(
                padding: const EdgeInsets.all(GeoLiftSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        BotonStepper(
                          icono: Icons.remove_rounded,
                          tooltip: 'Restar peso',
                          onPressed: sesionCompleta ? null : _decPeso,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(_formatearPeso(_peso),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(height: 1.05)),
                              Text(unidad.etiqueta,
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        BotonStepper(
                          icono: Icons.add_rounded,
                          tooltip: 'Sumar peso',
                          onPressed: sesionCompleta ? null : _incPeso,
                        ),
                      ],
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: GeoLiftSpacing.lg),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        BotonStepper(
                          icono: Icons.remove_rounded,
                          tamano: 48,
                          tooltip: 'Restar repeticiones',
                          onPressed: sesionCompleta ? null : _decReps,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$_reps',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(width: GeoLiftSpacing.sm),
                              Text('REPS',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        BotonStepper(
                          icono: Icons.add_rounded,
                          tamano: 48,
                          tooltip: 'Sumar repeticiones',
                          onPressed: sesionCompleta ? null : _incReps,
                        ),
                      ],
                    ),
                    const SizedBox(height: GeoLiftSpacing.lg),
                    _SelectorRpe(
                      valor: _rpe,
                      onCambio: sesionCompleta
                          ? null
                          : (valor) => setState(() => _rpe = valor),
                    ),
                  ],
                ),
              ),
              if (descansando) ...[
                const SizedBox(height: GeoLiftSpacing.lg),
                _TarjetaDescanso(
                  restantes: _segundosRestantes,
                  total: widget.objetivo.descansoSeg,
                  texto: _formatearTiempo(_segundosRestantes),
                  onSaltar: _saltarDescanso,
                ),
              ],
              const SizedBox(height: GeoLiftSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: accionBoton,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                      ),
                      child: Text(textoBoton),
                    ),
                  ),
                  // Aplazar no necesita palabras al lado del botón grande:
                  // ⏭ + tooltip. Se oculta cuando ya no hay a quién saltarle.
                  if (!sesionCompleta && widget.onAplazarEjercicio != null) ...[
                    const SizedBox(width: GeoLiftSpacing.md),
                    IconButton(
                      onPressed: _aplazar,
                      tooltip: 'No puedo ahora, saltar',
                      style: IconButton.styleFrom(
                        minimumSize: const Size(60, 60),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ],
              ),
              if (_registrados.isNotEmpty) ...[
                const SizedBox(height: GeoLiftSpacing.xxl),
                const EncabezadoSeccion('Sets registrados'),
                for (final r in _registrados)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GeoLiftSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GeoLiftSpacing.lg,
                          vertical: GeoLiftSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 18, color: colorScheme.secondary),
                          const SizedBox(width: GeoLiftSpacing.md),
                          Expanded(
                            child: Text('Serie ${r.numeroSet}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          Text(
                            '${_formatearPeso(r.peso)} ${unidad.name} × ${r.reps}'
                            '${r.rpe == null ? '' : '  @${r.rpe!.toStringAsFixed(0)}'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (_celebrando)
          Positioned.fill(
            child: _OverlayCelebracion(
              esUltimoEjercicio: widget.esUltimoEjercicio,
              nombreProximo: nombreProximo,
              onSaltar: _avanzar,
            ),
          ),
      ],
    );
  }
}

/// Overlay que se muestra tras registrar la última serie de un ejercicio:
/// celebra brevemente y deja que se toque para adelantar el avance
/// automático (igual patrón que "toca para saltar" del descanso).
class _OverlayCelebracion extends StatelessWidget {
  final bool esUltimoEjercicio;
  final String? nombreProximo;
  final VoidCallback onSaltar;

  const _OverlayCelebracion({
    required this.esUltimoEjercicio,
    required this.nombreProximo,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onSaltar,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        builder: (context, opacidad, child) =>
            Opacity(opacity: opacidad, child: child),
        child: Container(
          color: colorScheme.surface.withValues(alpha: 0.97),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, valor, child) =>
                    Transform.scale(scale: valor, child: child),
                child: Icon(Icons.check_circle,
                    size: 72, color: colorScheme.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                esUltimoEjercicio
                    ? '¡Última serie hecha!'
                    : '¡Ejercicio completado!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (nombreProximo != null) ...[
                const SizedBox(height: 8),
                Text('Siguiente: $nombreProximo',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 20),
              Text('Toca para continuar',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un dato del objetivo del ejercicio (series, rango de reps, descanso)
/// como chip con ícono, en vez de una sola línea larga de texto.
class _ChipObjetivo extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipObjetivo({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GeoLiftSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Cuenta regresiva del descanso entre series, con una barra que se va
/// vaciando. Tocarla termina el descanso antes de tiempo.
class _TarjetaDescanso extends StatelessWidget {
  final int restantes;
  final int total;
  final String texto;
  final VoidCallback onSaltar;

  const _TarjetaDescanso({
    required this.restantes,
    required this.total,
    required this.texto,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraccion = total <= 0 ? 0.0 : (restantes / total).clamp(0.0, 1.0);
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
        onTap: onSaltar,
        child: Padding(
          padding: const EdgeInsets.all(GeoLiftSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: colorScheme.primary),
                  const SizedBox(width: GeoLiftSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DESCANSO',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: colorScheme.primary)),
                        Text('Toca para saltar',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    texto,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: GeoLiftSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                child: LinearProgressIndicator(
                  value: fraccion,
                  minHeight: 6,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Esfuerzo percibido (RPE) de la serie: 6 = muy fácil … 10 = al fallo.
/// Es opcional — tocar el valor ya marcado lo desmarca.
class _SelectorRpe extends StatelessWidget {
  final double? valor;
  final ValueChanged<double?>? onCambio;
  const _SelectorRpe({required this.valor, required this.onCambio});

  static const _valores = [6.0, 7.0, 8.0, 9.0, 10.0];

  // Misma posición que en [_valores].
  static const _descripciones = [
    'RPE 6: podías hacer 4 o más reps extra',
    'RPE 7: te quedaban unas 3 reps',
    'RPE 8: te quedaban unas 2 reps',
    'RPE 9: te quedaba 1 rep',
    'RPE 10: al fallo, no salía otra',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Tooltip(
          message: 'Esfuerzo percibido (opcional)',
          child: Text('RPE', style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: GeoLiftSpacing.md),
        for (var i = 0; i < _valores.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Tooltip(
                message: _descripciones[i],
                child: Material(
                  color: valor == _valores[i]
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                    onTap: onCambio == null
                        ? null
                        : () => onCambio!(
                            valor == _valores[i] ? null : _valores[i]),
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Text(
                          _valores[i].toStringAsFixed(0),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            color: valor == _valores[i]
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
