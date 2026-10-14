import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre el catálogo de ejercicios (tabla `Ejercicios`).
extension EjerciciosQueries on AppDatabase {
  Future<List<Ejercicio>> catalogoDeEjercicios() => select(ejercicios).get();

  /// Solo los ejercicios que de verdad están en algún día de una rutina
  /// activa — a diferencia de [catalogoDeEjercicios], que trae todo lo que
  /// existe alguna vez se haya creado, use o no una rutina hoy en día.
  Future<List<Ejercicio>> ejerciciosEnUso() async {
    final query = select(ejercicios).join([
      innerJoin(rutinaEjercicios,
          rutinaEjercicios.ejercicioId.equalsExp(ejercicios.id)),
      innerJoin(rutinaDias,
          rutinaDias.id.equalsExp(rutinaEjercicios.rutinaDiaId)),
      innerJoin(rutinas, rutinas.id.equalsExp(rutinaDias.rutinaId)),
    ])
      ..where(rutinas.activa.equals(true));

    final filas = await query.get();
    // Un mismo ejercicio puede repetirse en varios días/rutinas: se
    // deduplica en Dart en vez de un DISTINCT en SQL para poder seguir
    // usando readTable() y reconstruir el Ejercicio completo.
    final porId = <int, Ejercicio>{};
    for (final fila in filas) {
      final ejercicio = fila.readTable(ejercicios);
      porId[ejercicio.id] = ejercicio;
    }
    final resultado = porId.values.toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
    return resultado;
  }

  Future<int> crearEjercicio(EjerciciosCompanion datos) =>
      into(ejercicios).insert(datos);

  /// Corrige el nombre de un ejercicio del catálogo, sin tocar su id — así
  /// el historial ya registrado con él (que se referencia por id, no por
  /// nombre) sigue intacto y pasa a mostrarse con el nombre corregido.
  Future<void> renombrarEjercicio(int id, String nombre) =>
      (update(ejercicios)..where((e) => e.id.equals(id)))
          .write(EjerciciosCompanion(nombre: Value(nombre)));
}
