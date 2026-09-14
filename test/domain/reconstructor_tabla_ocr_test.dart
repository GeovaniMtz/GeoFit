import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/domain/importador_rutina.dart';
import 'package:geolift/domain/reconstructor_tabla_ocr.dart';

void main() {
  group('ReconstructorTablaOcr.reconstruir', () {
    test(
        'reagrupa nombre + su serie por fila aunque el OCR haya entregado '
        'primero toda la columna de nombres y después toda la de series '
        '(el bug real: ML Kit lee una tabla columna por columna)', () {
      final lineas = [
        // Columna "Nombre" completa primero, tal como la entrega ML Kit.
        const LineaOcr(
            texto: 'Press Banca', left: 10, top: 100, right: 150, bottom: 130),
        const LineaOcr(
            texto: 'Press Banca inclinado',
            left: 10,
            top: 140,
            right: 190,
            bottom: 170),
        const LineaOcr(
            texto: 'Pullover', left: 10, top: 180, right: 100, bottom: 210),
        // Columna "Series" completa después.
        const LineaOcr(
            texto: '10, 8, 8, 6',
            left: 250,
            top: 100,
            right: 330,
            bottom: 130),
        const LineaOcr(
            texto: '8, 8, 6', left: 250, top: 140, right: 300, bottom: 170),
        const LineaOcr(
            texto: '2 x 8', left: 250, top: 180, right: 290, bottom: 210),
      ];

      final texto = ReconstructorTablaOcr.reconstruir(lineas);

      expect(texto.split('\n'), [
        'Press Banca 10, 8, 8, 6',
        'Press Banca inclinado 8, 8, 6',
        'Pullover 2 x 8',
      ]);
    });

    test(
        'una fila con un solo elemento (encabezado de día que ocupa todo '
        'el ancho) queda como línea suelta, sin fusionarse con nada', () {
      final lineas = [
        const LineaOcr(
            texto: 'LUNES Pecho - Triceps',
            left: 10,
            top: 20,
            right: 320,
            bottom: 50),
        const LineaOcr(
            texto: 'Press Banca', left: 10, top: 100, right: 150, bottom: 130),
        const LineaOcr(
            texto: '10, 8, 8, 6',
            left: 250,
            top: 100,
            right: 330,
            bottom: 130),
      ];

      final texto = ReconstructorTablaOcr.reconstruir(lineas);

      expect(texto.split('\n'), [
        'LUNES Pecho - Triceps',
        'Press Banca 10, 8, 8, 6',
      ]);
    });

    test(
        'las etiquetas de columna repetidas por bloque (Series, Apuntes, '
        'Nombre, Fecha) se descartan y no generan una fila vacía o basura',
        () {
      final lineas = [
        const LineaOcr(texto: 'NOMBRE', left: 10, top: 10, right: 80, bottom: 30),
        const LineaOcr(
            texto: 'FECHA:', left: 300, top: 10, right: 380, bottom: 30),
        const LineaOcr(
            texto: 'Series', left: 250, top: 60, right: 300, bottom: 80),
        const LineaOcr(
            texto: 'Apuntes', left: 400, top: 60, right: 460, bottom: 80),
        const LineaOcr(
            texto: 'Press Banca', left: 10, top: 100, right: 150, bottom: 130),
        const LineaOcr(
            texto: '10, 8, 8, 6',
            left: 250,
            top: 100,
            right: 330,
            bottom: 130),
      ];

      final texto = ReconstructorTablaOcr.reconstruir(lineas);

      expect(texto.split('\n'), ['Press Banca 10, 8, 8, 6']);
    });

    test('sin líneas útiles (todo ruido o vacío) retorna cadena vacía', () {
      final lineas = [
        const LineaOcr(texto: 'Series', left: 0, top: 0, right: 10, bottom: 10),
        const LineaOcr(texto: '   ', left: 20, top: 0, right: 30, bottom: 10),
      ];

      expect(ReconstructorTablaOcr.reconstruir(lineas), isEmpty);
    });

    test(
        'una grilla de 5 columnas (un día por columna) no mezcla columnas '
        'entre sí, aunque el OCR las entregue en cualquier orden — cada '
        'columna se lee de arriba a abajo y sus subtítulos de músculo se '
        'descartan en silencio', () {
      // Coordenadas de una tabla como la real: 5 columnas de días bien
      // separadas en X (gap de 190, muy por encima de la tolerancia de
      // columna), cada una con: encabezado de día, subtítulo de grupo
      // muscular (sin números — se debe descartar), y varios ejercicios
      // que ya traen su propia serie en la misma celda. Se listan
      // intercaladas entre columnas (no agrupadas) para simular que el
      // OCR no las entrega en ningún orden confiable.
      final lineas = [
        const LineaOcr(
            texto: 'LUNES', left: 10, top: 20, right: 110, bottom: 50),
        const LineaOcr(
            texto: 'MARTES', left: 200, top: 20, right: 300, bottom: 50),
        const LineaOcr(
            texto: 'PECHO', left: 10, top: 60, right: 130, bottom: 90),
        const LineaOcr(
            texto: 'ESPALDA', left: 200, top: 60, right: 320, bottom: 90),
        const LineaOcr(
            texto: 'MIERCOLES', left: 390, top: 20, right: 490, bottom: 50),
        const LineaOcr(
            texto: 'Press banca 4x12',
            left: 10,
            top: 100,
            right: 230,
            bottom: 130),
        const LineaOcr(
            texto: 'Dominadas al fallo',
            left: 200,
            top: 100,
            right: 420,
            bottom: 130),
        const LineaOcr(
            texto: 'PIERNA', left: 390, top: 60, right: 510, bottom: 90),
        const LineaOcr(
            texto: 'Aperturas 3x12',
            left: 10,
            top: 140,
            right: 230,
            bottom: 170),
        const LineaOcr(
            texto: 'Jalón tras nuca 3x12',
            left: 200,
            top: 140,
            right: 420,
            bottom: 170),
        const LineaOcr(
            texto: 'Sentadillas 4x12',
            left: 390,
            top: 100,
            right: 610,
            bottom: 130),
        const LineaOcr(
            texto: 'JUEVES', left: 580, top: 20, right: 680, bottom: 50),
        const LineaOcr(
            texto: 'HOMBRO', left: 10, top: 180, right: 130, bottom: 210),
        const LineaOcr(
            texto: 'PECHO', left: 580, top: 60, right: 700, bottom: 90),
        const LineaOcr(
            texto: 'Peso muerto 4x12',
            left: 390,
            top: 140,
            right: 610,
            bottom: 170),
        const LineaOcr(
            texto: 'BICEPS', left: 200, top: 180, right: 320, bottom: 210),
        const LineaOcr(
            texto: 'VIERNES', left: 770, top: 20, right: 870, bottom: 50),
        const LineaOcr(
            texto: 'Press banca plano 3x12',
            left: 580,
            top: 100,
            right: 800,
            bottom: 130),
        const LineaOcr(
            texto: 'Press Arnold 3x12',
            left: 10,
            top: 220,
            right: 230,
            bottom: 250),
        const LineaOcr(
            texto: 'ESPALDA', left: 770, top: 60, right: 890, bottom: 90),
        const LineaOcr(
            texto: 'Curl martillo 3x12',
            left: 200,
            top: 220,
            right: 420,
            bottom: 250),
        const LineaOcr(
            texto: 'Aperturas planas 4x12',
            left: 580,
            top: 140,
            right: 800,
            bottom: 170),
        const LineaOcr(
            texto: 'Dominadas al fallo',
            left: 770,
            top: 100,
            right: 990,
            bottom: 130),
        const LineaOcr(
            texto: 'HOMBRO', left: 580, top: 180, right: 700, bottom: 210),
        const LineaOcr(
            texto: 'Jalón tras nuca 3x12',
            left: 770,
            top: 140,
            right: 990,
            bottom: 170),
        const LineaOcr(
            texto: 'Press Arnold 3x12',
            left: 580,
            top: 220,
            right: 800,
            bottom: 250),
        const LineaOcr(
            texto: 'BICEPS', left: 770, top: 180, right: 890, bottom: 210),
        const LineaOcr(
            texto: 'Curl predicador 3x12',
            left: 770,
            top: 220,
            right: 990,
            bottom: 250),
      ];

      final resultado =
          ImportadorRutina.parsear(ReconstructorTablaOcr.reconstruir(lineas));

      expect(resultado.dias.map((d) => d.nombre),
          ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES']);
      expect(
        resultado.dias
            .map((d) => d.ejercicios.map((e) => e.nombre).toList())
            .toList(),
        [
          ['Press banca', 'Aperturas', 'Press Arnold'],
          ['Dominadas', 'Jalón tras nuca', 'Curl martillo'],
          ['Sentadillas', 'Peso muerto'],
          ['Press banca plano', 'Aperturas planas', 'Press Arnold'],
          ['Dominadas', 'Jalón tras nuca', 'Curl predicador'],
        ],
      );
    });

    test(
        'de punta a punta: el texto reconstruido de una tabla revuelta se '
        'importa como 2 días con sus ejercicios y series correctos', () {
      final lineas = [
        // Encabezados de día (fila ancha, una sola columna).
        const LineaOcr(
            texto: 'LUNES Pecho', left: 10, top: 20, right: 320, bottom: 50),
        // Todo el bloque de nombres primero...
        const LineaOcr(
            texto: 'Press Banca', left: 10, top: 100, right: 150, bottom: 130),
        const LineaOcr(
            texto: 'Aperturas con mancuernas',
            left: 10,
            top: 140,
            right: 220,
            bottom: 170),
        const LineaOcr(
            texto: 'MARTES Espalda',
            left: 10,
            top: 220,
            right: 320,
            bottom: 250),
        const LineaOcr(
            texto: 'Dominadas al fallo',
            left: 10,
            top: 300,
            right: 180,
            bottom: 330),
        // ...y todo el bloque de series después, en el mismo orden de fila.
        const LineaOcr(
            texto: '10, 8, 8, 6',
            left: 250,
            top: 100,
            right: 330,
            bottom: 130),
        const LineaOcr(
            texto: '2x8', left: 250, top: 140, right: 290, bottom: 170),
      ];

      final texto = ReconstructorTablaOcr.reconstruir(lineas);
      final resultado = ImportadorRutina.parsear(texto);

      // El parser solo recorta el prefijo "Día N" — un encabezado como
      // "LUNES Pecho" (sin ese prefijo) queda como nombre de día tal cual,
      // que es aparte de lo que se está probando aquí.
      expect(resultado.dias, hasLength(2));
      expect(resultado.dias[0].nombre, 'LUNES Pecho');
      expect(resultado.dias[0].ejercicios, hasLength(2));
      expect(resultado.dias[0].ejercicios[0].nombre, 'Press Banca');
      expect(resultado.dias[0].ejercicios[0].series, 4);
      expect(resultado.dias[0].ejercicios[0].repsMin, 6);
      expect(resultado.dias[0].ejercicios[0].repsMax, 10);
      expect(resultado.dias[1].nombre, 'MARTES Espalda');
      // "Dominadas al fallo" no tenía ninguna serie en su fila (quedó
      // sola) — se registra igual gracias al patrón "al fallo".
      expect(resultado.dias[1].ejercicios, hasLength(1));
      expect(resultado.dias[1].ejercicios[0].nombre, 'Dominadas');
    });
  });
}
