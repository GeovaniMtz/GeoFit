import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/progresion_service.dart';

/// Base de datos local, viva durante toda la vida de la app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final progresionServiceProvider = Provider<ProgresionService>((ref) {
  return ProgresionService();
});

// ---- Rutinas ---------------------------------------------------------------

final rutinasActivasProvider = FutureProvider<List<Rutina>>((ref) {
  return ref.watch(databaseProvider).rutinasActivas();
});

final diasDeRutinaProvider =
    FutureProvider.family<List<RutinaDia>, int>((ref, rutinaId) {
  return ref.watch(databaseProvider).diasDeRutina(rutinaId);
});

final ultimoDiaEntrenadoProvider =
    FutureProvider.family<RutinaDia?, int>((ref, rutinaId) {
  return ref.watch(databaseProvider).ultimoDiaEntrenado(rutinaId);
});

final ejerciciosDeDiaProvider =
    FutureProvider.family<List<RutinaEjercicio>, int>((ref, rutinaDiaId) {
  return ref.watch(databaseProvider).ejerciciosDeDia(rutinaDiaId);
});

final catalogoDeEjerciciosProvider = FutureProvider<List<Ejercicio>>((ref) {
  return ref.watch(databaseProvider).catalogoDeEjercicios();
});

final ejerciciosEnUsoProvider = FutureProvider<List<Ejercicio>>((ref) {
  return ref.watch(databaseProvider).ejerciciosEnUso();
});

// ---- Progreso / historial ---------------------------------------------------

final historialPorEjercicioProvider =
    FutureProvider.family<List<RegistroConFecha>, int>((ref, ejercicioId) {
  return ref.watch(databaseProvider).historialPorEjercicio(ejercicioId);
});

final historialDeSesionesProvider = FutureProvider<List<SesionResumen>>((ref) {
  return ref.watch(databaseProvider).historialDeSesiones();
});

final historialPesoCorporalProvider =
    FutureProvider<List<RegistrosPesoCorporalData>>((ref) {
  return ref.watch(databaseProvider).historialPesoCorporal();
});

// ---- Configuración -----------------------------------------------------

final configuracionProvider = FutureProvider<ConfiguracionData>((ref) {
  return ref.watch(databaseProvider).obtenerConfiguracion();
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
