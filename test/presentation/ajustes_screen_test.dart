import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/main.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets(
    'elegir un tema en Ajustes cambia el brillo de la app y lo persiste',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const GeoLiftApp(),
      ));
      await tester.pumpAndSettle();

      // Por defecto sigue al sistema.
      var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);

      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      expect(find.text('APARIENCIA'), findsOneWidget);

      await tester.tap(find.byTooltip('Claro'));
      await tester.pumpAndSettle();

      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
      expect(
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
          Brightness.light);
      expect((await db.obtenerConfiguracion()).tema, 'claro');

      await tester.tap(find.byTooltip('Oscuro'));
      await tester.pumpAndSettle();

      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
          Brightness.dark);
      expect((await db.obtenerConfiguracion()).tema, 'oscuro');

      await tester.tap(find.byTooltip('Sistema'));
      await tester.pumpAndSettle();

      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
      expect((await db.obtenerConfiguracion()).tema, 'sistema');
    },
  );
}
