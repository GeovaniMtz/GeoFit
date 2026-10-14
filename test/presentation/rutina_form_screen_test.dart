import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/rutina_form_screen.dart';
import 'package:geolift/presentation/widgets/rutina_form/borrador.dart';

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

      await tester.tap(find.byTooltip('Eliminar rutina'));
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

  testWidgets(
    'editar el nombre de un ejercicio existente lo corrige también en el '
    'catálogo, sin perder el historial ya registrado con él',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // La base ya trae "Press militar" en el catálogo semilla.
      final catalogoInicial = await db.catalogoDeEjercicios();
      final pressMilitarId =
          catalogoInicial.firstWhere((e) => e.nombre == 'Press militar').id;

      final rutinaId = await db.crearRutina('Empuje');
      final diaId = await db.crearDia(rutinaId, 'Día 1', 0);
      final rutinaEjercicioId =
          await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pressMilitarId,
        seriesObjetivo: const Value(4),
        repsMin: const Value(6),
        repsMax: const Value(10),
        descansoSeg: const Value(90),
      ));
      // Historial ya registrado bajo "Press militar", que debe seguir
      // intacto (mismo id) después de la corrección de nombre.
      final sesionId = await db.iniciarSesion(diaId);
      await db.registrarSet(RegistrosSetCompanion.insert(
        sesionId: sesionId,
        rutinaEjercicioId: rutinaEjercicioId,
        numeroSet: 1,
        peso: 40,
        reps: 8,
      ));

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: RutinaFormScreen(rutinaId: rutinaId)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Press militar'), findsOneWidget);

      // Se edita el ejercicio corrigiendo su nombre.
      await tester.tap(find.text('Press militar'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Press militar'), 'Press inclinado');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GUARDAR RUTINA'));
      await tester.pumpAndSettle();

      // El día sigue teniendo el mismo ejercicio (mismo id de catálogo),
      // ahora con el nombre corregido.
      final ejerciciosDelDia = await db.ejerciciosDeDiaConNombre(diaId);
      expect(ejerciciosDelDia, hasLength(1));
      expect(ejerciciosDelDia.single.nombreEjercicio, 'Press inclinado');
      expect(
          ejerciciosDelDia.single.rutinaEjercicio.ejercicioId, pressMilitarId);

      // No quedó un "Press militar" separado ni se creó un ejercicio
      // duplicado en el catálogo: se corrigió en su lugar.
      final catalogoFinal = await db.catalogoDeEjercicios();
      expect(catalogoFinal.where((e) => e.nombre == 'Press militar'),
          isEmpty);
      expect(
        catalogoFinal.where((e) => e.nombre == 'Press inclinado'),
        hasLength(1),
      );

      // El set registrado antes de corregir el nombre se conserva, y ahora
      // se muestra bajo el nombre correcto.
      final historial = await db.historialPorEjercicio(pressMilitarId);
      expect(historial, hasLength(1));
      expect(historial.single.registro.peso, 40);
    },
  );

  testWidgets(
    'con diasIniciales (importación) llega prellenado y ya marcado como '
    'sin guardar',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final diaImportado = DiaBorrador()..controladorNombre.text = 'Pecho';
      diaImportado.ejercicios.add(EjercicioBorrador(
        nombreEjercicio: 'Press banca',
        seriesObjetivo: 4,
        repsMin: 8,
        repsMax: 12,
        descansoSeg: 80,
      ));

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RutinaFormScreen(diasIniciales: [diaImportado]),
                    ),
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

      // Los datos importados ya están ahí sin que el usuario haya tocado
      // nada.
      expect(find.text('Pecho'), findsOneWidget);
      expect(find.text('Press banca'), findsOneWidget);

      // Es contenido real sin guardar: el botón de regresar ya pide
      // confirmar de inmediato, sin necesidad de editar nada primero.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar cambios?'), findsOneWidget);
    },
  );
}
