import 'package:drift/drift.dart' show Value;

import '../database.dart';

/// Todo lo que la pantalla de Entrenar necesita de la base, en un solo
/// lugar: así ni el controlador ni los widgets hablan SQL, y si algún día
/// los datos vienen de otro lado (p. ej. sincronización con un servidor),
/// solo cambia esta clase.
class EntrenamientoRepository {
  final AppDatabase _db;
  EntrenamientoRepository(this._db);

  // ---- Sesión ---------------------------------------------------------------

  /// Retoma la sesión de hoy para el día o crea una nueva.
  Future<int> iniciarOResumirSesion(int rutinaDiaId) =>
      _db.iniciarOResumirSesion(rutinaDiaId);

  Future<List<RutinaEjercicio>> ejerciciosDeDia(int rutinaDiaId) =>
      _db.ejerciciosDeDia(rutinaDiaId);

  /// Cuántas series lleva registradas cada ejercicio (por id de
  /// `RutinaEjercicio`) en la sesión — para saber dónde retomar.
  Future<Map<int, int>> seriesHechasPorEjercicio(int sesionId) async {
    final sets = await _db.setsDeSesion(sesionId);
    final conteo = <int, int>{};
    for (final set in sets) {
      conteo[set.rutinaEjercicioId] = (conteo[set.rutinaEjercicioId] ?? 0) + 1;
    }
    return conteo;
  }

  // ---- Ejercicio ------------------------------------------------------------

  Future<Ejercicio?> ejercicio(int ejercicioId) async {
    final catalogo = await _db.catalogoDeEjercicios();
    for (final e in catalogo) {
      if (e.id == ejercicioId) return e;
    }
    return null;
  }

  /// Series ya registradas de un ejercicio en esta sesión, en orden.
  Future<List<RegistrosSetData>> seriesEnSesion(
          int sesionId, int rutinaEjercicioId) =>
      _db.setsDeEjercicioEnSesion(sesionId, rutinaEjercicioId);

  /// Historial completo del ejercicio del catálogo, más reciente primero.
  Future<List<RegistroConFecha>> historial(int ejercicioId) =>
      _db.historialPorEjercicio(ejercicioId);

  /// Guarda una serie y actualiza la duración de la sesión.
  Future<void> registrarSerie({
    required int sesionId,
    required int rutinaEjercicioId,
    required int numeroSet,
    required double pesoKg,
    required int reps,
    required double? rpe,
    required bool esPr,
  }) async {
    await _db.registrarSet(RegistrosSetCompanion.insert(
      sesionId: sesionId,
      rutinaEjercicioId: rutinaEjercicioId,
      numeroSet: numeroSet,
      peso: pesoKg,
      reps: reps,
      esPr: Value(esPr),
      rpe: Value(rpe),
    ));
    await _db.actualizarDuracionSesion(sesionId);
  }
}
