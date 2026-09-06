import '../data/database.dart';

/// Decide cuál de los días configurados en una rutina le toca entrenar hoy
/// al usuario: rota al siguiente después del último que entrenó (según el
/// orden de la rutina), o el primero si todavía no la ha entrenado nunca.
RutinaDia? diaQueToca(List<RutinaDia> dias, RutinaDia? ultimoEntrenado) {
  if (dias.isEmpty) return null;
  if (ultimoEntrenado == null) return dias.first;

  final indice = dias.indexWhere((d) => d.id == ultimoEntrenado.id);
  if (indice == -1) return dias.first;
  return dias[(indice + 1) % dias.length];
}
