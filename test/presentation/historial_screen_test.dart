import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/historial_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets(
    'agrupa por semana con su total y marca las sesiones sin series',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final catalogo = await db.catalogoDeEjercicios();
      final rutinaId = await db.crearRutina('Torso');
      final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
      final re =
          await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: catalogo.first.id,
      ));

      Future<int> sesion(DateTime fecha) =>
          db.into(db.sesionesEntrenamiento).insert(
                SesionesEntrenamientoCompanion.insert(
                  rutinaDiaId: diaId,
                  fecha: Value(fecha),
                ),
              );

      final ahora = DateTime.now();
      // Una con series esta semana, otra vacía esta semana y una de hace
      // dos semanas.
      final conSeries = await sesion(ahora);
      await db.registrarSet(RegistrosSetCompanion.insert(
        sesionId: conSeries,
        rutinaEjercicioId: re,
        numeroSet: 1,
        peso: 100,
        reps: 5,
      ));
      await sesion(ahora.subtract(const Duration(minutes: 1)));
      final vieja = await sesion(ahora.subtract(const Duration(days: 14)));
      await db.registrarSet(RegistrosSetCompanion.insert(
        sesionId: vieja,
        rutinaEjercicioId: re,
        numeroSet: 1,
        peso: 60,
        reps: 10,
      ));

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HistorialScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Esta semana'), findsOneWidget);
      // La sesión vacía no cuenta como entrenada.
      expect(find.text('1 sesión · 500 kg'), findsOneWidget);
      expect(find.text('Sin series registradas'), findsOneWidget);
      expect(find.text('Semana pasada'), findsNothing);

      // La de hace dos semanas va en su propio grupo, con su propio total.
      await tester.scrollUntilVisible(find.text('1 sesión · 600 kg'), 200);
      expect(find.text('1 sesión · 600 kg'), findsOneWidget);
    },
  );
}
