import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/core/notification_service.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/entrenar_screen.dart';

/// Sustituto sin plugin real de [NotificacionEntrenamientoService]: registra
/// las llamadas para poder revisarlas en los asserts, sin tocar canales de
/// notificación de verdad (que no existen en el entorno de test de
/// widgets).
class NotificacionEntrenamientoServiceFake
    extends NotificacionEntrenamientoService {
  final List<String> llamadas = [];

  @override
  Future<void> solicitarPermiso() async {
    llamadas.add('solicitarPermiso');
  }

  @override
  Future<void> mostrarProgreso({
    required int rutinaDiaId,
    required String nombreEjercicio,
    required int numeroEjercicio,
    required int totalEjercicios,
    required int numeroSet,
    required int totalSets,
  }) async {
    llamadas.add('mostrarProgreso($nombreEjercicio, ejercicio '
        '$numeroEjercicio/$totalEjercicios, serie $numeroSet/$totalSets)');
  }

  @override
  Future<void> cancelar() async {
    llamadas.add('cancelar');
  }
}

void main() {
  testWidgets(
    'registrar una serie refresca el historial y la rotación aunque ya '
    'estaban leídos antes (así los mantiene vivos el IndexedStack de '
    'MainShell)',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final catalogo = await db.catalogoDeEjercicios();
      final pressBancaId =
          catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
      final rutinaId = await db.crearRutina('Push Pull Legs');
      final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pressBancaId,
        seriesObjetivo: const Value(3),
      ));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider
              .overrideWithValue(NotificacionEntrenamientoServiceFake()),
        ],
      );
      addTearDown(container.dispose);

      // Se leen los providers ANTES de entrenar, tal como pasa con
      // Historial y Rutinas dentro del IndexedStack de MainShell (se
      // construyen y quedan vivos desde que abres la app).
      final historialAntes =
          await container.read(historialDeSesionesProvider.future);
      final diaAntes =
          await container.read(ultimoDiaEntrenadoProvider(rutinaId).future);
      expect(historialAntes, isEmpty);
      expect(diaAntes, isNull);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();

      final historialDespues =
          await container.read(historialDeSesionesProvider.future);
      final diaDespues =
          await container.read(ultimoDiaEntrenadoProvider(rutinaId).future);

      expect(historialDespues, hasLength(1));
      expect(diaDespues?.id, diaId);
    },
  );

  testWidgets(
    'muestra el nombre del siguiente ejercicio mientras se entrena el '
    'actual',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final catalogo = await db.catalogoDeEjercicios();
      final pressBancaId =
          catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
      final sentadillaId =
          catalogo.firstWhere((e) => e.nombre == 'Sentadilla').id;
      final rutinaId = await db.crearRutina('Push Pull Legs');
      final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pressBancaId,
        orden: const Value(0),
        seriesObjetivo: const Value(1),
      ));
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: sentadillaId,
        orden: const Value(1),
        seriesObjetivo: const Value(1),
      ));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider
              .overrideWithValue(NotificacionEntrenamientoServiceFake()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Próximo ejercicio: Sentadilla'), findsOneWidget);

      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SIGUIENTE EJERCICIO'));
      await tester.pumpAndSettle();

      // En el último ejercicio ya no hay "próximo" que mostrar.
      expect(find.textContaining('Próximo ejercicio:'), findsNothing);
    },
  );

  testWidgets(
    'salir de Entrenar a mitad de la rutina y volver a entrar retoma en el '
    'mismo ejercicio en vez de reiniciar desde el primero',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final catalogo = await db.catalogoDeEjercicios();
      final pressBancaId =
          catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
      final sentadillaId =
          catalogo.firstWhere((e) => e.nombre == 'Sentadilla').id;
      final pesoMuertoId =
          catalogo.firstWhere((e) => e.nombre == 'Peso muerto').id;
      final rutinaId = await db.crearRutina('Full body');
      final diaId = await db.crearDia(rutinaId, 'Día 1', 0);
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pressBancaId,
        orden: const Value(0),
        seriesObjetivo: const Value(1),
      ));
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: sentadillaId,
        orden: const Value(1),
        seriesObjetivo: const Value(1),
      ));
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pesoMuertoId,
        orden: const Value(2),
        seriesObjetivo: const Value(1),
      ));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider
              .overrideWithValue(NotificacionEntrenamientoServiceFake()),
        ],
      );
      addTearDown(container.dispose);

      // Primera entrada: completa el primer ejercicio y avanza al segundo
      // (el de en medio, "Sentadilla"), luego "sale" (el widget se
      // desmonta, como pasaría al navegar hacia atrás).
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Ejercicio 1 de 3'), findsOneWidget);

      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SIGUIENTE EJERCICIO'));
      await tester.pumpAndSettle();
      expect(find.text('Ejercicio 2 de 3'), findsOneWidget);

      // "Sale" de Entrenar reemplazando el árbol de widgets por uno vacío,
      // y "vuelve a entrar" con una instancia nueva de EntrenarScreen.
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox.shrink()),
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      // Debe retomar en "Sentadilla" (ejercicio 2), no reiniciar en el 1.
      expect(find.text('Ejercicio 2 de 3'), findsOneWidget);

      // Y sigue siendo la misma sesión: solo hay un set registrado en total
      // (el de Press de banca de antes de salir), no dos sesiones distintas.
      final sesiones = await db.historialDeSesiones();
      expect(sesiones, hasLength(1));
      expect(sesiones.single.totalSets, 1);
    },
  );

  testWidgets(
    'muestra y actualiza la notificación de progreso mientras se entrena, y '
    'la cancela al completar la sesión y al salir de la pantalla',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final catalogo = await db.catalogoDeEjercicios();
      final pressBancaId =
          catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
      final rutinaId = await db.crearRutina('Push Pull Legs');
      final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
      await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
        rutinaDiaId: diaId,
        ejercicioId: pressBancaId,
        orden: const Value(0),
        seriesObjetivo: const Value(1),
      ));

      final notificaciones = NotificacionEntrenamientoServiceFake();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(notificaciones),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: EntrenarScreen(rutinaDiaId: diaId)),
      ));
      await tester.pumpAndSettle();

      expect(notificaciones.llamadas, contains('solicitarPermiso'));
      expect(
        notificaciones.llamadas
            .where((l) => l.startsWith('mostrarProgreso'))
            .last,
        contains('serie 1/1'),
      );

      await tester.tap(find.text('REGISTRAR SERIE'));
      await tester.pumpAndSettle();

      // Único ejercicio de la rutina: al registrar su única serie, la
      // sesión se completa y la notificación se retira.
      expect(notificaciones.llamadas.last, 'cancelar');

      // Salir de la pantalla (desmontarla) cancela de nuevo — sin
      // problema, cancelar() es idempotente.
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox.shrink()),
      ));
      await tester.pumpAndSettle();
      expect(notificaciones.llamadas.last, 'cancelar');
    },
  );
}
