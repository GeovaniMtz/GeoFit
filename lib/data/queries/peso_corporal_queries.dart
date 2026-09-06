import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre el historial de peso corporal (tabla
/// `RegistrosPesoCorporal`).
extension PesoCorporalQueries on AppDatabase {
  Future<List<RegistrosPesoCorporalData>> historialPesoCorporal() =>
      (select(registrosPesoCorporal)
            ..orderBy([(r) => OrderingTerm.asc(r.fecha)]))
          .get();

  Future<int> registrarPesoCorporal(double peso, {String? nota}) =>
      into(registrosPesoCorporal).insert(RegistrosPesoCorporalCompanion.insert(
        peso: peso,
        nota: Value(nota),
      ));
}
