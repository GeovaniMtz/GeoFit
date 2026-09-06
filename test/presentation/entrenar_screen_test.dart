import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/presentation/providers/providers.dart';
import 'package:geolift/presentation/screens/entrenar_screen.dart';

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
        overrides: [databaseProvider.overrideWithValue(db)],
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
}
