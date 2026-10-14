import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/entrenar_screen.dart';

import 'entrenar_screen_test.dart' show NotificacionEntrenamientoServiceFake;

/// Día con Press de banca (3 series de 8–12) y una sesión de AYER con las
/// series dadas como (peso, reps, rpe). Devuelve el id del día.
Future<int> _diaConSesionDeAyer(
  AppDatabase db,
  List<(double, int, double?)> seriesDeAyer,
) async {
  final catalogo = await db.catalogoDeEjercicios();
  final pressBancaId =
      catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
  final rutinaId = await db.crearRutina('Torso');
  final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
  final rutinaEjercicioId =
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
    rutinaDiaId: diaId,
    ejercicioId: pressBancaId,
    seriesObjetivo: const Value(3),
    repsMin: const Value(8),
    repsMax: const Value(12),
  ));

  // De ayer, para que "Entrenar" no la retome como la sesión de hoy.
  final sesionId = await db.into(db.sesionesEntrenamiento).insert(
        SesionesEntrenamientoCompanion.insert(
          rutinaDiaId: diaId,
          fecha: Value(DateTime.now().subtract(const Duration(days: 1))),
        ),
      );
  for (var i = 0; i < seriesDeAyer.length; i++) {
    final (peso, reps, rpe) = seriesDeAyer[i];
    await db.registrarSet(RegistrosSetCompanion.insert(
      sesionId: sesionId,
      rutinaEjercicioId: rutinaEjercicioId,
      numeroSet: i + 1,
      peso: peso,
      reps: reps,
      rpe: Value(rpe),
    ));
  }
  return diaId;
}

Future<void> _abrirEntrenar(WidgetTester tester, AppDatabase db, int diaId) {
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      notificationServiceProvider
          .overrideWithValue(NotificacionEntrenamientoServiceFake()),
    ],
  );
  addTearDown(container.dispose);
  return tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
  ));
}

void main() {
  testWidgets(
    'tras una sesión al tope con reps de sobra sugiere subir y precarga el '
    'peso nuevo',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _diaConSesionDeAyer(db, [
        (60, 12, 7),
        (60, 12, 8),
        (60, 12, 8),
      ]);

      await _abrirEntrenar(tester, db, diaId);
      await tester.pumpAndSettle();

      expect(find.text('Hoy sube a 62.5 kg'), findsOneWidget);
      expect(find.text('62.5'), findsOneWidget);
    },
  );

  testWidgets(
    'tras llegar al tope pero al límite sugiere mantener el peso',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _diaConSesionDeAyer(db, [
        (60, 12, 9),
        (60, 12, 10),
        (60, 12, 10),
      ]);

      await _abrirEntrenar(tester, db, diaId);
      await tester.pumpAndSettle();

      expect(find.text('Hoy mantén 60 kg'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    },
  );

  testWidgets(
    'sin RPE y con una sola sesión no muestra sugerencia',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final diaId = await _diaConSesionDeAyer(db, [
        (60, 12, null),
        (60, 12, null),
      ]);

      await _abrirEntrenar(tester, db, diaId);
      await tester.pumpAndSettle();

      expect(find.textContaining('Hoy '), findsNothing);
      // Sin sugerencia arranca con el peso de la sesión anterior.
      expect(find.text('60'), findsOneWidget);
    },
  );
}
