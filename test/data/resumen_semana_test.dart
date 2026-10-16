import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';

void main() {
  test(
      'resume la semana (lunes a domingo) y compara el volumen con la '
      'anterior; las sesiones sin series no cuentan', () async {
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

    Future<int> sesion(DateTime fecha, {int? duracion}) =>
        db.into(db.sesionesEntrenamiento).insert(
              SesionesEntrenamientoCompanion.insert(
                rutinaDiaId: diaId,
                fecha: Value(fecha),
                duracionSeg: Value(duracion),
              ),
            );
    Future<void> serie(int sesionId, double peso, int reps,
            {bool pr = false}) =>
        db.registrarSet(RegistrosSetCompanion.insert(
          sesionId: sesionId,
          rutinaEjercicioId: re,
          numeroSet: 1,
          peso: peso,
          reps: reps,
          esPr: Value(pr),
        ));

    // "Hoy" es el jueves 15 de octubre de 2026: la semana va del lunes 12
    // al domingo 18.
    final ahora = DateTime(2026, 10, 15, 20);

    final lunes = await sesion(DateTime(2026, 10, 12, 18), duracion: 3000);
    await serie(lunes, 100, 5, pr: true);
    await serie(lunes, 100, 5);
    final miercoles = await sesion(DateTime(2026, 10, 14, 7), duracion: 1800);
    await serie(miercoles, 60, 10);
    // Se abrió "Entrenar" pero no se registró nada: no cuenta.
    await sesion(DateTime(2026, 10, 15, 9));
    // Semana pasada (domingo 11): solo cuenta para comparar volumen.
    final anterior = await sesion(DateTime(2026, 10, 11, 10), duracion: 900);
    await serie(anterior, 50, 10);

    final r = await db.resumenSemana(ahora);

    expect(r.inicio, DateTime(2026, 10, 12));
    expect(r.sesiones, 2);
    expect(r.diasEntrenados, {DateTime.monday, DateTime.wednesday});
    expect(r.series, 3);
    expect(r.prs, 1);
    expect(r.volumenKg, 100 * 5 + 100 * 5 + 60 * 10);
    expect(r.volumenSemanaAnteriorKg, 50 * 10);
    expect(r.segundos, 3000 + 1800);
  });
}
