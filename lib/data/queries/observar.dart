import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas reactivas: en vez de que cada pantalla tenga que acordarse de
/// refrescar los datos que otra pantalla acaba de cambiar (y mostrar datos
/// viejos cuando se le olvida), las pantallas se suscriben a un stream que
/// vuelve a correr la consulta sola cada vez que cambia alguna de sus
/// tablas.
extension Observar on AppDatabase {
  /// Emite el resultado de [consulta] de inmediato y lo vuelve a emitir
  /// cada vez que Drift registra un cambio en cualquiera de [tablas].
  ///
  /// Se reutilizan las consultas `Future` que ya existen (algunas hacen
  /// varios queries y procesan en Dart, así que `.watch()` de Drift no les
  /// alcanza). [tablas] debe incluir TODAS las tablas que lee la consulta;
  /// si falta una, sus cambios no se reflejan.
  ///
  /// Drift avisa de los cambios hechos con sus APIs (insert/update/delete,
  /// transacciones). Lo que se escriba con `customStatement` debe avisar
  /// a mano con `notifyUpdates` (ver `restaurarDesde`).
  Stream<T> observar<T>(
    Iterable<TableInfo> tablas,
    Future<T> Function() consulta,
  ) async* {
    yield await consulta();
    await for (final _
        in tableUpdates(TableUpdateQuery.onAllTables(tablas.toList()))) {
      yield await consulta();
    }
  }
}
