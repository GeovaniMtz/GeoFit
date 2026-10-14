import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/importar_rutina_screen.dart';

void main() {
  testWidgets(
    'analizar muestra el preview con procedencia de cada ejercicio y '
    'habilita Continuar cuando detectó algo',
    (tester) async {
      // La pantalla tiene bastante contenido (instrucciones, texto de
      // ejemplo, preview) y en el tamaño de prueba por defecto el botón
      // "Continuar" queda fuera del extent que el ListView llega a montar
      // sin hacer scroll; se agranda el viewport para que todo se
      // construya sin depender de scrollear.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.crearEjercicio(EjerciciosCompanion.insert(
        nombre: 'Press banca',
        grupoMuscular: 'Pecho',
      ));

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ImportarRutinaScreen()),
      ));
      await tester.pumpAndSettle();

      // Antes de analizar no hay preview ni botón de continuar.
      expect(find.text('CONTINUAR'), findsNothing);

      await tester.enterText(
        find.byType(TextField).first,
        'Día 1: Pecho\n'
        'Press banca 4x8-12\n'
        'Aperturas 3x12-15\n',
      );
      await tester.tap(find.text('ANALIZAR'));
      await tester.pumpAndSettle();

      // Un día, dos ejercicios detectados.
      expect(find.text('1 días, 2 ejercicios detectados'), findsOneWidget);

      // "Press banca" ya existía en el catálogo (creado arriba) y debe
      // mostrarse como coincidencia, no como ejercicio nuevo.
      expect(
        find.textContaining('Coincide con: Press banca'),
        findsOneWidget,
      );
      // "Aperturas" no existe en el catálogo: debe marcarse como nuevo.
      expect(find.textContaining('Ejercicio nuevo'), findsOneWidget);

      final continuar = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'CONTINUAR'),
      );
      expect(continuar.onPressed, isNotNull);
    },
  );

  testWidgets(
    'un texto sin ejercicios detectables deja Continuar deshabilitado',
    (tester) async {
      // La pantalla tiene bastante contenido (instrucciones, texto de
      // ejemplo, preview) y en el tamaño de prueba por defecto el botón
      // "Continuar" queda fuera del extent que el ListView llega a montar
      // sin hacer scroll; se agranda el viewport para que todo se
      // construya sin depender de scrollear.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ImportarRutinaScreen()),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Esto no tiene ningún ejercicio reconocible',
      );
      await tester.tap(find.text('ANALIZAR'));
      await tester.pumpAndSettle();

      expect(find.text('0 días, 0 ejercicios detectados'), findsOneWidget);
      // La línea suelta se reporta como no reconocida, no se pierde.
      expect(find.text('1 líneas no reconocidas'), findsOneWidget);

      final continuar = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'CONTINUAR'),
      );
      expect(continuar.onPressed, isNull);
    },
  );
}
