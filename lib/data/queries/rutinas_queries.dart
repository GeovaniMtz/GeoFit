import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre rutinas y sus días (tablas `Rutinas` y `RutinaDias`).
extension RutinasQueries on AppDatabase {
  Future<List<Rutina>> rutinasActivas() =>
      (select(rutinas)..where((r) => r.activa.equals(true))).get();

  Future<Rutina> obtenerRutina(int id) =>
      (select(rutinas)..where((r) => r.id.equals(id))).getSingle();

  Future<int> crearRutina(String nombre) =>
      into(rutinas).insert(RutinasCompanion.insert(nombre: nombre));

  Future<void> actualizarNombreRutina(int id, String nombre) =>
      (update(rutinas)..where((r) => r.id.equals(id)))
          .write(RutinasCompanion(nombre: Value(nombre)));

  /// "Elimina" una rutina sin borrar sus filas: solo la marca inactiva para
  /// que deje de listarse. Los días, ejercicios y sesiones quedan intactos
  /// para que el historial y las gráficas de progreso sigan funcionando.
  Future<void> archivarRutina(int id) =>
      (update(rutinas)..where((r) => r.id.equals(id)))
          .write(const RutinasCompanion(activa: Value(false)));

  Future<List<RutinaDia>> diasDeRutina(int rutinaId) => (select(rutinaDias)
        ..where((d) => d.rutinaId.equals(rutinaId))
        ..orderBy([(d) => OrderingTerm(expression: d.orden)]))
      .get();

  Future<RutinaDia> obtenerDia(int id) =>
      (select(rutinaDias)..where((d) => d.id.equals(id))).getSingle();

  Future<int> crearDia(int rutinaId, String nombreDia, int orden) =>
      into(rutinaDias).insert(RutinaDiasCompanion.insert(
        rutinaId: rutinaId,
        nombreDia: nombreDia,
        orden: Value(orden),
      ));

  Future<void> actualizarDia(int id, String nombreDia, int orden) =>
      (update(rutinaDias)..where((d) => d.id.equals(id))).write(
          RutinaDiasCompanion(
              nombreDia: Value(nombreDia), orden: Value(orden)));

  /// El día (de los configurados en la rutina) de la sesión más reciente
  /// registrada, sin importar cuál de los días de esa rutina fue. Con esto
  /// se sabe cuál sigue en la rotación; null si la rutina nunca se entrenó.
  Future<RutinaDia?> ultimoDiaEntrenado(int rutinaId) async {
    final query = select(sesionesEntrenamiento).join([
      innerJoin(rutinaDias,
          rutinaDias.id.equalsExp(sesionesEntrenamiento.rutinaDiaId)),
    ])
      ..where(rutinaDias.rutinaId.equals(rutinaId))
      ..orderBy([OrderingTerm.desc(sesionesEntrenamiento.fecha)])
      ..limit(1);

    final fila = await query.getSingleOrNull();
    return fila?.readTable(rutinaDias);
  }
}
