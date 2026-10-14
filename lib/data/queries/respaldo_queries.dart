import 'package:drift/drift.dart';

import '../database.dart';

/// El archivo elegido no se puede restaurar. [mensaje] ya viene listo para
/// mostrarse al usuario.
class RespaldoInvalido implements Exception {
  final String mensaje;
  const RespaldoInvalido(this.mensaje);

  @override
  String toString() => 'RespaldoInvalido: $mensaje';
}

/// Respaldo y restauración de toda la base (tablas de este esquema).
extension RespaldoQueries on AppDatabase {
  /// Escribe una copia completa y consistente de la base en [ruta]. Usa
  /// `VACUUM INTO`, que toma una instantánea aunque la app tenga la base
  /// abierta — copiar el archivo `.sqlite` a mano podría dejar fuera
  /// escrituras que todavía no llegan a disco. [ruta] no debe existir.
  Future<void> exportarA(String ruta) =>
      customStatement('VACUUM INTO ?', [ruta]);

  /// Reemplaza TODOS los datos actuales por los del respaldo en [ruta].
  ///
  /// Se adjunta el respaldo y se copia tabla por tabla dentro de una sola
  /// transacción: si algo falla a medio camino no se pierde nada. Solo se
  /// copian las columnas que existen en ambos lados, así un respaldo de una
  /// versión anterior (con menos columnas) también se puede restaurar — las
  /// columnas nuevas quedan con su valor por defecto.
  ///
  /// Lanza [RespaldoInvalido] si el archivo no es un respaldo de GeoLift o
  /// viene de una versión más nueva de la app.
  Future<void> restaurarDesde(String ruta) async {
    try {
      await customStatement('ATTACH DATABASE ? AS respaldo', [ruta]);
    } catch (_) {
      throw const RespaldoInvalido('No se pudo abrir el archivo.');
    }

    try {
      await _validarRespaldo();
      await transaction(() async {
        for (final tabla in allTables) {
          final nombre = tabla.actualTableName;
          final columnas = await _columnasComunes(nombre);
          await customStatement('DELETE FROM main."$nombre"');
          if (columnas.isEmpty) continue;
          final lista = columnas.map((c) => '"$c"').join(', ');
          await customStatement(
            'INSERT INTO main."$nombre" ($lista) '
            'SELECT $lista FROM respaldo."$nombre"',
          );
        }
      });
      // Las pantallas leen por streams/consultas de Drift: se avisa que
      // cambió todo para que nada se quede con datos viejos en caché.
      notifyUpdates({
        for (final tabla in allTables) TableUpdate.onTable(tabla),
      });
    } finally {
      await customStatement('DETACH DATABASE respaldo');
    }
  }

  Future<void> _validarRespaldo() async {
    final List<String> tablas;
    try {
      tablas = (await customSelect(
        "SELECT name FROM respaldo.sqlite_master WHERE type = 'table'",
      ).get())
          .map((f) => f.read<String>('name'))
          .toList();
    } catch (_) {
      // SQLite solo se da cuenta de que no es una base al leerla.
      throw const RespaldoInvalido('El archivo no es un respaldo de GeoLift.');
    }

    final esperadas = allTables.map((t) => t.actualTableName);
    if (!esperadas.every(tablas.contains)) {
      throw const RespaldoInvalido('El archivo no es un respaldo de GeoLift.');
    }

    final version =
        (await customSelect('PRAGMA respaldo.user_version').getSingle())
            .read<int>('user_version');
    if (version > schemaVersion) {
      throw const RespaldoInvalido(
        'El respaldo es de una versión más nueva de GeoLift. Actualiza la '
        'app antes de restaurarlo.',
      );
    }
  }

  Future<List<String>> _columnasComunes(String tabla) async {
    Future<Set<String>> columnas(String esquema) async =>
        (await customSelect('PRAGMA $esquema.table_info("$tabla")').get())
            .map((f) => f.read<String>('name'))
            .toSet();

    final enMain = await columnas('main');
    final enRespaldo = await columnas('respaldo');
    return enMain.where(enRespaldo.contains).toList();
  }
}
