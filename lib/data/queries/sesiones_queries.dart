import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre sesiones de entrenamiento y los sets registrados en ellas
/// (tablas `SesionesEntrenamiento` y `RegistrosSet`).
extension SesionesQueries on AppDatabase {
  Future<int> iniciarSesion(int rutinaDiaId) => into(sesionesEntrenamiento)
      .insert(SesionesEntrenamientoCompanion.insert(rutinaDiaId: rutinaDiaId));

  Future<int> registrarSet(RegistrosSetCompanion datos) =>
      into(registrosSet).insert(datos);

  /// Historial de sets de un ejercicio del catálogo (p.ej. "Press de banca"),
  /// sin importar en qué rutina o día se hizo — así el progreso y los PRs se
  /// comparan contra el movimiento en sí, no contra una rutina en particular.
  /// Más reciente primero.
  Future<List<RegistroConFecha>> historialPorEjercicio(int ejercicioId) async {
    final query = select(registrosSet).join([
      innerJoin(rutinaEjercicios,
          rutinaEjercicios.id.equalsExp(registrosSet.rutinaEjercicioId)),
      innerJoin(sesionesEntrenamiento,
          sesionesEntrenamiento.id.equalsExp(registrosSet.sesionId)),
    ])
      ..where(rutinaEjercicios.ejercicioId.equals(ejercicioId))
      ..orderBy([OrderingTerm.desc(sesionesEntrenamiento.fecha)]);

    final filas = await query.get();
    return filas
        .map((f) => RegistroConFecha(
              registro: f.readTable(registrosSet),
              fecha: f.readTable(sesionesEntrenamiento).fecha,
            ))
        .toList();
  }

  /// Sesiones pasadas con el nombre del día entrenado y un resumen (sets y
  /// volumen total) para que Historial no necesite un query por sesión.
  Future<List<SesionResumen>> historialDeSesiones() async {
    final query = select(sesionesEntrenamiento).join([
      innerJoin(rutinaDias,
          rutinaDias.id.equalsExp(sesionesEntrenamiento.rutinaDiaId)),
    ])
      ..orderBy([OrderingTerm.desc(sesionesEntrenamiento.fecha)]);

    final filas = await query.get();
    final idsDeSesion =
        filas.map((f) => f.readTable(sesionesEntrenamiento).id).toList();

    final sets = idsDeSesion.isEmpty
        ? <RegistrosSetData>[]
        : await (select(registrosSet)
              ..where((r) => r.sesionId.isIn(idsDeSesion)))
            .get();

    final setsPorSesion = <int, List<RegistrosSetData>>{};
    for (final set in sets) {
      setsPorSesion.putIfAbsent(set.sesionId, () => []).add(set);
    }

    return filas.map((f) {
      final sesion = f.readTable(sesionesEntrenamiento);
      final setsDeSesion = setsPorSesion[sesion.id] ?? const [];
      final volumen = setsDeSesion.fold<double>(
          0, (acumulado, s) => acumulado + s.peso * s.reps);
      return SesionResumen(
        sesion: sesion,
        nombreDia: f.readTable(rutinaDias).nombreDia,
        totalSets: setsDeSesion.length,
        volumenTotal: volumen,
      );
    }).toList();
  }
}

/// Combina un [RegistrosSet] con la fecha de la sesión a la que pertenece,
/// para que las gráficas de progreso no necesiten un segundo query.
class RegistroConFecha {
  final RegistrosSetData registro;
  final DateTime fecha;
  const RegistroConFecha({required this.registro, required this.fecha});
}

/// Una sesión de entrenamiento pasada, con el nombre del día y el resumen
/// (sets totales y volumen) que muestra la pantalla de Historial.
class SesionResumen {
  final SesionesEntrenamientoData sesion;
  final String nombreDia;
  final int totalSets;
  final double volumenTotal;
  const SesionResumen({
    required this.sesion,
    required this.nombreDia,
    required this.totalSets,
    required this.volumenTotal,
  });
}
