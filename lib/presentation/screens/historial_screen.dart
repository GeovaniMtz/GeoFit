import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';
import '../widgets/estado_error.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiones = ref.watch(historialDeSesionesProvider);
    final formatoDiaSemana = DateFormat('EEEE', 'es');
    final formatoHora = DateFormat('HH:mm', 'es');

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
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
                GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xl),
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: GeoLiftSpacing.md),
            itemBuilder: (context, i) {
              final resumen = lista[i];
              final fecha = resumen.sesion.fecha;
              final cuando = '${_capitalizar(formatoDiaSemana.format(fecha))}'
                  ' · ${formatoHora.format(fecha)}';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(GeoLiftSpacing.md),
                  child: Row(
                    children: [
                      _BloqueFecha(fecha: fecha),
                      const SizedBox(width: GeoLiftSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(resumen.nombreDia,
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(cuando,
                                style: Theme.of(context).textTheme.bodySmall),
                            if (resumen.totalSets > 0) ...[
                              const SizedBox(height: GeoLiftSpacing.sm),
                              Wrap(
                                spacing: GeoLiftSpacing.sm,
                                runSpacing: GeoLiftSpacing.xs,
                                children: [
                                  _Dato(
                                    icono: Icons.repeat_rounded,
                                    texto: '${resumen.totalSets} sets',
                                  ),
                                  _Dato(
                                    icono: Icons.fitness_center_rounded,
                                    texto:
                                        '${resumen.volumenTotal.toStringAsFixed(0)} kg',
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}

/// Día del mes en grande con el mes abreviado debajo: se escanea la lista
/// por fecha de un vistazo.
class _BloqueFecha extends StatelessWidget {
  final DateTime fecha;
  const _BloqueFecha({required this.fecha});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mes = DateFormat('MMM', 'es').format(fecha).replaceAll('.', '');
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: GeoLiftSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
      ),
      child: Column(
        children: [
          Text(
            '${fecha.day}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  height: 1.1,
                ),
          ),
          Text(
            mes.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: GeoLiftSpacing.xs),
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
