import '../data/database.dart';
import 'clasificador_ejercicio.dart';

/// Un ejercicio tal como se interpretó de una línea de texto pegada por el
/// usuario, antes de intentar emparejarlo contra el catálogo existente.
class EjercicioParseado {
  final String nombre;
  final int series;
  final int repsMin;
  final int repsMax;

  const EjercicioParseado({
    required this.nombre,
    required this.series,
    required this.repsMin,
    required this.repsMax,
  });
}

class DiaParseado {
  final String nombre;
  final List<EjercicioParseado> ejercicios;

  DiaParseado(this.nombre) : ejercicios = [];
}

class ResultadoImportacion {
  final List<DiaParseado> dias;

  /// Líneas que no se pudieron interpretar como ejercicio ni como
  /// encabezado de día útil (p. ej. un encabezado sin ejercicios debajo).
  /// Se muestran al usuario en vez de perderse en silencio.
  final List<String> lineasNoReconocidas;

  const ResultadoImportacion({
    required this.dias,
    required this.lineasNoReconocidas,
  });

  int get totalEjercicios =>
      dias.fold(0, (suma, dia) => suma + dia.ejercicios.length);
}

/// Convierte una rutina pegada como texto libre (de una nota, cuaderno, etc.)
/// en días/ejercicios estructurados, y busca coincidencias en el catálogo de
/// ejercicios ya existente para no crear duplicados por typos o variantes de
/// redacción.
class ImportadorRutina {
  static const int _maxLongitudNombre = 100; // Ejercicios.nombre en tables.dart

  // "4x8-12", "4 x 8", "3x10", "4×8-12", "3*10"
  static final RegExp _regexSeriesXReps =
      RegExp(r'(\d{1,2})\s*[x×X\*]\s*(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?');

  // "3 series de 10-12", "4 sets 8"
  static final RegExp _regexSeriesDeReps = RegExp(
    r'(\d{1,2})\s*(?:series?|sets?)\s*(?:de\s*)?(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?',
    caseSensitive: false,
  );

  // "10, 8, 8, 6" o "10/8/8/6": pirámide descendente u otro esquema con
  // una meta de reps distinta por serie — la cantidad de series es cuántos
  // números se listaron, y se guarda como el rango completo (menor-mayor).
  static final RegExp _regexListaReps =
      RegExp(r'(\d{1,3}(?:\s*[,/]\s*\d{1,3}){1,})');

  // "4 al fallo", "3 fallo", "Dominadas al fallo", "hasta el fallo": sin
  // una meta de reps fija, así que solo hay que rescatar cuántas series
  // hay (si se indicó un número) — si no, es un ejercicio de una sola
  // serie "hasta donde aguantes".
  static final RegExp _regexAlFallo = RegExp(
    r'(?:(\d{1,2})\s*(?:x|×|\*)?\s*)?\b(?:al\s+fallo|hasta\s+el\s+fallo|fallo)\b',
    caseSensitive: false,
  );

  static final RegExp _regexBullet = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*');
  static final RegExp _regexBordeInicial = RegExp(r'^[\s:,\-–]+');
  static final RegExp _regexBordeFinal = RegExp(r'[\s:,\-–]+$');

  static final RegExp _regexPrefijoDia =
      RegExp(r'^\s*(?:d[ií]a|day)\s*\d+\s*[:\-–]?\s*', caseSensitive: false);

  // Nombre de día de la semana en cualquier parte de la línea ("LUNES
  // Pecho - Triceps", "martes: espalda"): junto con _regexPrefijoDia
  // ("Día 1"), es la señal que usa [_pareceEncabezadoDia] para decidir si
  // una línea sin series/reps es realmente un encabezado de día nuevo o
  // solo un nombre de ejercicio que, por un fallo de OCR/reconstrucción de
  // tabla, llegó sin su columna de series pegada.
  static final RegExp _regexDiaSemana = RegExp(
    r'\b(lunes|martes|mi[ée]rcoles|jueves|viernes|s[áa]bado|domingo)\b',
    caseSensitive: false,
  );

  static const _stopwords = {
    'de', 'del', 'la', 'el', 'los', 'las', 'en', 'con', 'y', 'a', 'al',
  };

