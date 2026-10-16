import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/escaner_rutina_service.dart';
import '../../core/notification_service.dart';
import '../../core/respaldo_automatico.dart';
import '../../core/respaldo_service.dart';
import '../../data/database.dart';
import '../../data/repositories/entrenamiento_repository.dart';
import '../../domain/progresion_service.dart';
import '../../domain/unidad_peso.dart';

export '../../domain/unidad_peso.dart';

/// Base de datos local, viva durante toda la vida de la app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final progresionServiceProvider = Provider<ProgresionService>((ref) {
  return ProgresionService();
});

/// Notificaciones locales de progreso de entrenamiento — una instancia viva
/// durante toda la app, igual que [databaseProvider].
final notificationServiceProvider =
    Provider<NotificacionEntrenamientoService>((ref) {
  return NotificacionEntrenamientoService();
});

/// Reconocimiento de texto (OCR) para escanear una rutina con la cámara —
/// una instancia viva durante toda la app, igual que
/// [notificationServiceProvider].
final escanerRutinaServiceProvider = Provider<EscanerRutinaService>((ref) {
  final servicio = EscanerRutinaService();
  ref.onDispose(servicio.cerrar);
  return servicio;
});

final entrenamientoRepositoryProvider =
    Provider<EntrenamientoRepository>((ref) {
  return EntrenamientoRepository(ref.watch(databaseProvider));
});

final respaldoServiceProvider = Provider<RespaldoService>((ref) {
  return RespaldoService();
});

/// Respaldo semanal automático (ver [RespaldoAutomatico]); la carpeta se
/// resuelve una sola vez.
final respaldoAutomaticoProvider =
    FutureProvider<RespaldoAutomatico>((ref) async {
  return RespaldoAutomatico(await carpetaRespaldoAutomatico());
});

/// Fecha del último respaldo automático (null si nunca se ha hecho) y la
/// carpeta donde se guardan, para mostrarlo en Ajustes.
final estadoRespaldoAutomaticoProvider =
    FutureProvider<({DateTime? ultimo, String carpeta})>((ref) async {
  final auto = await ref.watch(respaldoAutomaticoProvider.future);
  return (ultimo: await auto.ultimo(), carpeta: auto.carpeta.path);
});

/// Vuelve a leer de la base las preferencias (tema y unidad de peso). Se
/// usa tras restaurar un respaldo: los datos se refrescan solos (los
/// providers son reactivos), pero los controladores de preferencias solo
/// leen la base al crearse.
void recargarPreferencias(WidgetRef ref) {
  ref
    ..invalidate(temaControllerProvider)
    ..invalidate(unidadPesoProvider);
}

// ---- Rutinas ---------------------------------------------------------------

// Todos los providers de datos son reactivos (ver [Observar.observar]): se
// actualizan solos cuando cambia alguna de las tablas que leen, así que
// después de guardar algo NO hace falta invalidarlos a mano. Cada uno lista
// las tablas que lee su consulta; si una consulta empieza a leer otra
// tabla, hay que agregarla aquí.

final rutinasActivasProvider = StreamProvider<List<Rutina>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar([db.rutinas], db.rutinasActivas);
});

final diasDeRutinaProvider =
    StreamProvider.family<List<RutinaDia>, int>((ref, rutinaId) {
  final db = ref.watch(databaseProvider);
  return db.observar([db.rutinaDias], () => db.diasDeRutina(rutinaId));
});

final ultimoDiaEntrenadoProvider =
    StreamProvider.family<RutinaDia?, int>((ref, rutinaId) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.sesionesEntrenamiento, db.rutinaDias],
    () => db.ultimoDiaEntrenado(rutinaId),
  );
});

final ejerciciosDeDiaProvider =
    StreamProvider.family<List<RutinaEjercicio>, int>((ref, rutinaDiaId) {
  final db = ref.watch(databaseProvider);
  return db
      .observar([db.rutinaEjercicios], () => db.ejerciciosDeDia(rutinaDiaId));
});

final catalogoDeEjerciciosProvider = StreamProvider<List<Ejercicio>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar([db.ejercicios], db.catalogoDeEjercicios);
});

final ejerciciosEnUsoProvider = StreamProvider<List<Ejercicio>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.ejercicios, db.rutinaEjercicios, db.rutinaDias, db.rutinas],
    db.ejerciciosEnUso,
  );
});

