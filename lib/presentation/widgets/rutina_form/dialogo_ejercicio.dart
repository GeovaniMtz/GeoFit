import 'package:flutter/material.dart';

import '../../../domain/clasificador_ejercicio.dart';
import 'borrador.dart';

/// Diálogo para agregar (o editar, si se pasa [existente]) el ejercicio
/// objetivo de un día de rutina: nombre, descanso, series y reps.
void mostrarFormularioDeEjercicio(
  BuildContext context, {
  EjercicioBorrador? existente,
  required void Function(EjercicioBorrador) onGuardar,
}) {
  final controladorNombre =
      TextEditingController(text: existente?.nombreEjercicio ?? '');
  final controladorSeries =
      TextEditingController(text: '${existente?.seriesObjetivo ?? 3}');
  final controladorRepsMin =
      TextEditingController(text: '${existente?.repsMin ?? 8}');
  final controladorRepsMax =
      TextEditingController(text: '${existente?.repsMax ?? 12}');
  final controladorDescanso = TextEditingController(
      text:
          '${existente?.descansoSeg ?? ClasificadorEjercicio.descansoSugeridoSeg('')}');
  // Al editar, se respeta el descanso ya guardado hasta que el usuario lo
  // toque; al crear, sigue la sugerencia mientras no lo edite a mano.
  var descansoTocado = existente != null;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialogo) => AlertDialog(
        scrollable: true,
        title:
            Text(existente == null ? 'Agregar ejercicio' : 'Editar ejercicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controladorNombre,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'p. ej. Sentadilla',
              ),
              onChanged: (nombre) {
                if (!descansoTocado) {
                  controladorDescanso.text =
                      '${ClasificadorEjercicio.descansoSugeridoSeg(nombre)}';
                }
                setStateDialogo(() {});
              },
            ),
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final tipo =
                  ClasificadorEjercicio.clasificar(controladorNombre.text);
              final descanso = ClasificadorEjercicio.descansoSugeridoSeg(
                  controladorNombre.text);
              final etiquetaTipo = switch (tipo) {
                TipoEjercicio.maquina => 'máquina',
                TipoEjercicio.pesoLibre => 'peso libre',
                TipoEjercicio.indeterminado => 'sin detectar',
              };
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'Descanso sugerido: ${descanso}s ($etiquetaTipo)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setStateDialogo(() {
                      controladorDescanso.text = '$descanso';
                      descansoTocado = false;
                    }),
                    child: const Text('USAR'),
                  ),
                ],
              );
            }),
            const SizedBox(height: 6),
            TextField(
              controller: controladorDescanso,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Descanso (segundos)'),
              onChanged: (_) => descansoTocado = true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controladorSeries,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Series'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controladorRepsMin,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps mín.'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controladorRepsMax,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps máx.'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final nombre = controladorNombre.text.trim();
              if (nombre.isEmpty) return;

              final series = int.tryParse(controladorSeries.text) ?? 3;
              final repsMin = int.tryParse(controladorRepsMin.text) ?? 8;
              final repsMax = int.tryParse(controladorRepsMax.text) ?? 12;

              onGuardar(EjercicioBorrador(
                rutinaEjercicioId: existente?.rutinaEjercicioId,
                ejercicioId: existente?.ejercicioId,
                nombreEjercicio: nombre,
                seriesObjetivo: series < 1 ? 1 : series,
                repsMin: repsMin < 1 ? 1 : repsMin,
                repsMax: repsMax < repsMin ? repsMin : repsMax,
                descansoSeg: int.tryParse(controladorDescanso.text) ??
                    ClasificadorEjercicio.descansoSugeridoSeg(nombre),
                nombreEjercicioOriginal: existente?.nombreEjercicioOriginal,
              ));
              Navigator.pop(context);
            },
            child: Text(existente == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    ),
  );
}