  /// Grupos de palabras mutuamente excluyentes: si un nombre menciona una
  /// palabra del grupo y el otro menciona una DISTINTA del mismo grupo,
  /// nunca son el mismo ejercicio sin importar qué tan parecido se vea el
  /// resto del texto — trabajan un músculo, ángulo o lado distinto (p. ej.
  /// "Extensión de tríceps" vs. "Extensión de cuádriceps", o "Press banca
  /// inclinado" vs. "Press banca declinado"). Las variantes de plural ya se
  /// resuelven con [_stem] antes de comparar, así que aquí solo hace falta
  /// una forma por palabra (más el par de género donde aplica).
  static const List<Set<String>> _gruposExcluyentes = [
    {
      'bicep', 'tricep', 'cuadricep', 'femoral', 'gluteo', 'dorsal',
      'deltoide', 'pectoral', 'gemelo', 'pantorrilla', 'abdominal',
      'antebrazo', 'trapecio', 'lumbar', 'oblicuo',
    },
    {'frontal', 'lateral', 'posterior'},
    {'inclinado', 'inclinada', 'declinado', 'declinada', 'plano', 'plana'},
    {'unilateral', 'bilateral'},
    {'izquierdo', 'izquierda', 'derecho', 'derecha'},
  ];

  /// Prueba los cuatro formatos de series/reps reconocidos, en orden, y
  /// retorna el match crudo (para poder quitarlo de la línea y quedarse
  /// con el nombre) junto con las series/reps ya resueltas. `null` si la
  /// línea no tiene ninguno — el llamador la trata entonces como posible
  /// encabezado de día.
  static ({RegExpMatch match, int series, int repsMin, int repsMax})?
      _extraerSeriesYReps(String linea) {
    final matchRango =
        _regexSeriesXReps.firstMatch(linea) ?? _regexSeriesDeReps.firstMatch(linea);
    if (matchRango != null) {
      var series = int.tryParse(matchRango.group(1)!) ?? 3;
      if (series < 1) series = 1;
      var repsMin = int.tryParse(matchRango.group(2)!) ?? 8;
      if (repsMin < 1) repsMin = 1;
      var repsMax = matchRango.group(3) != null
          ? (int.tryParse(matchRango.group(3)!) ?? repsMin)
          : repsMin;
      if (repsMax < repsMin) repsMax = repsMin;
      return (match: matchRango, series: series, repsMin: repsMin, repsMax: repsMax);
    }

    final matchLista = _regexListaReps.firstMatch(linea);
    if (matchLista != null) {
      final numeros = matchLista
          .group(1)!
          .split(RegExp(r'[,/]'))
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
      if (numeros.length >= 2) {
        return (
          match: matchLista,
          series: numeros.length,
          repsMin: numeros.reduce((a, b) => a < b ? a : b),
          repsMax: numeros.reduce((a, b) => a > b ? a : b),
        );
      }
    }

    final matchFallo = _regexAlFallo.firstMatch(linea);
    if (matchFallo != null) {
      final serieCapturada = matchFallo.group(1);
      var series = serieCapturada != null ? (int.tryParse(serieCapturada) ?? 3) : 3;
      if (series < 1) series = 1;
      // Sin meta de reps fija ("al fallo" = hasta donde aguantes): se deja
      // el mismo valor por defecto que cuando no se detecta ningún número
      // de reps en los otros formatos, editable luego desde la revisión.
      return (match: matchFallo, series: series, repsMin: 8, repsMax: 8);
    }

    return null;
  }

  /// True si [texto] ya trae su propia meta de series/reps reconocible
  /// (p. ej. "Press banca 4x12", "3 al fallo"). Pública para que
  /// [ReconstructorTablaOcr] pueda distinguir, dentro de una columna de una
  /// tabla en grilla (días como columna), una celda que ya es un ejercicio
  /// completo de un subtítulo de grupo muscular sin números.
  static bool pareceTenerSeriesYReps(String texto) =>
      _extraerSeriesYReps(texto) != null;

  // Los encabezados de día reales casi siempre son cortos ("Push", "Full
  // body", "LUNES Pecho - Triceps"), mientras que un nombre de ejercicio
  // que perdió su columna de series casi siempre tiene más palabras
  // (describe músculo + ángulo + agarre + equipo). No es infalible, pero
  // como señal de apoyo junto a [_regexDiaSemana]/[_regexPrefijoDia] evita
  // fragmentar la rutina por líneas largas sin ganar falsos positivos en
  // los encabezados cortos típicos.
  static const int _maxPalabrasEncabezadoSinPatron = 3;

  /// True solo con una señal inequívoca de encabezado de día ("Día 2",
  /// "LUNES Pecho - Triceps") — a diferencia de [_pareceEncabezadoDia], no
  /// se deja engañar por una línea corta cualquiera. Un día abierto con
  /// esta señal es lo bastante confiable como para sobrevivir aunque el
  /// ejercicio que le sigue también haya perdido su columna de series
  /// (ver [parsear]).
  static bool _esEncabezadoConfirmado(String linea) =>
      _regexPrefijoDia.hasMatch(linea) || _regexDiaSemana.hasMatch(linea);

