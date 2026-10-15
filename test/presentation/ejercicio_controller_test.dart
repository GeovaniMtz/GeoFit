import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/domain/progresion_service.dart';
import 'package:geolift/presentation/controllers/ejercicio_controller.dart';
import 'package:geolift/presentation/providers/providers.dart';

import 'entrenar_screen_test.dart' show NotificacionEntrenamientoServiceFake;

/// Tests de la lógica de Entrenar SIN pantalla: antes vivía dentro del
/// widget y solo se podía probar tocando botones.
void main() {
  late AppDatabase db;
  late NotificacionEntrenamientoServiceFake notificaciones;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notificaciones = NotificacionEntrenamientoServiceFake();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(notificaciones),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Press de banca con [series] series de 8–12 y 90 s de descanso, en una
  /// sesión de hoy recién creada.
  Future<ArgsEjercicio> prepararEjercicio({
    int series = 3,
    bool esUltimo = false,
  }) async {
    final catalogo = await db.catalogoDeEjercicios();
    final pressId = catalogo.firstWhere((e) => e.nombre == 'Press de banca').id;
    final rutinaId = await db.crearRutina('Torso');
    final diaId = await db.crearDia(rutinaId, 'Empuje', 0);
    final reId =
        await db.agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
      rutinaDiaId: diaId,
      ejercicioId: pressId,
      seriesObjetivo: Value(series),
      repsMin: const Value(8),
      repsMax: const Value(12),
      descansoSeg: const Value(90),
    ));
    final objetivo =
        (await db.ejerciciosDeDia(diaId)).firstWhere((e) => e.id == reId);
    final sesionId = await db.iniciarSesion(diaId);
    return (
      objetivo: objetivo,
      sesionId: sesionId,
      numeroEjercicio: 1,
      totalEjercicios: esUltimo ? 1 : 2,
      esUltimoEjercicio: esUltimo,
      proximoEjercicioId: null,
    );
  }

  /// Se suscribe al controlador (para que autoDispose no lo destruya) y
  /// espera a que termine de cargar.
  Future<EjercicioController> abrir(ArgsEjercicio args) async {
    final provider = ejercicioControllerProvider(args);
    final sub = container.listen(provider, (_, __) {});
    addTearDown(sub.close);
    while (container.read(provider).cargando) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return container.read(provider.notifier);
  }

  EstadoEjercicio estadoDe(ArgsEjercicio args) =>
      container.read(ejercicioControllerProvider(args));

  test('sin historial arranca en la barra (20 kg) y con el mínimo de reps',
      () async {
    final args = await prepararEjercicio();
    await abrir(args);

    final estado = estadoDe(args);
    expect(estado.nombreEjercicio, 'Press de banca');
    expect(estado.pesoKg, 20);
    expect(estado.reps, 8);
    expect(estado.numeroSet, 1);
    expect(estado.puedeRegistrar, isTrue);
    expect(notificaciones.llamadas.last, contains('serie 1/3'));
  });

  test('los −/+ respetan el paso de la unidad y los límites', () async {
    final args = await prepararEjercicio();
    final c = await abrir(args);

    c.subirPeso();
    expect(estadoDe(args).pesoKg, 22.5);
    for (var i = 0; i < 20; i++) {
      c.bajarPeso();
    }
    expect(estadoDe(args).pesoKg, 0);

    for (var i = 0; i < 20; i++) {
      c.bajarReps();
    }
    expect(estadoDe(args).reps, 1);
    for (var i = 0; i < 60; i++) {
      c.subirReps();
    }
    expect(estadoDe(args).reps, 50);
  });

  test(
      'registrar guarda en la base, avanza la serie, limpia el RPE y arranca '
      'el descanso', () async {
    final args = await prepararEjercicio();
    final c = await abrir(args);
    c.elegirRpe(8);

    final esPr = await c.registrarSerie();

    expect(esPr, isTrue, reason: 'primera serie del ejercicio');
    final estado = estadoDe(args);
    expect(estado.numeroSet, 2);
    expect(estado.rpe, isNull);
    expect(estado.segundosDescanso, 90);
    expect(estado.puedeRegistrar, isFalse);
    expect(estado.registradas.single.rpe, 8);

    final guardado = (await db.setsDeSesion(args.sesionId)).single;
    expect(guardado.peso, 20);
    expect(guardado.rpe, 8);
    expect(guardado.esPr, isTrue);

    // Mientras descansa no se puede registrar otra.
    expect(await c.registrarSerie(), isNull);

    c.saltarDescanso();
    expect(estadoDe(args).descansando, isFalse);
    expect(estadoDe(args).puedeRegistrar, isTrue);
  });

  test('una serie con menos 1RM estimado que el récord no es PR', () async {
    final args = await prepararEjercicio();
    final c = await abrir(args);
    c.subirPeso(); // 22.5 kg
    await c.registrarSerie();
    c.saltarDescanso();

    c.bajarPeso(); // 20 kg, mismas reps: menos que el récord
    expect(await c.registrarSerie(), isFalse);
  });

  test('la última serie celebra en vez de descansar', () async {
    final args = await prepararEjercicio(series: 1, esUltimo: true);
    final c = await abrir(args);

    await c.registrarSerie();

    final estado = estadoDe(args);
    expect(estado.celebrando, isTrue);
    expect(estado.descansando, isFalse);
    expect(estado.seriesCompletas, isTrue);
    // Último ejercicio de la sesión: se retira la notificación.
    await Future<void>.delayed(Duration.zero);
    expect(notificaciones.llamadas.last, 'cancelar');
  });

  test('retoma las series que la sesión ya tenía', () async {
    final args = await prepararEjercicio();
    await db.registrarSet(RegistrosSetCompanion.insert(
      sesionId: args.sesionId,
      rutinaEjercicioId: args.objetivo.id,
      numeroSet: 1,
      peso: 50,
      reps: 10,
    ));

    await abrir(args);

    final estado = estadoDe(args);
    expect(estado.numeroSet, 2);
    expect(estado.registradas.single.pesoKg, 50);
    // Arranca desde el último peso registrado.
    expect(estado.pesoKg, 50);
  });

  test('una sesión anterior al tope con RPE ≤ 8 precarga el peso sugerido',
      () async {
    final args = await prepararEjercicio();
    final ayer = await db.into(db.sesionesEntrenamiento).insert(
          SesionesEntrenamientoCompanion.insert(
            rutinaDiaId: args.objetivo.rutinaDiaId,
            fecha: Value(DateTime.now().subtract(const Duration(days: 1))),
          ),
        );
    for (var i = 1; i <= 3; i++) {
      await db.registrarSet(RegistrosSetCompanion.insert(
        sesionId: ayer,
        rutinaEjercicioId: args.objetivo.id,
        numeroSet: i,
        peso: 60,
        reps: 12,
        rpe: const Value(7),
      ));
    }

    await abrir(args);

    final estado = estadoDe(args);
    expect(estado.sugerencia?.tipo, TipoSugerencia.subirPeso);
    expect(estado.pesoKg, 62.5);
    expect(estado.referencia?.registro.peso, 60);
  });
}
