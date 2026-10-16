import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/entrenar_screen.dart';

import 'entrenar_screen_test.dart' show NotificacionEntrenamientoServiceFake;

/// Rutina de un día con Press de banca a [series] series, lista para
/// entrenar. Devuelve el id del día.
Future<int> _crearDiaConPressBanca(AppDatabase db, {int series = 1}) async {
  final catalogo = await db.catalogoDeEjercicios();
  final pressBancaId =
      catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
  final rutinaId = await db.crearRutina('Torso');
  final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
  await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
    rutinaDiaId: diaId,
    ejercicioId: pressBancaId,
    seriesObjetivo: Value(series),
  ));
  return diaId;
}

ProviderContainer _contenedor(AppDatabase db) => ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider
            .overrideWithValue(NotificacionEntrenamientoServiceFake()),
      ],
    );

void main() {
  group('consultas de sesión', () {
    test('la duración se mide desde el inicio de la sesión', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _crearDiaConPressBanca(db);
      final sesionId = await db.iniciarSesion(diaId);
      final inicio = (await db.obtenerSesion(sesionId)).fecha;

      await db.actualizarDuracionSesion(sesionId,
          hasta: inicio.add(const Duration(minutes: 47, seconds: 5)));

      expect((await db.obtenerSesion(sesionId)).duracionSeg, 47 * 60 + 5);
    });

    test('las notas se guardan recortadas y una nota vacía se borra', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _crearDiaConPressBanca(db);
      final sesionId = await db.iniciarSesion(diaId);

      await db.guardarNotasSesion(sesionId, '  me dolió el hombro  ');
      expect((await db.obtenerSesion(sesionId)).notas, 'me dolió el hombro');

      await db.guardarNotasSesion(sesionId, '   ');
      expect((await db.obtenerSesion(sesionId)).notas, isNull);
    });

    test('la unidad de peso se persiste en Configuracion', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect((await db.obtenerConfiguracion()).unidadPeso, 'kg');
      await db.actualizarUnidadPeso('lb');
      expect((await db.obtenerConfiguracion()).unidadPeso, 'lb');
    });
  });

  testWidgets(
    'en libras arranca en 45 LB, sube de 5 en 5 y guarda en kg junto con el '
    'RPE marcado',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _crearDiaConPressBanca(db, series: 2);

      final container = _contenedor(db);
      addTearDown(container.dispose);
      await container
          .read(unidadPesoProvider.notifier)
          .cambiarUnidad(UnidadPeso.lb);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('45'), findsOneWidget);
      expect(find.text('LB'), findsOneWidget);

      await tester.tap(find.byTooltip('Sumar peso'));
      await tester.pump();
      expect(find.text('50'), findsOneWidget);

      await tester
          .ensureVisible(find.byTooltip('RPE 8: te quedaban unas 2 reps'));
      await tester.tap(find.byTooltip('RPE 8: te quedaban unas 2 reps'));
      await tester.pump();

      await tester.ensureVisible(find.text('REGISTRAR SERIE'));
      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();

      final sesion = (await db.historialDeSesiones()).single.sesion;
      final set = (await db.setsDeSesion(sesion.id)).single;
      expect(set.peso, closeTo(50 / UnidadPeso.librasPorKilo, 1e-9));
      expect(set.rpe, 8);
      // Se registró una serie: la sesión ya tiene duración guardada.
      expect(sesion.duracionSeg, isNotNull);

      // La lista de sets registrados lo muestra en libras y con su RPE.
      expect(find.text('50 lb × 8  @8'), findsOneWidget);
    },
  );

  testWidgets(
    'las notas escritas al completar la rutina se guardan en la sesión',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _crearDiaConPressBanca(db, series: 1);

      final container = _contenedor(db);
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('REGISTRAR SERIE'));
      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();
      expect(find.text('¡RUTINA COMPLETADA!'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, 'Notas de la sesión (opcional)'),
          'Dormí mal, bajé el peso');
      await tester.ensureVisible(find.text('VOLVER AL INICIO'));
      await tester.tap(find.text('VOLVER AL INICIO'));
      await tester.pumpAndSettle();

      final sesion = (await db.historialDeSesiones()).single.sesion;
      expect(sesion.notas, 'Dormí mal, bajé el peso');
    },
  );
}