  /// True si [linea] tiene pinta de encabezado de día ("Día 2", "LUNES
  /// Pecho - Triceps", "Push") en vez de un nombre de ejercicio cualquiera.
  /// Se usa solo para decidir si una línea SIN series/reps debe cortar el
  /// día actual — una línea larga sin ese patrón, en medio de un día que ya
  /// tiene ejercicios, es mucho más probable que sea un ejercicio cuya
  /// columna de series se perdió (OCR, reconstrucción de tabla) que un día
  /// nuevo de verdad, así que no debe fragmentar la rutina.
  static bool _pareceEncabezadoDia(String linea) {
    if (_esEncabezadoConfirmado(linea)) return true;
    final palabras = linea.trim().split(RegExp(r'\s+'));
    return palabras.length <= _maxPalabrasEncabezadoSinPatron;
  }

  static ResultadoImportacion parsear(String texto) {
    final dias = <DiaParseado>[];
    final lineasNoReconocidas = <String>[];

    DiaParseado? actual;
    String? encabezadoActual;
    // True si `actual` se abrió con una señal inequívoca de día (día de la
    // semana o "Día N"), no con el resguardo genérico de "línea corta
    // cualquiera". Sin esto, un día real recién abierto cuyo PRIMER
    // ejercicio también perdió su columna de series (mismo problema de OCR
    // que motivó el resguardo de abajo) se descartaba como "vacío" antes de
    // que le llegara ningún ejercicio — perdiendo el día real completo y
    // dejando que ese ejercicio roto se convirtiera en un día fantasma con
    // su nombre.
    var actualConfirmado = false;

    void cerrarDiaActual() {
      final dia = actual;
      if (dia == null) return;
      if (dia.ejercicios.isEmpty) {
        lineasNoReconocidas.add(encabezadoActual ?? dia.nombre);
      } else {
        dias.add(dia);
      }
      actual = null;
      encabezadoActual = null;
    }

    for (final lineaCruda in texto.split('\n')) {
      final linea = lineaCruda.trim();
      if (linea.isEmpty) continue;

      final extraido = _extraerSeriesYReps(linea);

      if (extraido != null) {
        final match = extraido.match;
        var nombre = linea.substring(0, match.start) + linea.substring(match.end);
        nombre = nombre.replaceFirst(_regexBullet, '');
        nombre = nombre.replaceFirst(_regexBordeInicial, '');
        nombre = nombre.replaceFirst(_regexBordeFinal, '');
        nombre = nombre.trim();

        if (nombre.isEmpty) {
          lineasNoReconocidas.add(linea);
          continue;
        }
        if (nombre.length > _maxLongitudNombre) {
          nombre = nombre.substring(0, _maxLongitudNombre);
        }

        actual ??= DiaParseado('');
        actual!.ejercicios.add(EjercicioParseado(
          nombre: nombre,
          series: extraido.series,
          repsMin: extraido.repsMin,
          repsMax: extraido.repsMax,
        ));
      } else if (actual != null &&
          (actual!.ejercicios.isNotEmpty || actualConfirmado) &&
          !_pareceEncabezadoDia(linea)) {
        // Ya estamos en medio de un día (con ejercicios reales, o confiable
        // aunque todavía no le haya llegado ninguno) y esta línea no tiene
        // ni series/reps ni pinta de encabezado de día: es mucho más
        // probable que sea un ejercicio que perdió su columna de series
        // (falla de OCR o de reconstrucción de tabla) que un día nuevo de
        // verdad. Cortar el día aquí robaría todos los ejercicios
        // siguientes hacia un día fantasma con este nombre — en vez de
        // eso, se deja como línea no reconocida y el día actual sigue
        // abierto.
        lineasNoReconocidas.add(linea);
      } else {
        cerrarDiaActual();
        final nombreDia = linea.replaceFirst(_regexPrefijoDia, '').trim();
        actual = DiaParseado(nombreDia.isEmpty ? linea : nombreDia);
        encabezadoActual = linea;
        actualConfirmado = _esEncabezadoConfirmado(linea);
      }
    }
    cerrarDiaActual();

    return ResultadoImportacion(
      dias: dias,
      lineasNoReconocidas: lineasNoReconocidas,
    );
  }

