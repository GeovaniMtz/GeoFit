import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// Las 8 tablas del plan de acción.
//
// RutinaEjercicio guarda el OBJETIVO planeado (series/reps a alcanzar).
// RegistrosSet guarda lo que REALMENTE se hizo en cada serie de cada sesión.
// El motor de progresión (lib/domain/progresion_service.dart) compara ambos.
// ---------------------------------------------------------------------------

class Ejercicios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get grupoMuscular => text()();
  TextColumn get equipo => text().withDefault(const Constant(''))();
  BoolColumn get esPersonalizado =>
      boolean().withDefault(const Constant(false))();
}

class Rutinas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  BoolColumn get activa => boolean().withDefault(const Constant(true))();
  DateTimeColumn get creadaEn => dateTime().withDefault(currentDateAndTime)();
}

class RutinaDias extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinaId =>
      integer().references(Rutinas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombreDia => text()(); // p.ej. "Día 1 — Empuje"
  IntColumn get orden => integer().withDefault(const Constant(0))();
}

class RutinaEjercicios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinaDiaId =>
      integer().references(RutinaDias, #id, onDelete: KeyAction.cascade)();
  IntColumn get ejercicioId => integer().references(Ejercicios, #id)();
  IntColumn get orden => integer().withDefault(const Constant(0))();
  IntColumn get seriesObjetivo => integer().withDefault(const Constant(3))();
  IntColumn get repsMin => integer().withDefault(const Constant(8))();
  IntColumn get repsMax => integer().withDefault(const Constant(12))();
  IntColumn get descansoSeg => integer().withDefault(const Constant(90))();
}

class SesionesEntrenamiento extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinaDiaId => integer().references(RutinaDias, #id)();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  IntColumn get duracionSeg => integer().nullable()();
  TextColumn get notas => text().nullable()();
}

class RegistrosSet extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sesionId => integer()
      .references(SesionesEntrenamiento, #id, onDelete: KeyAction.cascade)();
  IntColumn get rutinaEjercicioId =>
      integer().references(RutinaEjercicios, #id)();
  IntColumn get numeroSet => integer()();
  RealColumn get peso => real()();
  IntColumn get reps => integer()();
  RealColumn get rpe => real().nullable()();
  BoolColumn get esPr => boolean().withDefault(const Constant(false))();
}

class RegistrosPesoCorporal extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  RealColumn get peso => real()();
  TextColumn get nota => text().nullable()();
}

class Configuracion extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get unidadPeso => text().withDefault(const Constant('kg'))();
  TextColumn get metaPrincipal => text().nullable()();
  // 'sistema' | 'claro' | 'oscuro'
  TextColumn get tema => text().withDefault(const Constant('sistema'))();

  // Cuántas sesiones por semana se propone entrenar (anillo de Inicio).
  IntColumn get metaSesionesSemana =>
      integer().withDefault(const Constant(4))();
}
