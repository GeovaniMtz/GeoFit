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

  static final RegExp _regexBullet = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*');
  static final RegExp _regexBordeInicial = RegExp(r'^[\s:,\-–]+');
  static final RegExp _regexBordeFinal = RegExp(r'[\s:,\-–]+$');

  static final RegExp _regexPrefijoDia =
      RegExp(r'^\s*(?:d[ií]a|day)\s*\d+\s*[:\-–]?\s*', caseSensitive: false);

  static const _stopwords = {
    'de', 'del', 'la', 'el', 'los', 'las', 'en', 'con', 'y', 'a', 'al',
  };

  static ResultadoImportacion parsear(String texto) {
    final dias = <DiaParseado>[];
    final lineasNoReconocidas = <String>[];

    DiaParseado? actual;
    String? encabezadoActual;

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

      final match = _regexSeriesXReps.firstMatch(linea) ??
          _regexSeriesDeReps.firstMatch(linea);

      if (match != null) {
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

        var series = int.tryParse(match.group(1)!) ?? 3;
        if (series < 1) series = 1;
        var repsMin = int.tryParse(match.group(2)!) ?? 8;
        if (repsMin < 1) repsMin = 1;
        var repsMax = match.group(3) != null
            ? (int.tryParse(match.group(3)!) ?? repsMin)
            : repsMin;
        if (repsMax < repsMin) repsMax = repsMin;

        actual ??= DiaParseado('');
        actual!.ejercicios.add(EjercicioParseado(
          nombre: nombre,
          series: series,
          repsMin: repsMin,
          repsMax: repsMax,
        ));
      } else {
        cerrarDiaActual();
        final nombreDia = linea.replaceFirst(_regexPrefijoDia, '').trim();
        actual = DiaParseado(nombreDia.isEmpty ? linea : nombreDia);
        encabezadoActual = linea;
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
    Ejercicio? mejor;
    var mejorScore = 0.0;

    for (final candidato in catalogo) {
      final normB = ClasificadorEjercicio.normalizar(candidato.nombre).trim();
      final tokensB = _tokenizar(normB);

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
        .toList();
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
