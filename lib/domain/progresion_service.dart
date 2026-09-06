/// Motor de mejora de rutina — reglas simples y explicables, sin IA.
///
/// Capa de dominio pura: no depende de Flutter ni de Drift, así que se puede
/// probar con `dart test` / `flutter test` sin levantar la base de datos.
library;

/// Una serie ya realizada, junto con el objetivo de reps contra el que se mide.
class SerieRealizada {
  final double peso;
  final int reps;
  final int repsMinObjetivo;
  final int repsMaxObjetivo;

  const SerieRealizada({
    required this.peso,
    required this.reps,
    required this.repsMinObjetivo,
    required this.repsMaxObjetivo,
  });

  bool get llegoAlTope => reps >= repsMaxObjetivo;
  bool get noLlegoAlMinimo => reps < repsMinObjetivo;
}

enum TipoSugerencia { subirPeso, deload, ninguna }

class Sugerencia {
  final TipoSugerencia tipo;
  final double? incrementoKg;
  final String motivo;

  const Sugerencia(this.tipo, this.incrementoKg, this.motivo);

  static const ninguna = Sugerencia(TipoSugerencia.ninguna, null, '');
}

class ProgresionService {
  /// Sesiones seguidas que deben cumplir la condición antes de sugerir un cambio.
  static const int sesionesConsecutivasRequeridas = 2;

  static const double incrementoTrenSuperior = 2.5;
  static const double incrementoTrenInferior = 5.0;
  static const double factorDeload = 0.90;

  /// [ultimasSesiones] va de la más reciente a la más antigua; cada elemento
  /// es la lista de series de esa sesión para el mismo ejercicio.
  Sugerencia evaluar(
    List<List<SerieRealizada>> ultimasSesiones, {
    required bool esTrenInferior,
  }) {
    if (ultimasSesiones.length < sesionesConsecutivasRequeridas) {
      return Sugerencia.ninguna;
    }

    final recientes =
        ultimasSesiones.take(sesionesConsecutivasRequeridas).toList();

    final todasAlTope = recientes.every(
      (sesion) => sesion.isNotEmpty && sesion.every((s) => s.llegoAlTope),
    );
    if (todasAlTope) {
      final incremento =
          esTrenInferior ? incrementoTrenInferior : incrementoTrenSuperior;
      return Sugerencia(
        TipoSugerencia.subirPeso,
        incremento,
        'Completaste todas las series al tope del rango en las últimas '
        '$sesionesConsecutivasRequeridas sesiones. Sube ${incremento}kg.',
      );
    }

    final fallaronMinimoSiempre = recientes.every(
      (sesion) => sesion.isNotEmpty && sesion.any((s) => s.noLlegoAlMinimo),
    );
    if (fallaronMinimoSiempre) {
      return const Sugerencia(
        TipoSugerencia.deload,
        null,
        'No alcanzaste el mínimo de reps en las últimas sesiones. '
        'Considera una semana de descarga al 90% del peso.',
      );
    }

    return Sugerencia.ninguna;
  }

  /// 1RM estimado con la fórmula de Epley: peso × (1 + reps / 30).
  double e1rm(double peso, int reps) => peso * (1 + reps / 30);

  /// Peso de descarga sugerido para una semana de deload.
  double pesoDeDeload(double pesoActual) => pesoActual * factorDeload;

  /// Volumen de una sesión para un ejercicio: Σ (reps × peso) por serie.
  double volumen(List<SerieRealizada> series) =>
      series.fold(0.0, (total, s) => total + (s.reps * s.peso));

  /// ¿El nuevo set es un PR frente al mejor e1RM histórico?
  bool esNuevoPr(
      {required double e1rmNuevo, required double? e1rmMaximoPrevio}) {
    if (e1rmMaximoPrevio == null) return true;
    return e1rmNuevo > e1rmMaximoPrevio;
  }
}
