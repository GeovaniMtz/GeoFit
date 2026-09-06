import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre las preferencias del usuario (tabla `Configuracion`).
extension ConfiguracionQueries on AppDatabase {
  Future<ConfiguracionData> obtenerConfiguracion() async {
    final existente = await select(configuracion).getSingleOrNull();
    if (existente != null) return existente;
    final id =
        await into(configuracion).insert(const ConfiguracionCompanion());
    return (await (select(configuracion)..where((c) => c.id.equals(id)))
        .getSingle());
  }

  /// Guarda el tema elegido por el usuario ('sistema' | 'claro' | 'oscuro').
  Future<void> actualizarTema(String tema) async {
    final config = await obtenerConfiguracion();
    await (update(configuracion)..where((c) => c.id.equals(config.id)))
        .write(ConfiguracionCompanion(tema: Value(tema)));
  }
}
