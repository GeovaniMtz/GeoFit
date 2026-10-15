import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';
import '../widgets/estado_error.dart';
import 'rutina_completada_screen.dart' show formatearDuracion;

/// Lo que se hizo en una sesión pasada: cada ejercicio con sus series (peso,
/// reps, RPE y PRs), en el orden en que se entrenaron, más la nota.
class DetalleSesionScreen extends ConsumerWidget {
  final int sesionId;
  const DetalleSesionScreen({super.key, required this.sesionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(detalleSesionProvider(sesionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(detalle.valueOrNull?.nombreDia ?? 'Sesión'),
      ),
      body: detalle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EstadoError(
          onReintentar: () => ref.invalidate(detalleSesionProvider(sesionId)),
        ),
        data: (d) {
          if (d == null) {
            return const EstadoVacio(
              icono: Icons.history_rounded,
              titulo: 'Esta sesión ya no existe',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
                GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xxl),
            children: [
              _Resumen(detalle: d),
              const SizedBox(height: GeoLiftSpacing.lg),
              _Notas(sesionId: sesionId, notas: d.sesion.notas),
              const SizedBox(height: GeoLiftSpacing.xl),
              if (d.ejercicios.isEmpty)
                Text(
                  'Esta sesión no tiene series registradas.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else ...[
                const EncabezadoSeccion('Ejercicios'),
                for (final e in d.ejercicios) ...[
                  _TarjetaEjercicio(ejercicio: e),
                  const SizedBox(height: GeoLiftSpacing.md),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Fecha y hora, y chips con duración, series, volumen y PRs.
class _Resumen extends ConsumerWidget {
  final DetalleSesion detalle;
  const _Resumen({required this.detalle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidad = ref.watch(unidadPesoProvider);
    final fecha = DateFormat("EEEE d 'de' MMMM · HH:mm", 'es')
        .format(detalle.sesion.fecha);
    final duracion = detalle.sesion.duracionSeg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fecha[0].toUpperCase() + fecha.substring(1),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: GeoLiftSpacing.md),
        Wrap(
          spacing: GeoLiftSpacing.sm,
          runSpacing: GeoLiftSpacing.sm,
          children: [
            if (duracion != null && duracion > 0)
              _Dato(Icons.timer_outlined, formatearDuracion(duracion)),
            _Dato(Icons.repeat_rounded, '${detalle.totalSeries} sets'),
            _Dato(Icons.fitness_center_rounded,
                unidad.formatearConUnidad(detalle.volumenKg, decimales: 0)),
            if (detalle.totalPrs > 0)
              _Dato(
                Icons.emoji_events_rounded,
                detalle.totalPrs == 1 ? '1 PR' : '${detalle.totalPrs} PRs',
                destacado: true,
              ),
          ],
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool destacado;
  const _Dato(this.icono, this.texto, {this.destacado = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = destacado ? colorScheme.secondary : colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GeoLiftSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: destacado
            ? colorScheme.secondary.withValues(alpha: 0.14)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
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

/// La nota de la sesión, con un botón para escribirla o corregirla.
class _Notas extends ConsumerWidget {
  final int sesionId;
  final String? notas;
  const _Notas({required this.sesionId, required this.notas});

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final controlador = TextEditingController(text: notas);
    final nuevas = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notas de la sesión'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'p. ej. me molestó el hombro en el press',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevas == null) return;
    // No hace falta refrescar: detalleSesionProvider es reactivo.
    await ref.read(databaseProvider).guardarNotasSesion(sesionId, nuevas);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tieneNotas = notas != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.lg, GeoLiftSpacing.sm,
            GeoLiftSpacing.sm, GeoLiftSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.sticky_note_2_outlined,
                size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: GeoLiftSpacing.md),
            Expanded(
              child: Text(
                tieneNotas ? notas! : 'Sin notas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: tieneNotas ? FontStyle.italic : null,
                      color: tieneNotas ? colorScheme.onSurface : null,
                    ),
              ),
            ),
            IconButton(
              onPressed: () => _editar(context, ref),
              tooltip: tieneNotas ? 'Editar notas' : 'Agregar notas',
              style: IconButton.styleFrom(backgroundColor: Colors.transparent),
              icon: Icon(tieneNotas
                  ? Icons.edit_outlined
                  : Icons.add_comment_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un ejercicio con sus series: número, peso × reps, RPE y PR.
class _TarjetaEjercicio extends ConsumerWidget {
  final EjercicioDeSesion ejercicio;
  const _TarjetaEjercicio({required this.ejercicio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GeoLiftSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ejercicio.nombre, style: textTheme.titleMedium),
                ),
                Text(
                  unidad.formatearConUnidad(ejercicio.volumenKg, decimales: 0),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: GeoLiftSpacing.md),
            for (final s in ejercicio.series)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                      ),
                      child:
                          Text('${s.numeroSet}', style: textTheme.labelSmall),
                    ),
                    const SizedBox(width: GeoLiftSpacing.md),
                    Expanded(
                      child: Text(
                        '${unidad.formatearConUnidad(s.peso)} × ${s.reps}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (s.rpe != null)
                      Padding(
                        padding: const EdgeInsets.only(left: GeoLiftSpacing.sm),
                        child: Text('RPE ${s.rpe!.toStringAsFixed(0)}',
                            style: textTheme.bodySmall),
                      ),
                    if (s.esPr)
                      Padding(
                        padding: const EdgeInsets.only(left: GeoLiftSpacing.sm),
                        child: Tooltip(
                          message: 'Récord personal',
                          child: Icon(Icons.emoji_events_rounded,
                              size: 18, color: colorScheme.secondary),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
