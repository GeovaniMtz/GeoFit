import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/reconstructor_tabla_ocr.dart';

/// Envuelve el reconocimiento de texto (OCR) on-device de ML Kit para
/// convertir una foto de una rutina (cuaderno, pizarra, captura de
/// pantalla, planilla con columnas) en texto plano, que se pasa a
/// [ImportadorRutina.parsear] — la misma tubería que ya usa "pegar rutina
/// como texto", sin duplicar lógica de interpretación.
class EscanerRutinaService {
  final TextRecognizer _reconocedor =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Extrae el texto de la foto en [rutaImagen]. Retorna cadena vacía si no
  /// se reconoció nada (foto borrosa, sin texto legible, etc.) — el
  /// llamador decide cómo avisar al usuario en ese caso.
  ///
  /// Antes de devolver el texto plano de ML Kit, intenta reconstruirlo por
  /// posición con [ReconstructorTablaOcr]: para una rutina en tabla
  /// (columnas "Nombre" / "Series" / "Apuntes"), el texto plano de ML Kit
  /// sale columna por columna en vez de fila por fila, perdiendo qué serie
  /// le corresponde a qué ejercicio. Si la reconstrucción no encuentra
  /// nada útil (foto sin estructura de tabla), cae de vuelta al texto
  /// plano tal cual.
  Future<String> reconocerTexto(String rutaImagen) async {
    final entrada = InputImage.fromFilePath(rutaImagen);
    final resultado = await _reconocedor.processImage(entrada);

    final lineas = <LineaOcr>[
      for (final bloque in resultado.blocks)
        for (final linea in bloque.lines)
          LineaOcr(
            texto: linea.text,
            left: linea.boundingBox.left,
            top: linea.boundingBox.top,
            right: linea.boundingBox.right,
            bottom: linea.boundingBox.bottom,
          ),
    ];

    final reconstruido = ReconstructorTablaOcr.reconstruir(lineas);
    return reconstruido.isNotEmpty ? reconstruido : resultado.text;
  }

  /// Libera el reconocedor nativo. Se llama al descartar el provider, igual
  /// que [AppDatabase.close] en [databaseProvider].
  Future<void> cerrar() => _reconocedor.close();
}
