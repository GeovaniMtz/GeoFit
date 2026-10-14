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

  /// Esfuerzo percibido (6–10), si el usuario lo marcó.
  final double? rpe;

  const SerieRealizada({
    required this.peso,
    required this.reps,
    required this.repsMinObjetivo,
    required this.repsMaxObjetivo,
    this.rpe,
  });

  bool get llegoAlTope => reps >= repsMaxObjetivo;
  bool get noLlegoAlMinimo => reps < repsMinObjetivo;
}

enum TipoSugerencia { subirPeso, mantener, deload, ninguna }

class Sugerencia {
  final TipoSugerencia tipo;
  final double? incrementoKg;
  final String motivo;

  /// Peso (kg) más alto de la sesión más reciente: la base sobre la que se
  /// suma el incremento, se repite (mantener) o se descarga (deload).
  final double? pesoBaseKg;

  const Sugerencia(this.tipo, this.incrementoKg, this.motivo,
      {this.pesoBaseKg});

  static const ninguna = Sugerencia(TipoSugerencia.ninguna, null, '');

  /// Peso (kg) con el que conviene arrancar hoy según la sugerencia, o null
  /// si no hay una.
  double? get pesoSugeridoKg {
    final base = pesoBaseKg;
    if (base == null) return null;
    return switch (tipo) {
      TipoSugerencia.subirPeso => base + (incrementoKg ?? 0),
      TipoSugerencia.mantener => base,
      TipoSugerencia.deload => base * ProgresionService.factorDeload,
      TipoSugerencia.ninguna => null,
    };
  }
}

class ProgresionService {
  /// Sesiones seguidas que deben cumplir la condición antes de sugerir un
  /// cambio cuando no hay RPE que respalde la decisión.
  static const int sesionesConsecutivasRequeridas = 2;

  static const double incrementoTrenSuperior = 2.5;
  static const double incrementoTrenInferior = 5.0;
  static const double factorDeload = 0.90;

  /// RPE máximo para considerar que las series sobraron (≥2 reps en
  /// reserva): con eso basta UNA sesión al tope para subir.
  static const double rpeConSobra = 8;

  /// RPE a partir del cual la serie fue prácticamente al fallo: aunque se
  /// haya llegado al tope de reps, conviene repetir el peso antes de subir.
  static const double rpeAlLimite = 9.5;

  /// [ultimasSesiones] va de la más reciente a la más antigua; cada elemento
  /// es la lista de series de esa sesión para el mismo ejercicio.
  ///
  /// Reglas, en orden:
  /// 1. Última sesión al tope con RPE marcado en todas las series y ≤ 8 →
  ///    subir ya (había reps de sobra).
  /// 2. Última sesión al tope pero con alguna serie a RPE ≥ 9.5 → mantener:
  ///    se llegó, pero al límite.
  /// 3. [sesionesConsecutivasRequeridas] sesiones al tope → subir (la regla
  ///    de siempre, para quien no marca RPE).
  /// 4. [sesionesConsecutivasRequeridas] sesiones sin llegar al mínimo →
  ///    deload.
  Sugerencia evaluar(
    List<List<SerieRealizada>> ultimasSesiones, {
    required bool esTrenInferior,
  }) {
    final conSeries = ultimasSesiones.where((s) => s.isNotEmpty).toList();
    if (conSeries.isEmpty) return Sugerencia.ninguna;

    final ultima = conSeries.first;
    final pesoBase = ultima.map((s) => s.peso).reduce((a, b) => a > b ? a : b);
    final incremento =
        esTrenInferior ? incrementoTrenInferior : incrementoTrenSuperior;
    final ultimaAlTope = ultima.every((s) => s.llegoAlTope);

    if (ultimaAlTope) {
      final rpes = ultima.map((s) => s.rpe).whereType<double>().toList();
      final rpeMaximo =
          rpes.isEmpty ? null : rpes.reduce((a, b) => a > b ? a : b);

      if (rpes.length == ultima.length && rpeMaximo! <= rpeConSobra) {
        return Sugerencia(
          TipoSugerencia.subirPeso,
          incremento,
          'La sesión pasada hiciste todas las series al tope del rango y '
          'con reps de sobra (RPE ${_rpe(rpeMaximo)} o menos).',
          pesoBaseKg: pesoBase,
        );
      }

      if (rpeMaximo != null && rpeMaximo >= rpeAlLimite) {
        return Sugerencia(
          TipoSugerencia.mantener,
          null,
          'Llegaste al tope de reps, pero al límite (RPE '
          '${_rpe(rpeMaximo)}). Repite el peso hasta que se sienta más '
          'fácil antes de subir.',
          pesoBaseKg: pesoBase,
        );
      }
    }

    if (conSeries.length < sesionesConsecutivasRequeridas) {
      return Sugerencia.ninguna;
    }
    final recientes = conSeries.take(sesionesConsecutivasRequeridas).toList();

    if (recientes.every((sesion) => sesion.every((s) => s.llegoAlTope))) {
      return Sugerencia(
        TipoSugerencia.subirPeso,
        incremento,
        'Completaste todas las series al tope del rango en las últimas '
        '$sesionesConsecutivasRequeridas sesiones.',
        pesoBaseKg: pesoBase,
      );
    }

    if (recientes.every((sesion) => sesion.any((s) => s.noLlegoAlMinimo))) {
      return Sugerencia(
        TipoSugerencia.deload,
        null,
        'No alcanzaste el mínimo de reps en las últimas '
        '$sesionesConsecutivasRequeridas sesiones. Baja al 90% una sesión '
        'para recuperar y vuelve a subir desde ahí.',
        pesoBaseKg: pesoBase,
      );
    }

    return Sugerencia.ninguna;
  }

  static String _rpe(double rpe) =>
      rpe == rpe.roundToDouble() ? rpe.toStringAsFixed(0) : '$rpe';

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
