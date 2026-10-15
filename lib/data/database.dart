import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';
export 'queries/configuracion_queries.dart';
export 'queries/ejercicios_queries.dart';
export 'queries/observar.dart';
export 'queries/peso_corporal_queries.dart';
export 'queries/respaldo_queries.dart';
export 'queries/rutina_ejercicios_queries.dart';
export 'queries/rutinas_queries.dart';
export 'queries/sesiones_queries.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Ejercicios,
  Rutinas,
  RutinaDias,
  RutinaEjercicios,
  SesionesEntrenamiento,
  RegistrosSet,
  RegistrosPesoCorporal,
  Configuracion,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Permite inyectar un [QueryExecutor] (p. ej. una base en memoria) desde
  /// los tests, sin tocar el archivo sqlite real.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(ejercicios).insert(const EjerciciosCompanion(
            nombre: Value('Sentadilla'),
            grupoMuscular: Value('Pierna'),
          ));
          await into(ejercicios).insert(const EjerciciosCompanion(
            nombre: Value('Press de banca'),
            grupoMuscular: Value('Pecho'),
          ));
          await into(ejercicios).insert(const EjerciciosCompanion(
            nombre: Value('Peso muerto'),
            grupoMuscular: Value('Espalda'),
          ));
          await into(ejercicios).insert(const EjerciciosCompanion(
            nombre: Value('Press militar'),
            grupoMuscular: Value('Hombro'),
          ));
          await into(configuracion).insert(const ConfiguracionCompanion());
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(configuracion, configuracion.tema);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'geolift.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
