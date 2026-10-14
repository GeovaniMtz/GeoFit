import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre los ejercicios configurados dentro de un día de rutina
/// (tabla `RutinaEjercicios`) — el objetivo planeado, no lo que se registró.
extension RutinaEjerciciosQueries on AppDatabase {
  Future<List<RutinaEjercicio>> ejerciciosDeDia(int rutinaDiaId) =>
      (select(rutinaEjercicios)
            ..where((e) => e.rutinaDiaId.equals(rutinaDiaId))
            ..orderBy([(e) => OrderingTerm(expression: e.orden)]))
          .get();

  /// Igual que [ejerciciosDeDia] pero con el nombre del ejercicio del
  /// catálogo ya resuelto, para poblar el formulario de edición sin
  /// consultas adicionales.
  Future<List<RutinaEjercicioConNombre>> ejerciciosDeDiaConNombre(
      int rutinaDiaId) async {
    final query = select(rutinaEjercicios).join([
      innerJoin(
          ejercicios, ejercicios.id.equalsExp(rutinaEjercicios.ejercicioId)),
    ])
      ..where(rutinaEjercicios.rutinaDiaId.equals(rutinaDiaId))
      ..orderBy([OrderingTerm(expression: rutinaEjercicios.orden)]);

    final filas = await query.get();
    return filas
        .map((f) => RutinaEjercicioConNombre(
              rutinaEjercicio: f.readTable(rutinaEjercicios),
              nombreEjercicio: f.readTable(ejercicios).nombre,
            ))
        .toList();
  }

  Future<int> agregarEjercicioARutina(RutinaEjerciciosCompanion datos) =>
      into(rutinaEjercicios).insert(datos);

  Future<void> actualizarEjercicioDeRutina(
    int id, {
    required int ejercicioId,
    required int orden,
    required int seriesObjetivo,
    required int repsMin,
    required int repsMax,
    required int descansoSeg,
  }) =>
      (update(rutinaEjercicios)..where((e) => e.id.equals(id)))
          .write(RutinaEjerciciosCompanion(
        ejercicioId: Value(ejercicioId),
        orden: Value(orden),
        seriesObjetivo: Value(seriesObjetivo),
        repsMin: Value(repsMin),
        repsMax: Value(repsMax),
        descansoSeg: Value(descansoSeg),
      ));

  Future<void> eliminarEjercicioDeRutina(int id) =>
      (delete(rutinaEjercicios)..where((e) => e.id.equals(id))).go();
}

/// Combina un [RutinaEjercicio] (el objetivo guardado en una rutina) con el
/// nombre del ejercicio del catálogo, para poblar el formulario de edición
/// sin una consulta aparte por cada fila.
class RutinaEjercicioConNombre {
  final RutinaEjercicio rutinaEjercicio;
  final String nombreEjercicio;
  const RutinaEjercicioConNombre({
    required this.rutinaEjercicio,
    required this.nombreEjercicio,
  });
}