// ---- Progreso / historial ---------------------------------------------------

final historialPorEjercicioProvider =
    StreamProvider.family<List<RegistroConFecha>, int>((ref, ejercicioId) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.registrosSet, db.rutinaEjercicios, db.sesionesEntrenamiento],
    () => db.historialPorEjercicio(ejercicioId),
  );
});

final historialDeSesionesProvider = StreamProvider<List<SesionResumen>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.sesionesEntrenamiento, db.rutinaDias, db.registrosSet],
    db.historialDeSesiones,
  );
});

/// Lo entrenado esta semana (lunes a domingo) para el anillo de Inicio.
final resumenSemanaProvider = StreamProvider<ResumenSemana>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.sesionesEntrenamiento, db.registrosSet],
    () => db.resumenSemana(DateTime.now()),
  );
});

/// Sesiones por semana que el usuario se propone entrenar.
final metaSesionesSemanaProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [db.configuracion],
    () async => (await db.obtenerConfiguracion()).metaSesionesSemana,
  );
});

final detalleSesionProvider =
    StreamProvider.family<DetalleSesion?, int>((ref, sesionId) {
  final db = ref.watch(databaseProvider);
  return db.observar(
    [
      db.sesionesEntrenamiento,
      db.rutinaDias,
      db.registrosSet,
      db.rutinaEjercicios,
      db.ejercicios,
    ],
    () => db.detalleDeSesion(sesionId),
  );
});

final historialPesoCorporalProvider =
    StreamProvider<List<RegistrosPesoCorporalData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.observar([db.registrosPesoCorporal], db.historialPesoCorporal);
});

/// Preferencia de tema del usuario, tal como se guarda en la tabla
/// `Configuracion` ('sistema' | 'claro' | 'oscuro').
enum TemaApp {
  sistema,
  claro,
  oscuro;

  static TemaApp desdeTexto(String valor) => switch (valor) {
        'claro' => TemaApp.claro,
        'oscuro' => TemaApp.oscuro,
        _ => TemaApp.sistema,
      };

  String get texto => switch (this) {
        TemaApp.claro => 'claro',
        TemaApp.oscuro => 'oscuro',
        TemaApp.sistema => 'sistema',
      };

  ThemeMode get modo => switch (this) {
        TemaApp.claro => ThemeMode.light,
        TemaApp.oscuro => ThemeMode.dark,
        TemaApp.sistema => ThemeMode.system,
      };
}

/// Controla y persiste el tema elegido en `Configuracion.tema`.
class TemaController extends StateNotifier<TemaApp> {
  TemaController(this._db) : super(TemaApp.sistema) {
    _cargar();
  }

  final AppDatabase _db;

  Future<void> _cargar() async {
    final config = await _db.obtenerConfiguracion();
    state = TemaApp.desdeTexto(config.tema);
  }

  Future<void> cambiarTema(TemaApp tema) async {
    state = tema;
    await _db.actualizarTema(tema.texto);
  }
}

final temaControllerProvider =
    StateNotifierProvider<TemaController, TemaApp>((ref) {
  return TemaController(ref.watch(databaseProvider));
});

/// Controla y persiste la unidad de peso en `Configuracion.unidadPeso`.
/// Solo afecta cómo se muestran y capturan los pesos — lo guardado siempre
/// está en kg (ver [UnidadPeso]).
class UnidadPesoController extends StateNotifier<UnidadPeso> {
  UnidadPesoController(this._db) : super(UnidadPeso.kg) {
    _cargar();
  }

  final AppDatabase _db;

  // Si el usuario elige una unidad antes de que termine la carga inicial,
  // esa lectura (ya vieja) no debe pisar su elección.
  bool _elegidaPorUsuario = false;

  Future<void> _cargar() async {
    final config = await _db.obtenerConfiguracion();
    if (mounted && !_elegidaPorUsuario) {
      state = UnidadPeso.desdeTexto(config.unidadPeso);
    }
  }

  Future<void> cambiarUnidad(UnidadPeso unidad) async {
    _elegidaPorUsuario = true;
    state = unidad;
    await _db.actualizarUnidadPeso(unidad.texto);
  }
}

final unidadPesoProvider =
    StateNotifierProvider<UnidadPesoController, UnidadPeso>((ref) {
  return UnidadPesoController(ref.watch(databaseProvider));
});
