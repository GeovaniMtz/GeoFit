import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/rutinas_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets(
    'muestra cuál día de la rutina toca, y rota tras entrenar',
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
        child: const MaterialApp(home: RutinasScreen()),
      ));
      await tester.pumpAndSettle();

      // Sin historial, toca el primer día configurado.
      expect(find.text('Toca: Empuje'), findsOneWidget);

      // Se registra una sesión del día "Empuje" y se invalida el provider
      // para que la pantalla refleje el nuevo historial.
      await db.iniciarSesion(diaEmpujeId);
      container.invalidate(ultimoDiaEntrenadoProvider(rutinaId));
      await tester.pumpAndSettle();

      // Ahora debe tocarle el siguiente en la rotación.
      expect(find.text('Toca: Tirón'), findsOneWidget);
    },
  );
}
