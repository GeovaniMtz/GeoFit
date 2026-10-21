import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/database.dart';
import '../../controllers/ejercicio_controller.dart';
import '../../providers/providers.dart';
import 'caja_referencia.dart';
import 'consola_peso_reps.dart';
import 'encabezado_ejercicio.dart';
import 'lista_series.dart';
import 'overlay_celebracion.dart';
import 'tarjeta_descanso.dart';
import 'tarjeta_sugerencia.dart';

/// Panel de UN ejercicio dentro de la sesión activa.
///
/// Toda la lógica (series, descanso, PRs, sugerencia, notificación) vive en
/// [EjercicioController]; este widget solo compone las piezas visuales y se
/// encarga de lo que es puramente de interfaz: vibrar, la animación de
/// celebración y avisarle a la pantalla cuándo avanzar o aplazar.
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
  late final ArgsEjercicio _args = (
    objetivo: widget.objetivo,
    sesionId: widget.sesionId,
    numeroEjercicio: widget.numeroEjercicio,
    totalEjercicios: widget.totalEjercicios,
    esUltimoEjercicio: widget.esUltimoEjercicio,
    proximoEjercicioId: widget.proximoObjetivo?.ejercicioId,
  );

  // Pausa de la celebración antes de avanzar solo. Es un
  // AnimationController (y no un Timer) para que su ticker mantenga "viva"
  // la espera: así pumpAndSettle() en los tests no la da por terminada a
  // medio camino.
  AnimationController? _controladorCelebracion;
  bool _avanzado = false;

  EjercicioController get _controller =>
      ref.read(ejercicioControllerProvider(_args).notifier);

  // El controlador vigente, guardado en cada build (ya suscrito con
  // watch): Riverpod no permite usar `ref` dentro de dispose().
  EjercicioController? _controllerAlDesmontar;

  @override
  void dispose() {
    _controllerAlDesmontar?.detenerDescanso();
    // stop() antes de dispose(): un AnimationController no puede
    // destruirse mientras sigue animando (lanza un assert en debug/test).
    _controladorCelebracion?.stop();
    _controladorCelebracion?.dispose();
    super.dispose();
  }

  void _iniciarCelebracion() {
    if (_controladorCelebracion != null || _avanzado) return;
    HapticFeedback.mediumImpact();
    final controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _controladorCelebracion = controlador;
    controlador.forward().whenComplete(_avanzar);
  }

  /// Pasa al siguiente ejercicio (o cierra la rutina). Lo dispara el fin de
  /// la celebración, un toque sobre ella o el botón principal de respaldo.
  void _avanzar() {
    if (_avanzado) return;
    _avanzado = true;
    _controladorCelebracion?.stop();
    if (widget.esUltimoEjercicio) {
      widget.onRutinaCompletada();
    } else {
      widget.onSiguienteEjercicio?.call();
    }
  }

  void _aplazar() {
    final onAplazar = widget.onAplazarEjercicio;
    if (onAplazar == null) return;
    HapticFeedback.selectionClick();
    onAplazar();
  }

  Future<void> _registrar() async {
    final esPr = await _controller.registrarSerie();
    if (esPr == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏆 ¡Nuevo PR en este ejercicio!')),
      );
    }
  }

  void _saltarDescanso() {
    if (!ref.read(ejercicioControllerProvider(_args)).descansando) return;
    HapticFeedback.mediumImpact();
    _controller.saltarDescanso();
  }

  @override
  Widget build(BuildContext context) {
    // Efectos de interfaz ante cambios del estado.
    ref.listen(ejercicioControllerProvider(_args), (antes, ahora) {
      if (ahora.celebrando && !(antes?.celebrando ?? false)) {
        _iniciarCelebracion();
      }
      // El descanso termina en silencio si no se avisa de alguna forma: con
      // el teléfono bocabajo o guardado nadie ve la cuenta llegar a cero, y
      // la vibración no depende de la pantalla.
      if (ahora.descansosTerminados > (antes?.descansosTerminados ?? 0)) {
        HapticFeedback.heavyImpact();
      }
    });

    final estado = ref.watch(ejercicioControllerProvider(_args));
    _controllerAlDesmontar = _controller;
    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final referencia = estado.referencia;
    final sugerencia = estado.sugerencia;

    final VoidCallback? accionBoton;
    final String textoBoton;
    if (estado.seriesCompletas) {
      // Respaldo tocable por si el avance automático no llegó a dispararse
      // (o el usuario no quiere esperar la celebración).
      accionBoton = _avanzar;
      textoBoton =
          widget.esUltimoEjercicio ? 'FINALIZAR RUTINA' : 'SIGUIENTE EJERCICIO';
    } else if (estado.descansando) {
      accionBoton = null;
      textoBoton = 'DESCANSANDO…';
    } else {
      accionBoton = estado.puedeRegistrar ? _registrar : null;
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
              EncabezadoEjercicio(
                nombre: estado.cargando ? 'Cargando…' : estado.nombreEjercicio,
                objetivo: widget.objetivo,
                nombreProximo: estado.nombreProximo,
              ),
              if (referencia != null) ...[
                const SizedBox(height: GeoLiftSpacing.lg),
                CajaReferencia(
                  peso: unidad.formatear(referencia.registro.peso),
                  unidad: unidad.name,
                  reps: referencia.registro.reps,
                ),
              ],
              if (sugerencia != null) ...[
                const SizedBox(height: GeoLiftSpacing.md),
                TarjetaSugerencia(
                  sugerencia: sugerencia,
                  pesoTexto: unidad.formatearConUnidad(
                      unidad.redondearAPasoKg(sugerencia.pesoSugeridoKg!)),
                ),
              ],
              const SizedBox(height: GeoLiftSpacing.xl),
              ConsolaPesoReps(
                numeroSet: estado.numeroSet,
                totalSeries: estado.totalSeries,
                pesoTexto: unidad.formatear(estado.pesoKg),
                unidadEtiqueta: unidad.etiqueta,
                reps: estado.reps,
                rpe: estado.rpe,
                habilitada: !estado.seriesCompletas,
                onSubirPeso: _controller.subirPeso,
                onBajarPeso: _controller.bajarPeso,
                onSubirReps: _controller.subirReps,
                onBajarReps: _controller.bajarReps,
                onElegirRpe: _controller.elegirRpe,
              ),
              if (estado.descansando) ...[
                const SizedBox(height: GeoLiftSpacing.lg),
                TarjetaDescanso(
                  restantes: estado.segundosDescanso,
                  total: widget.objetivo.descansoSeg,
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
                  if (!estado.seriesCompletas &&
                      widget.onAplazarEjercicio != null) ...[
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
              if (estado.registradas.isNotEmpty) ...[
                const SizedBox(height: GeoLiftSpacing.xxl),
                ListaSeries(series: estado.registradas, unidad: unidad),
              ],
            ],
          ),
        ),
        if (estado.celebrando)
          Positioned.fill(
            child: OverlayCelebracion(
              esUltimoEjercicio: widget.esUltimoEjercicio,
              nombreProximo: estado.nombreProximo,
              onSaltar: _avanzar,
            ),
          ),
      ],
    );
  }
}
