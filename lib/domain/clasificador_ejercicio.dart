/// Sugiere un tiempo de descanso por defecto a partir del nombre del
/// ejercicio: los ejercicios de máquina (jalón, prensa, poleas...) permiten
/// recuperarse más rápido que los de peso libre (mancuernas, barra...),
/// donde además interviene la estabilización.
enum TipoEjercicio { pesoLibre, maquina, indeterminado }

class ClasificadorEjercicio {
  static const int descansoMaquinaSeg = 60;
  static const int descansoPesoLibreSeg = 80;
  static const int descansoPorDefectoSeg = 90;

  static const _palabrasMaquina = [
    'maquina',
    'smith',
    'multipower',
    'polea',
    'poleas',
    'jalon',
    'prensa',
    'pec deck',
    'peck deck',
    'contractora',
    'hack',
    'abductor',
    'aductor',
    'extension de cuadriceps',
    'extension de cuadricep',
    'curl femoral',
    'cable cruzado',
    'crossover',
    'gemelo en maquina',
    'gemelos en maquina',
  ];

  static const _palabrasPesoLibre = [
    'mancuerna',
    'barra',
    'kettlebell',
    'pesa rusa',
    'peso muerto',
    'sentadilla',
    'zancada',
    'press banca',
    'press militar',
    'dominadas',
    'fondos',
    'peso libre',
  ];

  static String _normalizar(String texto) {
    var resultado = texto.toLowerCase();
    const acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
    };
    for (final entrada in acentos.entries) {
      resultado = resultado.replaceAll(entrada.key, entrada.value);
    }
    return resultado;
  }

  /// Las palabras de máquina se revisan primero: un nombre como
  /// "sentadilla en máquina" debe clasificarse como máquina aunque
  /// "sentadilla" también aparezca en la lista de peso libre.
  static TipoEjercicio clasificar(String nombreEjercicio) {
    final nombre = _normalizar(nombreEjercicio);
    if (nombre.trim().isEmpty) return TipoEjercicio.indeterminado;
    if (_palabrasMaquina.any(nombre.contains)) return TipoEjercicio.maquina;
    if (_palabrasPesoLibre.any(nombre.contains)) {
      return TipoEjercicio.pesoLibre;
    }
    return TipoEjercicio.indeterminado;
  }

  static int descansoSugeridoSeg(String nombreEjercicio) {
    switch (clasificar(nombreEjercicio)) {
      case TipoEjercicio.maquina:
        return descansoMaquinaSeg;
      case TipoEjercicio.pesoLibre:
        return descansoPesoLibreSeg;
      case TipoEjercicio.indeterminado:
        return descansoPorDefectoSeg;
    }
  }
}
