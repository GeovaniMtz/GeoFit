import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/detalle_sesion_screen.dart';
import 'package:geolift/presentation/widgets/anillo.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  /// Día con Sentadilla (orden 0) y Press de banca (orden 1). En la sesión
  /// se APLAZÓ la sentadilla: primero se hizo el press (2 series, la
  /// primera PR con RPE 8) y después la sentadilla (1 serie).
  Future<int> sesionConAplazado(AppDatabase db) async {
    final catalogo = await db.catalogoDeEjercicios();
    int id(String nombre) => catalogo.firstWhere((e) => e.nombre == nombre).id;
    final rutinaId = await db.crearRutina('Full body');
    final diaId = await db.crearDia(rutinaId, 'Día A', 0);
    final sentadilla =
        await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
      rutinaDiaId: diaId,
      ejercicioId: id('Sentadilla'),
      orden: const Value(0),
    ));
    final press =
        await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
      rutinaDiaId: diaId,
      ejercicioId: id('Press de banca'),
      orden: const Value(1),
    ));
    final sesionId = await db.iniciarSesion(diaId);

    Future<void> serie(int re, int n, double peso, int reps,
            {double? rpe, bool pr = false}) =>
        db.registrarSet(RegistrosSetCompanion.insert(
          sesionId: sesionId,
          rutinaEjercicioId: re,
          numeroSet: n,
          peso: peso,
          reps: reps,
          rpe: Value(rpe),
          esPr: Value(pr),
        ));
    await serie(press, 1, 60, 8, rpe: 8, pr: true);
    await serie(press, 2, 60, 7);
    await serie(sentadilla, 1, 100, 5);
    return sesionId;
  }

  group('detalleDeSesion', () {
    test('ordena los ejercicios como se entrenaron, no como la rutina',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final sesionId = await sesionConAplazado(db);

      final d = (await db.detalleDeSesion(sesionId))!;

      expect(d.nombreDia, 'Día A');
      expect(
          d.ejercicios.map((e) => e.nombre), ['Press de banca', 'Sentadilla']);
      expect(d.ejercicios.first.series.map((s) => s.numeroSet), [1, 2]);
      expect(d.totalSeries, 3);
      expect(d.volumenKg, 60 * 8 + 60 * 7 + 100 * 5);
      expect(d.totalPrs, 1);
    });

    test('devuelve null si la sesión no existe', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      expect(await db.detalleDeSesion(999), isNull);
    });
  });

  testWidgets(
    'muestra cada ejercicio con sus series, RPE y PR, y la nota editada se '
    've de inmediato',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final sesionId = await sesionConAplazado(db);

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: DetalleSesionScreen(sesionId: sesionId)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Día A'), findsOneWidget);
      // Métricas grandes: 3 series y 1 récord.
      Finder metrica(String numero, [String? unidad]) =>
          find.byWidgetPredicate((w) =>
              w is NumeroConUnidad && w.numero == numero && w.unidad == unidad);
      expect(metrica('3'), findsOneWidget);
      expect(metrica('1', 'PR'), findsOneWidget);
      expect(find.text('Press de banca'), findsOneWidget);
      expect(find.text('60 kg × 8'), findsOneWidget);
      expect(find.text('RPE 8'), findsOneWidget);
      expect(find.byTooltip('Récord personal'), findsOneWidget);
      expect(find.text('100 kg × 5'), findsOneWidget);
      expect(find.text('Sin notas'), findsOneWidget);

      await tester.tap(find.byTooltip('Agregar notas'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Rodilla bien');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Sin refrescar a mano: el provider es reactivo.
      expect(find.text('Rodilla bien'), findsOneWidget);
      expect(find.byTooltip('Editar notas'), findsOneWidget);
    },
  );
}
