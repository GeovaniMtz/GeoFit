import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/core/respaldo_automatico.dart';
import 'package:geolift/data/database.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;

void main() {
  // El último test abre una segunda base a propósito para restaurar en ella.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory carpeta;
  late AppDatabase db;

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('geolift_auto_');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.crearRutina('Pierna');
  });

  tearDown(() async {
    await db.close();
    if (await carpeta.exists()) await carpeta.delete(recursive: true);
  });

  test('la primera vez siempre respalda, aunque la carpeta no exista',
      () async {
    final sub = Directory(p.join(carpeta.path, 'GeoLift'));
    final auto = RespaldoAutomatico(sub);

    final creado =
        await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 14, 9, 30));

    expect(creado, isNotNull);
    expect(p.basename(creado!.path), 'geolift-auto-2026-10-14_0930.sqlite');
    expect(await auto.ultimo(), DateTime(2026, 10, 14, 9, 30));
  });

  test('no vuelve a respaldar antes de la semana', () async {
    final auto = RespaldoAutomatico(carpeta);
    await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 1, 8));

    expect(await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 7, 23)),
        isNull);
    expect(await auto.respaldos(), hasLength(1));
  });

  test('a los 7 días crea uno nuevo', () async {
    final auto = RespaldoAutomatico(carpeta);
    await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 1, 8));

    final nuevo =
        await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 8, 8));

    expect(nuevo, isNotNull);
    expect(await auto.ultimo(), DateTime(2026, 10, 8, 8));
  });

  test('conserva solo los 4 más recientes', () async {
    final auto = RespaldoAutomatico(carpeta);
    for (var semana = 0; semana < 6; semana++) {
      await auto.respaldarSiToca(db,
          ahora: DateTime(2026, 9, 1).add(Duration(days: 7 * semana)));
    }

    final quedan = await auto.respaldos();
    expect(quedan, hasLength(4));
    expect(quedan.first.fecha, DateTime(2026, 10, 6));
    expect(quedan.last.fecha, DateTime(2026, 9, 15));
  });

  test('ignora archivos ajenos en la carpeta', () async {
    await File(p.join(carpeta.path, 'foto.jpg')).writeAsString('x');
    await File(p.join(carpeta.path, 'geolift-auto-no-es-fecha.sqlite'))
        .writeAsString('x');
    final auto = RespaldoAutomatico(carpeta);

    expect(await auto.ultimo(), isNull);
    await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 14));
    expect(await File(p.join(carpeta.path, 'foto.jpg')).exists(), isTrue);
  });

  test('el respaldo automático se puede restaurar', () async {
    final auto = RespaldoAutomatico(carpeta);
    final archivo =
        await auto.respaldarSiToca(db, ahora: DateTime(2026, 10, 14));

    final otra = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(otra.close);
    await otra.restaurarDesde(archivo!.path);

    expect((await otra.rutinasActivas()).single.nombre, 'Pierna');
  });
}
