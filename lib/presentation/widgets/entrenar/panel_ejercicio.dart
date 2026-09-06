import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../providers/providers.dart';
import 'boton_stepper.dart';
import 'caja_referencia.dart';
import 'punto_serie.dart';

/// Panel de UN ejercicio dentro de la sesión activa: registra series (peso y
/// reps), corre el timer de descanso entre series, y avisa cuando el
/// ejercicio queda completo.
class PanelEjercicio extends ConsumerStatefulWidget {
  final RutinaEjercicio objetivo;
  final int sesionId;
  final bool esUltimoEjercicio;
  final VoidCallback? onSiguienteEjercicio;

  const PanelEjercicio({
    super.key,
    required this.objetivo,
    required this.sesionId,
    required this.esUltimoEjercicio,
    required this.onSiguienteEjercicio,
  });

  @override
  ConsumerState<PanelEjercicio> createState() => _PanelEjercicioState();
}

class _PanelEjercicioState extends ConsumerState<PanelEjercicio> {
  int _numeroSet = 1;
  double _peso = 20;
  int _reps = 8;
  bool _guardando = false;
  Timer? _timerDescanso;
  int _segundosRestantes = 0;

  bool _historialCapturado = false;
  List<RegistroConFecha> _historialPrevio = const [];

  final List<({int numeroSet, double peso, int reps})> _registrados = [];

  @override
  void initState() {
    super.initState();
    _reps = widget.objetivo.repsMin;
  }

  @override
  void dispose() {
    _timerDescanso?.cancel();
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
      _peso = historial.first.registro.peso;
      _reps = historial.first.registro.reps;
    }
  }

  void _incPeso() => setState(() => _peso += 2.5);
  void _decPeso() => setState(() => _peso = math.max(0, _peso - 2.5));
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
    ));

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
      _registrados.insert(0, (numeroSet: _numeroSet, peso: _peso, reps: _reps));
      _numeroSet += 1;
      _guardando = false;
    });

    if (!esUltimaSerie) {
      _iniciarDescanso();
    }

    if (esPr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏆 ¡Nuevo PR en este ejercicio!')),
      );
    }
  }

  String _formatearPeso(double peso) {
    return peso == peso.roundToDouble()
        ? peso.toStringAsFixed(0)
        : peso.toStringAsFixed(1);
  }

  String _formatearTiempo(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ejercicioAsync = ref.watch(catalogoDeEjerciciosProvider).whenData(
        (lista) =>
            lista.where((e) => e.id == widget.objetivo.ejercicioId).toList());
    ref
        .watch(historialPorEjercicioProvider(widget.objetivo.ejercicioId))
        .whenData(_capturarHistorial);

    final colorScheme = Theme.of(context).colorScheme;
    final totalSeries = widget.objetivo.seriesObjetivo;
    final sesionCompleta = _numeroSet > totalSeries;
    final descansando = _segundosRestantes > 0;

    VoidCallback? accionBoton;
    if (_guardando || descansando) {
      accionBoton = null;
    } else if (sesionCompleta) {
      accionBoton = widget.onSiguienteEjercicio;
    } else {
      accionBoton = _registrarSet;
    }

    String textoBoton;
    if (sesionCompleta) {
      textoBoton = widget.esUltimoEjercicio
          ? 'SESIÓN COMPLETADA'
          : 'SIGUIENTE EJERCICIO';
    } else if (descansando) {
      textoBoton = 'DESCANSANDO…';
    } else {
      textoBoton = 'REGISTRAR SERIE';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ejercicioAsync.when(
            loading: () => const Text('Cargando…'),
            error: (e, _) => const Text('No se pudo cargar.'),
            data: (lista) => Text(
              lista.isEmpty ? 'Ejercicio' : lista.first.nombre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Objetivo: $totalSeries series · '
            '${widget.objetivo.repsMin}-${widget.objetivo.repsMax} reps · '
            '${widget.objetivo.descansoSeg}s descanso',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_historialPrevio.isNotEmpty) ...[
            const SizedBox(height: 16),
            CajaReferencia(
              peso: _formatearPeso(_historialPrevio.first.registro.peso),
              reps: _historialPrevio.first.registro.reps,
            ),
          ],
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 1; i <= totalSeries; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BotonStepper(
                icono: Icons.remove,
                tooltip: 'Restar peso',
                onPressed: sesionCompleta ? null : _decPeso,
              ),
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    Text(_formatearPeso(_peso),
                        style: Theme.of(context).textTheme.displaySmall),
                    Text('KG', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              BotonStepper(
                icono: Icons.add,
                tooltip: 'Sumar peso',
                onPressed: sesionCompleta ? null : _incPeso,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reps',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant)),
                Row(
                  children: [
                    BotonStepper(
                      icono: Icons.remove,
                      tamano: 44,
                      tooltip: 'Restar repeticiones',
                      onPressed: sesionCompleta ? null : _decReps,
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$_reps',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    BotonStepper(
                      icono: Icons.add,
                      tamano: 44,
                      tooltip: 'Sumar repeticiones',
                      onPressed: sesionCompleta ? null : _incReps,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (descansando) ...[
            const SizedBox(height: 16),
            Material(
              color: colorScheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _saltarDescanso,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DESCANSO',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colorScheme.primary)),
                          Text('Toca para saltar',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.7))),
                        ],
                      ),
                      Text(
                        _formatearTiempo(_segundosRestantes),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: accionBoton,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: Text(textoBoton),
            ),
          ),
          if (_registrados.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('SETS REGISTRADOS',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            for (final r in _registrados)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 15, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Serie ${r.numeroSet}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    Text(
                      '${_formatearPeso(r.peso)} kg × ${r.reps}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
