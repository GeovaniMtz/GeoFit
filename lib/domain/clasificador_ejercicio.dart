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

  /// Pública porque también la reutiliza [ImportadorRutina] para
  /// comparar nombres pegados contra el catálogo existente.
  static String normalizar(String texto) {
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
    final nombre = normalizar(nombreEjercicio);
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

  static const _gruposTrenInferior = [
    'pierna',
    'gluteo',
    'cuadricep',
    'femoral',
    'isquio',
    'gemelo',
    'pantorrilla',
    'aductor',
    'abductor',
  ];

  static const _palabrasTrenInferior = [
    'sentadilla',
    'squat',
    'peso muerto',
    'deadlift',
    'prensa',
    'zancada',
    'desplante',
    'bulgara',
    'hip thrust',
    'puente de gluteo',
    'curl femoral',
    'extension de cuadricep',
    'gemelo',
    'pantorrilla',
    'aductor',
    'abductor',
    'hack',
    'step up',
  ];

  /// ¿El ejercicio es de tren inferior? Decide el tamaño del salto de peso
  /// al progresar (las piernas toleran incrementos más grandes). Primero
  /// mira el grupo muscular del catálogo y, si no ayuda (p. ej. "Sin
  /// clasificar" en ejercicios creados al vuelo), el nombre.
  static bool esTrenInferior(String nombreEjercicio,
      {String grupoMuscular = ''}) {
    final grupo = normalizar(grupoMuscular);
    if (_gruposTrenInferior.any(grupo.contains)) return true;
    final nombre = normalizar(nombreEjercicio);
    return _palabrasTrenInferior.any(nombre.contains);
  }
}
