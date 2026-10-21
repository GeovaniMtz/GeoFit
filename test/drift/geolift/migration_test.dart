// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:geolift/data/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Además de que el esquema quede bien, los DATOS de quien ya usa la app
  // deben llegar intactos: aquí una base v1 con una rutina entrenada, peso
  // corporal y la configuración en libras.
  test('de v1 a v2 se conservan todos los datos y tema queda en "sistema"',
      () async {
    // Las clases generadas por versión usan los tipos crudos de SQLite:
    // booleanos como 0/1 y fechas como segundos desde 1970.
    final creada = DateTime(2026, 9, 1, 7, 30).millisecondsSinceEpoch ~/ 1000;
    final entrenada =
        DateTime(2026, 9, 2, 18, 15).millisecondsSinceEpoch ~/ 1000;

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.ejercicios, const [
          v1.EjerciciosData(
              id: 1,
              nombre: 'Sentadilla',
              grupoMuscular: 'Pierna',
              equipo: '',
              esPersonalizado: 0),
        ]);
        batch.insertAll(oldDb.rutinas, [
          v1.RutinasData(id: 1, nombre: 'Pierna', activa: 1, creadaEn: creada),
        ]);
        batch.insertAll(oldDb.rutinaDias, const [
          v1.RutinaDiasData(id: 1, rutinaId: 1, nombreDia: 'Día 1', orden: 0),
        ]);
        batch.insertAll(oldDb.rutinaEjercicios, const [
          v1.RutinaEjerciciosData(
              id: 1,
              rutinaDiaId: 1,
              ejercicioId: 1,
              orden: 0,
              seriesObjetivo: 4,
              repsMin: 6,
              repsMax: 8,
              descansoSeg: 120),
        ]);
        batch.insertAll(oldDb.sesionesEntrenamiento, [
          v1.SesionesEntrenamientoData(
              id: 1,
              rutinaDiaId: 1,
              fecha: entrenada,
              duracionSeg: 3600,
              notas: 'Rodilla bien'),
        ]);
        batch.insertAll(oldDb.registrosSet, const [
          v1.RegistrosSetData(
              id: 1,
              sesionId: 1,
              rutinaEjercicioId: 1,
              numeroSet: 1,
              peso: 100,
              reps: 8,
              rpe: 8,
              esPr: 1),
          v1.RegistrosSetData(
              id: 2,
              sesionId: 1,
              rutinaEjercicioId: 1,
              numeroSet: 2,
              peso: 100,
              reps: 7,
              esPr: 0),
        ]);
        batch.insertAll(oldDb.registrosPesoCorporal, [
          v1.RegistrosPesoCorporalData(id: 1, fecha: entrenada, peso: 82.5),
        ]);
        batch.insertAll(oldDb.configuracion, const [
          v1.ConfiguracionData(id: 1, unidadPeso: 'lb'),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.ejercicios).get(), const [
          v2.EjerciciosData(
              id: 1,
              nombre: 'Sentadilla',
              grupoMuscular: 'Pierna',
              equipo: '',
              esPersonalizado: 0),
        ]);
        expect(await newDb.select(newDb.rutinas).get(), [
          v2.RutinasData(id: 1, nombre: 'Pierna', activa: 1, creadaEn: creada),
        ]);
        expect(await newDb.select(newDb.rutinaEjercicios).get(), const [
          v2.RutinaEjerciciosData(
              id: 1,
              rutinaDiaId: 1,
              ejercicioId: 1,
              orden: 0,
              seriesObjetivo: 4,
              repsMin: 6,
              repsMax: 8,
              descansoSeg: 120),
        ]);
        expect(await newDb.select(newDb.sesionesEntrenamiento).get(), [
          v2.SesionesEntrenamientoData(
              id: 1,
              rutinaDiaId: 1,
              fecha: entrenada,
              duracionSeg: 3600,
              notas: 'Rodilla bien'),
        ]);
        expect(await newDb.select(newDb.registrosSet).get(), const [
          v2.RegistrosSetData(
              id: 1,
              sesionId: 1,
              rutinaEjercicioId: 1,
              numeroSet: 1,
              peso: 100,
              reps: 8,
              rpe: 8,
              esPr: 1),
          v2.RegistrosSetData(
              id: 2,
              sesionId: 1,
              rutinaEjercicioId: 1,
              numeroSet: 2,
              peso: 100,
              reps: 7,
              esPr: 0),
        ]);
        expect(await newDb.select(newDb.registrosPesoCorporal).get(), [
          v2.RegistrosPesoCorporalData(id: 1, fecha: entrenada, peso: 82.5),
        ]);
        expect(await newDb.select(newDb.configuracion).get(), const [
          v2.ConfiguracionData(id: 1, unidadPeso: 'lb', tema: 'sistema'),
        ]);
      },
    );
  });

  test('de v2 a v3 se conservan los ajustes y la meta semanal queda en 4',
      () async {
    final creada = DateTime(2026, 9, 1, 7, 30).millisecondsSinceEpoch ~/ 1000;

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.rutinas, [
          v2.RutinasData(id: 1, nombre: 'Torso', activa: 1, creadaEn: creada),
        ]);
        batch.insertAll(oldDb.configuracion, const [
          v2.ConfiguracionData(id: 1, unidadPeso: 'lb', tema: 'oscuro'),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.rutinas).get(), [
          v3.RutinasData(id: 1, nombre: 'Torso', activa: 1, creadaEn: creada),
        ]);
        expect(await newDb.select(newDb.configuracion).get(), const [
          v3.ConfiguracionData(
              id: 1, unidadPeso: 'lb', tema: 'oscuro', metaSesionesSemana: 4),
        ]);
      },
    );
  });
}
