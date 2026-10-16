import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/anillo.dart';
import '../widgets/comunes.dart';
import '../widgets/estado_error.dart';

final _miles = NumberFormat('#,##0');

/// Las sesiones pasadas agrupadas por semana (lunes a domingo), cada grupo
/// con su total, y cada sesión con sus métricas en grande. Tocar una abre
/// su detalle.
class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiones = ref.watch(historialDeSesionesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: sesiones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EstadoError(
          onReintentar: () => ref.invalidate(historialDeSesionesProvider),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const EstadoVacio(
              icono: Icons.history_rounded,
              titulo: 'Sin sesiones todavía',
              detalle: 'Cuando entrenes, cada sesión aparecerá aquí.',
            );
          }
          final semanas = _agruparPorSemana(lista);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                GeoLiftSpacing.page,
                GeoLiftSpacing.sm,
                GeoLiftSpacing.page,
                GeoLiftSpacing.bajoBarra),
            children: [
              for (final semana in semanas) ...[
                _EncabezadoSemana(semana: semana),
                for (final sesion in semana.sesiones) ...[
                  _TarjetaSesion(resumen: sesion),
                  const SizedBox(height: GeoLiftSpacing.md),
                ],
                const SizedBox(height: GeoLiftSpacing.lg),
              ],
            ],
          );
        },
      ),
    );
  }

  /// [lista] viene de la más reciente a la más antigua; se conserva ese
  /// orden dentro de cada semana y entre semanas.
  static List<_Semana> _agruparPorSemana(List<SesionResumen> lista) {
    final semanas = <DateTime, List<SesionResumen>>{};
    for (final s in lista) {
      final f = s.sesion.fecha;
      final dia = DateTime(f.year, f.month, f.day);
      final lunes = dia.subtract(Duration(days: dia.weekday - 1));
      semanas.putIfAbsent(lunes, () => []).add(s);
    }
    return [
      for (final e in semanas.entries) _Semana(lunes: e.key, sesiones: e.value),
    ];
  }
}

class _Semana {
  final DateTime lunes;
  final List<SesionResumen> sesiones;
  const _Semana({required this.lunes, required this.sesiones});

  /// Solo cuentan las sesiones con al menos una serie, igual que en Inicio.
  int get entrenadas => sesiones.where((s) => s.totalSets > 0).length;
  double get volumenKg => sesiones.fold(0.0, (t, s) => t + s.volumenTotal);
}

/// "Esta semana" / "Semana pasada" / "5 – 11 oct", con el total del grupo.
class _EncabezadoSemana extends ConsumerWidget {
  final _Semana semana;
  const _EncabezadoSemana({required this.semana});

  String _titulo() {
    final hoy = DateTime.now();
    final dia = DateTime(hoy.year, hoy.month, hoy.day);
    final esteLunes = dia.subtract(Duration(days: dia.weekday - 1));
    final semanasAtras = esteLunes.difference(semana.lunes).inDays ~/ 7;
    if (semanasAtras == 0) return 'Esta semana';
    if (semanasAtras == 1) return 'Semana pasada';
    final domingo = semana.lunes.add(const Duration(days: 6));
    final mismoMes = domingo.month == semana.lunes.month;
    final inicio = DateFormat(mismoMes ? 'd' : 'd MMM', 'es')
        .format(semana.lunes)
        .replaceAll('.', '');
    final fin = DateFormat('d MMM', 'es').format(domingo).replaceAll('.', '');
    return '$inicio – $fin';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidad = ref.watch(unidadPesoProvider);
    final n = semana.entrenadas;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.xs, GeoLiftSpacing.sm,
          GeoLiftSpacing.xs, GeoLiftSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child:
                Text(_titulo(), style: Theme.of(context).textTheme.titleLarge),
          ),
          Text(
            '$n ${n == 1 ? 'sesión' : 'sesiones'} · '
            '${_miles.format(unidad.desdeKg(semana.volumenKg).round())} '
            '${unidad.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Una sesión: el día entrenado, cuándo, sus métricas en grande y la nota.
class _TarjetaSesion extends ConsumerWidget {
  final SesionResumen resumen;
  const _TarjetaSesion({required this.resumen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sesion = resumen.sesion;
    final cuando = DateFormat("EEE d 'de' MMM · HH:mm", 'es')
        .format(sesion.fecha)
        .replaceAll('.', '');
    final minutos = (sesion.duracionSeg ?? 0) ~/ 60;

    return Card(
      child: InkWell(
        onTap: () => context.push('/historial/${sesion.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.xl,
              GeoLiftSpacing.lg, GeoLiftSpacing.md, GeoLiftSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resumen.nombreDia,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(cuando[0].toUpperCase() + cuando.substring(1),
                            style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: GeoLiftSpacing.md),
              if (resumen.totalSets == 0)
                Text('Sin series registradas', style: textTheme.bodyMedium)
              else
                _Metricas(resumen: resumen, minutos: minutos, unidad: unidad),
              if (sesion.notas != null) ...[
                const SizedBox(height: GeoLiftSpacing.md),
                Text(
                  '"${sesion.notas}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Duración, series y volumen como números grandes con su unidad.
class _Metricas extends StatelessWidget {
  final SesionResumen resumen;
  final int minutos;
  final UnidadPeso unidad;

  const _Metricas({
    required this.resumen,
    required this.minutos,
    required this.unidad,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: GeoLiftSpacing.xl,
      runSpacing: GeoLiftSpacing.sm,
      children: [
        if (minutos > 0)
          NumeroConUnidad('$minutos',
              unidad: 'MIN', tamano: 26, color: colorScheme.primary),
        NumeroConUnidad('${resumen.totalSets}', unidad: 'SETS', tamano: 26),
        NumeroConUnidad(
          _miles.format(unidad.desdeKg(resumen.volumenTotal).round()),
          unidad: unidad.etiqueta,
          tamano: 26,
          color: colorScheme.secondary,
        ),
      ],
    );
  }
}
