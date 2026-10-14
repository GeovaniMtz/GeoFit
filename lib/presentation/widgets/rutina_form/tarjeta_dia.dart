import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'borrador.dart';
import 'dialogo_ejercicio.dart';

/// Tarjeta de un día de la rutina en el formulario: su nombre y la lista de
/// ejercicios objetivo configurados, con acciones para agregar/editar/quitar.
class TarjetaDia extends ConsumerWidget {
  final int indice;
  final DiaBorrador dia;
  final void Function(EjercicioBorrador ejercicio) onAgregarEjercicio;
  final void Function(int indice, EjercicioBorrador actualizado)
      onEditarEjercicio;
  final void Function(int indice) onQuitarEjercicio;
  final void Function() onDuplicarDia;

  const TarjetaDia({
    super.key,
    required this.indice,
    required this.dia,
    required this.onAgregarEjercicio,
    required this.onEditarEjercicio,
    required this.onQuitarEjercicio,
    required this.onDuplicarDia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: GeoLiftSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(GeoLiftSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dia.controladorNombre,
                    decoration: InputDecoration(
                      labelText: 'Nombre del día ${indice + 1}',
                      hintText: 'p. ej. Empuje',
                    ),
                  ),
                ),
                const SizedBox(width: GeoLiftSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  tooltip: 'Duplicar día',
                  onPressed: onDuplicarDia,
                ),
              ],
            ),
            const SizedBox(height: GeoLiftSpacing.md),
            for (var i = 0; i < dia.ejercicios.length; i++)
              ListTile(
                contentPadding:
                    const EdgeInsets.only(left: GeoLiftSpacing.md),
                title: Text(dia.ejercicios[i].nombreEjercicio,
                    style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(
                  '${dia.ejercicios[i].seriesObjetivo} series · '
                  '${dia.ejercicios[i].repsMin}-${dia.ejercicios[i].repsMax} reps · '
                  '${dia.ejercicios[i].descansoSeg}s descanso',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => mostrarFormularioDeEjercicio(
                  context,
                  existente: dia.ejercicios[i],
                  onGuardar: (actualizado) => onEditarEjercicio(i, actualizado),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Quitar ejercicio',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => onQuitarEjercicio(i),
                ),
              ),
            const SizedBox(height: GeoLiftSpacing.xs),
            TextButton.icon(
              onPressed: () => mostrarFormularioDeEjercicio(
                context,
                onGuardar: onAgregarEjercicio,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('AGREGAR EJERCICIO'),
            ),
          ],
        ),
      ),
    );
  }
}
