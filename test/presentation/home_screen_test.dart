import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('la pantalla de inicio muestra qué día es hoy', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hoy es '), findsOneWidget);
  });

  testWidgets(
    'marca con "SIGUIENTE" el día que toca dentro de la rutina (no la '
    'rutina completa) y rota tras entrenar',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final rutinaId = await db.crearRutina('Push Pull Legs');
      final diaEmpujeId = await db.crearDia(rutinaId, 'Empuje', 0);
      await db.crearDia(rutinaId, 'Tirón', 1);

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ));
      await tester.pumpAndSettle();

      // Ya no existe la etiqueta vieja a nivel de rutina completa.
      expect(find.textContaining('HOY TOCA'), findsNothing);

      // Sin historial, "SIGUIENTE" va junto al primer día.
      expect(find.text('SIGUIENTE'), findsOneWidget);
      final filaEmpuje = tester.getTopLeft(find.text('Empuje'));
      final etiquetaSiguiente = tester.getTopLeft(find.text('SIGUIENTE'));
      expect(etiquetaSiguiente.dy, closeTo(filaEmpuje.dy, 30));

      await db.iniciarSesion(diaEmpujeId);
      container.invalidate(ultimoDiaEntrenadoProvider(rutinaId));
      await tester.pumpAndSettle();

      // Tras entrenar Empuje, "SIGUIENTE" rota a la fila de Tirón.
      final filaTiron = tester.getTopLeft(find.text('Tirón'));
      final etiquetaSiguienteDespues = tester.getTopLeft(find.text('SIGUIENTE'));
      expect(etiquetaSiguienteDespues.dy, closeTo(filaTiron.dy, 30));
    },
  );
}
