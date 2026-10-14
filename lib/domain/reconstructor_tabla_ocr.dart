import 'importador_rutina.dart';

/// Un fragmento de texto reconocido por OCR, con su posición en la imagen
/// (mismas unidades que reporte el reconocedor, normalmente píxeles). Es lo
/// único que hace falta para reconstruir una tabla — no depende de los
/// tipos concretos de `google_mlkit_text_recognition`, así que este archivo
/// se puede probar sin un dispositivo real ni un `RecognizedText` de
/// verdad.
class LineaOcr {
  final String texto;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const LineaOcr({
    required this.texto,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get centroY => (top + bottom) / 2;
  double get alto => bottom - top;
}

/// Reconstruye el texto de una tabla a partir de las líneas que dio el OCR
/// y su posición en la imagen — el texto plano de ML Kit
/// (`RecognizedText.text`) concatena las líneas en el orden en que el
/// reconocedor agrupó sus bloques, y para cualquier tabla de columnas eso
/// sale mal (columna por columna en vez de fila por fila, o mezclando
/// columnas que en realidad son días distintos). La posición sigue siendo
/// correcta aunque el orden del texto no lo sea, así que esto reagrupa por
/// posición en vez de confiar en ese orden.
///
/// Hay dos formas de tabla bien distintas en las rutinas reales que se han
/// probado, y cada una necesita una reconstrucción distinta:
///  - Pocas columnas por ATRIBUTO de un mismo ejercicio ("Nombre" | "Series"
///    | "Apuntes"), con un bloque por día apilado verticalmente: aquí hay
///    que JUNTAR nombre + su serie de la misma fila.
///  - Varias columnas, una por DÍA (una grilla de "Lunes | Martes | ... "):
///    aquí las columnas NO se deben mezclar — cada una ya trae, en sus
///    propias celdas, el ejercicio completo ("Press banca 4x12"), y hay que
///    leerla de arriba a abajo como un bloque propio.
/// [reconstruir] cuenta cuántas columnas detecta y elige la estrategia
/// según eso. El resultado se pasa por [ImportadorRutina.parsear] igual que
/// una rutina escrita a mano, línea por línea.
class ReconstructorTablaOcr {
  /// Etiquetas de encabezado de columna: no son un ejercicio ni un nombre
  /// de día, así que se descartan antes de agrupar para que no contaminen
  /// ninguna fila/columna (p. ej. una fila "Series | Apuntes" sin
  /// ejercicio, que es su propio encabezado de sub-tabla por día).
  static const _etiquetasColumna = {
    'series', 'apuntes', 'apuntes:', 'nombre', 'nombre:', 'fecha', 'fecha:',
  };

  /// A partir de esta cantidad de columnas detectadas se asume que cada
  /// columna es un día independiente (grilla) en vez de un atributo más de
  /// un mismo ejercicio (nombre/series). Las dos rutinas reales probadas
  /// hasta ahora tienen 2 columnas (nombre/series) o 5 (un día por
  /// columna) — este umbral las separa con margen de sobra.
  static const int _minColumnasModoGrilla = 4;

  static String reconstruir(List<LineaOcr> lineas) {
    final utiles = lineas.where((l) {
      final texto = l.texto.trim();
      if (texto.isEmpty) return false;
      return !_etiquetasColumna.contains(texto.toLowerCase());
    }).toList();

    if (utiles.isEmpty) return '';

    final columnas = _agruparPorColumna(utiles);
    return columnas.length >= _minColumnasModoGrilla
        ? _reconstruirComoGrilla(columnas)
        : _reconstruirComoFilas(utiles);
  }

  /// Tabla de pocas columnas por atributo ("Nombre" | "Series"): agrupa por
  /// fila (centro vertical parecido) y junta la primera columna (nombre)
  /// con la segunda (su serie) en una sola línea.
  static String _reconstruirComoFilas(List<LineaOcr> utiles) {
    final ordenadas = [...utiles]
      ..sort((a, b) => a.centroY.compareTo(b.centroY));

    final alturaMediana = _mediana(ordenadas.map((l) => l.alto).toList());
    // Dos líneas cuyo centro vertical difiere menos que esto se consideran
    // parte de la misma fila de la tabla.
    final tolerancia = alturaMediana * 0.6;

    final filas = <List<LineaOcr>>[];
    for (final linea in ordenadas) {
      final filaActual = filas.isEmpty ? null : filas.last;
      if (filaActual != null &&
          (linea.centroY - filaActual.first.centroY).abs() <= tolerancia) {
        filaActual.add(linea);
      } else {
        filas.add([linea]);
      }
    }

    final resultado = StringBuffer();
    for (final fila in filas) {
      fila.sort((a, b) => a.left.compareTo(b.left));
      // Primera columna = nombre, segunda = su serie; cualquier columna
      // extra (p. ej. "Apuntes") se ignora — el usuario la revisa a mano.
      final texto = fila.length >= 2
          ? '${fila[0].texto.trim()} ${fila[1].texto.trim()}'
          : fila[0].texto.trim();
      if (texto.isEmpty) continue;
      resultado.writeln(texto);
    }
    return resultado.toString().trim();
  }

  /// Tabla en grilla (varias columnas = varios días independientes): cada
  /// columna se lee de arriba a abajo y se emite tal cual, sin juntarla con
  /// ninguna otra — ya viene autocontenida ("Press banca inclinado 4x12",
  /// nombre y serie juntos en la misma celda).
  ///
  /// La primera celda de la columna es el nombre del día (se conserva
  /// siempre); de ahí en adelante solo se conservan las celdas que ya
  /// traen su propia serie reconocible. Los subtítulos de grupo muscular
  /// que se repiten dentro del día ("PECHO", "HOMBRO", "TRICEPS"...) no
  /// tienen números, así que se descartan en silencio — si se emitieran
  /// como línea suelta, el parser (para el que cualquier línea sin
  /// números abre un día nuevo) cortaría el día a la mitad en cada uno.
  static String _reconstruirComoGrilla(List<List<LineaOcr>> columnas) {
    final resultado = StringBuffer();
    for (final columna in columnas) {
      final ordenada = [...columna]..sort((a, b) => a.top.compareTo(b.top));
      for (var i = 0; i < ordenada.length; i++) {
        final texto = ordenada[i].texto.trim();
        if (texto.isEmpty) continue;
        if (i == 0 || ImportadorRutina.pareceTenerSeriesYReps(texto)) {
          resultado.writeln(texto);
        }
      }
    }
    return resultado.toString().trim();
  }

  static List<List<LineaOcr>> _agruparPorColumna(List<LineaOcr> lineas) {
    final ordenadas = [...lineas]..sort((a, b) => a.left.compareTo(b.left));

    final anchoMediano =
        _mediana(ordenadas.map((l) => l.right - l.left).toList());
    // Dos líneas cuyo borde izquierdo difiere menos que esto se consideran
    // parte de la misma columna.
    final tolerancia = anchoMediano * 0.8;

    final columnas = <List<LineaOcr>>[];
    for (final linea in ordenadas) {
      final colActual = columnas.isEmpty ? null : columnas.last;
      if (colActual != null &&
          (linea.left - colActual.first.left).abs() <= tolerancia) {
        colActual.add(linea);
      } else {
        columnas.add([linea]);
      }
    }
    return columnas;
  }

  static double _mediana(List<double> valores) {
    if (valores.isEmpty) return 0;
    final ordenados = [...valores]..sort();
    final medio = ordenados.length ~/ 2;
    if (ordenados.length.isOdd) return ordenados[medio];
    return (ordenados[medio - 1] + ordenados[medio]) / 2;
  }
}
