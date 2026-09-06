import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const TarjetaDia({
    super.key,
    required this.indice,
    required this.dia,
    required this.onAgregarEjercicio,
    required this.onEditarEjercicio,
    required this.onQuitarEjercicio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: dia.controladorNombre,
              decoration: InputDecoration(
                labelText: 'Nombre del día ${indice + 1}',
                hintText: 'p. ej. Empuje',
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < dia.ejercicios.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(dia.ejercicios[i].nombreEjercicio),
                subtitle: Text(
                  '${dia.ejercicios[i].seriesObjetivo} series · '
                  '${dia.ejercicios[i].repsMin}-${dia.ejercicios[i].repsMax} reps · '
                  '${dia.ejercicios[i].descansoSeg}s descanso',
                ),
                onTap: () => mostrarFormularioDeEjercicio(
                  context,
                  existente: dia.ejercicios[i],
                  onGuardar: (actualizado) => onEditarEjercicio(i, actualizado),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Quitar ejercicio',
                  onPressed: () => onQuitarEjercicio(i),
                ),
              ),
            TextButton.icon(
              onPressed: () => mostrarFormularioDeEjercicio(
                context,
                onGuardar: onAgregarEjercicio,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('AGREGAR EJERCICIO'),
            ),
          ],
        ),
      ),
    );
  }
}
