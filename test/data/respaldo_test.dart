import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:path/path.dart' as p;

void main() {
  // Aquí se abren a propósito dos bases a la vez (origen y destino), cada
  // una con su propia conexión en memoria: el aviso de Drift no aplica.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory carpeta;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('geolift_respaldo_');
  });

  tearDown(() async {
    if (await carpeta.exists()) await carpeta.delete(recursive: true);
  });

  /// Base con una rutina, una sesión con un set (con RPE y nota) y un
  /// registro de peso corporal, y la configuración en lb.
  Future<AppDatabase> baseConDatos() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final catalogo = await db.catalogoDeEjercicios();
    final sentadillaId =
        catalogo.firstWhere((e) => e.nombre == 'Sentadilla').id;
    final rutinaId = await db.crearRutina('Pierna');
    final diaId = await db.crearDia(rutinaId, 'Día 1', 0);
    final reId =
        await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
      rutinaDiaId: diaId,
      ejercicioId: sentadillaId,
    ));
    final sesionId = await db.iniciarSesion(diaId);
    await db.registrarSet(RegistrosSetCompanion.insert(
      sesionId: sesionId,
      rutinaEjercicioId: reId,
      numeroSet: 1,
      peso: 100,
      reps: 5,
      rpe: const Value(8),
    ));
    await db.guardarNotasSesion(sesionId, 'Buena sesión');
    await db.registrarPesoCorporal(82.5);
    await db.actualizarUnidadPeso('lb');
    return db;
  }

  test('exportar y restaurar en otra base deja exactamente los mismos datos',
      () async {
    final origen = await baseConDatos();
    addTearDown(origen.close);
    final ruta = p.join(carpeta.path, 'respaldo.sqlite');
    await origen.exportarA(ruta);
    expect(await File(ruta).exists(), isTrue);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(destino.close);
    // El destino ya tenía algo propio: debe desaparecer.
    await destino.crearRutina('Rutina que se va a perder');

    await destino.restaurarDesde(ruta);

    final rutinas = await destino.rutinasActivas();
    expect(rutinas.map((r) => r.nombre), ['Pierna']);

    final sesiones = await destino.historialDeSesiones();
    expect(sesiones, hasLength(1));
    expect(sesiones.single.sesion.notas, 'Buena sesión');
    expect(sesiones.single.totalSets, 1);

    final sets = await destino.setsDeSesion(sesiones.single.sesion.id);
    expect(sets.single.peso, 100);
    expect(sets.single.rpe, 8);

    expect((await destino.historialPesoCorporal()).single.peso, 82.5);
    expect((await destino.obtenerConfiguracion()).unidadPeso, 'lb');
  });

  test('tras restaurar se pueden seguir agregando datos sin chocar ids',
      () async {
    final origen = await baseConDatos();
    addTearDown(origen.close);
    final ruta = p.join(carpeta.path, 'respaldo.sqlite');
    await origen.exportarA(ruta);

    final destino = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(destino.close);
    await destino.restaurarDesde(ruta);

    await destino.crearRutina('Nueva');
    expect((await destino.rutinasActivas()).map((r) => r.nombre),
        containsAll(['Pierna', 'Nueva']));
  });

  test('un archivo que no es una base se rechaza sin tocar los datos',
      () async {
    final db = await baseConDatos();
    addTearDown(db.close);
    final ruta = p.join(carpeta.path, 'foto.jpg');
    await File(ruta).writeAsString('esto no es sqlite' * 100);

    await expectLater(
        db.restaurarDesde(ruta), throwsA(isA<RespaldoInvalido>()));
    expect((await db.rutinasActivas()).single.nombre, 'Pierna');
  });

  test('una base SQLite ajena (sin las tablas de GeoLift) se rechaza',
      () async {
    final ajena = NativeDatabase(File(p.join(carpeta.path, 'otra.sqlite')));
    final dbAjena = _BaseAjena(ajena);
    await dbAjena.customStatement('CREATE TABLE notas (id INTEGER)');
    await dbAjena.close();

    final db = await baseConDatos();
    addTearDown(db.close);
    await expectLater(db.restaurarDesde(p.join(carpeta.path, 'otra.sqlite')),
        throwsA(isA<RespaldoInvalido>()));
    expect((await db.rutinasActivas()).single.nombre, 'Pierna');
  });

  test('un respaldo de una versión más nueva se rechaza', () async {
    final origen = await baseConDatos();
    final ruta = p.join(carpeta.path, 'futuro.sqlite');
    await origen.exportarA(ruta);
    await origen.close();

    final futuro = _BaseAjena(NativeDatabase(File(ruta)));
    await futuro.customStatement('PRAGMA user_version = 999');
    await futuro.close();

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await expectLater(
        db.restaurarDesde(ruta),
        throwsA(isA<RespaldoInvalido>()
            .having((e) => e.mensaje, 'mensaje', contains('más nueva'))));
  });
}

/// Conexión cruda a un archivo SQLite cualquiera, para fabricar archivos
/// que NO son respaldos válidos de GeoLift.
class _BaseAjena {
  final NativeDatabase _executor;
  _BaseAjena(this._executor);

  Future<void> customStatement(String sql) async {
    await _executor.ensureOpen(_SinMigraciones());
    await _executor.runCustom(sql);
  }

  Future<void> close() => _executor.close();
}

class _SinMigraciones extends QueryExecutorUser {
  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(
      QueryExecutor executor, OpeningDetails details) async {}
}