  /// Busca en [catalogo] el ejercicio existente más parecido a [nombre].
  /// Retorna `null` si nada cruza el [umbral] — el llamador debe entonces
  /// tratar [nombre] como un ejercicio nuevo.
  static Ejercicio? buscarCoincidencia(
    String nombre,
    List<Ejercicio> catalogo, {
    double umbral = 0.80,
  }) {
    final normA = ClasificadorEjercicio.normalizar(nombre).trim();
    if (normA.isEmpty || catalogo.isEmpty) return null;

    for (final candidato in catalogo) {
      if (ClasificadorEjercicio.normalizar(candidato.nombre).trim() == normA) {
        return candidato;
      }
    }

    final tokensA = _tokenizar(normA);
    final setA = tokensA.toSet();
    Ejercicio? mejor;
    var mejorScore = 0.0;

    for (final candidato in catalogo) {
      final normB = ClasificadorEjercicio.normalizar(candidato.nombre).trim();
      final tokensB = _tokenizar(normB);

      // Antes de mirar qué tan parecido es el texto: si uno menciona un
      // músculo/ángulo/lado y el otro menciona uno distinto del mismo
      // grupo, son ejercicios distintos aunque el resto de las palabras
      // sea casi idéntico — se descarta este candidato de una vez.
      if (_tieneConflictoExcluyente(setA, tokensB.toSet())) continue;

      final levRatio = _razonLevenshtein(normA, normB);

      var overlap = 0.0;
      // Solo se confía en el solapamiento de palabras cuando los nombres
      // tienen una cantidad de palabras parecida: si no, un nombre corto
      // ("Press banca") calzaría como subconjunto de uno mucho más largo y
      // distinto ("Press banca inclinado con mancuernas").
      if (tokensA.isNotEmpty &&
          tokensB.isNotEmpty &&
          (tokensA.length - tokensB.length).abs() <= 1) {
        final interseccion =
            tokensA.toSet().intersection(tokensB.toSet()).length;
        final menor =
            tokensA.length < tokensB.length ? tokensA.length : tokensB.length;
        overlap = interseccion / menor;
      }

      final score = levRatio > overlap ? levRatio : overlap;
      if (score > mejorScore) {
        mejorScore = score;
        mejor = candidato;
      }
    }

    return mejorScore >= umbral ? mejor : null;
  }

  static List<String> _tokenizar(String normalizado) {
    return normalizado
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty && !_stopwords.contains(token))
        .map(_stem)
        .toList();
  }

  /// Reduce variantes de plural a una forma común ("extensiones" ->
  /// "extension", "mancuernas" -> "mancuerna") para que el solapamiento de
  /// palabras no falle solo porque uno pegó el ejercicio en singular y el
  /// catálogo lo tiene en plural (o viceversa). Solo se usa para comparar
  /// tokens, nunca para el nombre que se guarda o se muestra.
  static String _stem(String token) {
    if (token.length <= 4) return token;
    if (token.endsWith('ones')) {
      return '${token.substring(0, token.length - 4)}on';
    }
    if (token.endsWith('es')) return token.substring(0, token.length - 2);
    if (token.endsWith('s')) return token.substring(0, token.length - 1);
    return token;
  }

  /// True si [tokensA] y [tokensB] mencionan palabras distintas de un mismo
  /// [_gruposExcluyentes] (p. ej. una dice "tríceps" y la otra "cuádriceps")
  /// — señal de que son ejercicios distintos sin importar el resto.
  static bool _tieneConflictoExcluyente(
    Set<String> tokensA,
    Set<String> tokensB,
  ) {
    for (final grupo in _gruposExcluyentes) {
      final enA = tokensA.intersection(grupo);
      if (enA.isEmpty) continue;
      final enB = tokensB.intersection(grupo);
      if (enB.isEmpty) continue;
      if (enA.intersection(enB).isEmpty) return true;
    }
    return false;
  }

  static double _razonLevenshtein(String a, String b) {
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1;
    return 1 - (_levenshtein(a, b) / maxLen);
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var filaPrevia = List<int>.generate(b.length + 1, (j) => j);
    for (var i = 1; i <= a.length; i++) {
      final filaActual = List<int>.filled(b.length + 1, 0);
      filaActual[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final costo = a[i - 1] == b[j - 1] ? 0 : 1;
        final borrar = filaActual[j - 1] + 1;
        final insertar = filaPrevia[j] + 1;
        final sustituir = filaPrevia[j - 1] + costo;
        filaActual[j] = [borrar, insertar, sustituir].reduce(
          (x, y) => x < y ? x : y,
        );
      }
      filaPrevia = filaActual;
    }
    return filaPrevia[b.length];
  }
}
