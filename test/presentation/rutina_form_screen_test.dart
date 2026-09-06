import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/rutina_form_screen.dart';

void main() {
  testWidgets(
    'el lápiz de editar carga la rutina existente y la actualiza en vez '
    'de crear una nueva',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final ejercicioId = await db.crearEjercicio(EjerciciosCompanion.insert(
        nombre: 'Sentadilla',
        grupoMuscular: 'Pierna',
      ));
      final rutinaId = await db.crearRutina('Piernas');
      final diaId = await db.crearDia(rutinaId, 'Día 1', 0);
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: ejercicioId,
        seriesObjetivo: const Value(4),
        repsMin: const Value(6),
        repsMax: const Value(10),
        descansoSeg: const Value(80),
      ));

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: RutinaFormScreen(rutinaId: rutinaId)),
      ));
      await tester.pumpAndSettle();

      // El formulario debe mostrarse en modo edición y con los datos de la
      // rutina ya guardada, no en blanco como "Nueva rutina".
      expect(find.text('Editar rutina'), findsOneWidget);
      expect(find.text('Nueva rutina'), findsNothing);
      expect(find.text('Piernas'), findsOneWidget);
      expect(find.text('Sentadilla'), findsOneWidget);
      expect(find.textContaining('80s descanso'), findsOneWidget);

      // Se edita el nombre y se guarda.
      await tester.enterText(
          find.widgetWithText(TextField, 'Piernas'), 'Piernas y Glúteos');
      await tester.tap(find.text('GUARDAR RUTINA'));
      await tester.pumpAndSettle();

      // No debe haberse creado una rutina duplicada: la misma fila se
      // actualizó en su lugar.
      final rutinas = await db.rutinasActivas();
      expect(rutinas.length, 1);
      expect(rutinas.single.id, rutinaId);
      expect(rutinas.single.nombre, 'Piernas y Glúteos');

      final dias = await db.diasDeRutina(rutinaId);
      expect(dias.length, 1);
      expect(dias.single.id, diaId);

      final ejercicios = await db.ejerciciosDeDia(diaId);
      expect(ejercicios.length, 1);
    },
  );

  testWidgets(
    'eliminar rutina la archiva (no borra sus datos) y deja de listarse '
    'como activa',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final rutinaId = await db.crearRutina('Piernas');
      final diaId = await db.crearDia(rutinaId, 'Día 1', 0);
      final sesionId = await db.iniciarSesion(diaId);

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: RutinaFormScreen(rutinaId: rutinaId)),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ELIMINAR RUTINA'));
      await tester.pumpAndSettle();

      // Pide confirmación antes de archivarla.
      expect(find.text('¿Eliminar esta rutina?'), findsOneWidget);

      await tester.tap(find.text('ELIMINAR'));
      await tester.pumpAndSettle();

      // Ya no aparece entre las rutinas activas...
      final activas = await db.rutinasActivas();
      expect(activas, isEmpty);
      final rutina = await db.obtenerRutina(rutinaId);
      expect(rutina.activa, isFalse);

      // ...pero sus días y su historial siguen intactos para las gráficas.
      final dias = await db.diasDeRutina(rutinaId);
      expect(dias, hasLength(1));
      final sesiones = await db.historialDeSesiones();
      expect(sesiones.map((s) => s.sesion.id), contains(sesionId));
    },
  );

  testWidgets(
    'con cambios sin guardar, pide confirmar antes de salir con el botón '
    'de regresar',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RutinaFormScreen()),
                  ),
                  child: const Text('abrir formulario'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('abrir formulario'));
      await tester.pumpAndSettle();

      // Se escribe un nombre (cambio sin guardar) y se intenta regresar. Se
      // hace un pump aparte para que el rebuild que marca "sucio" ya haya
      // corrido antes del tap (como pasaría de verdad entre dos toques
      // separados del usuario).
      await tester.enterText(
          find.widgetWithText(TextField, 'Nombre de la rutina'), 'Piernas');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // No debe haber salido todavía: aparece la confirmación y el
      // formulario sigue ahí.
      expect(find.text('¿Descartar cambios?'), findsOneWidget);
      expect(find.text('Nueva rutina'), findsOneWidget);

      // "Seguir editando" cierra el diálogo sin salir del formulario.
      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Nueva rutina'), findsOneWidget);
      expect(find.text('Piernas'), findsOneWidget);

      // Al reintentar y confirmar, ahora sí se sale.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DESCARTAR'));
      await tester.pumpAndSettle();

      expect(find.text('abrir formulario'), findsOneWidget);
      expect(find.text('Nueva rutina'), findsNothing);

      // Nada se guardó: seguimos sin rutinas en la base.
      expect(await db.rutinasActivas(), isEmpty);
    },
  );
}
