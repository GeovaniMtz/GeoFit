import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/domain/importador_rutina.dart';

void main() {
  Ejercicio ejercicio(int id, String nombre) => Ejercicio(
        id: id,
        nombre: nombre,
        grupoMuscular: 'Sin clasificar',
        equipo: '',
        esPersonalizado: false,
      );

  group('ImportadorRutina.parsear', () {
    test('un día con un ejercicio', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Press banca 4x8-12
''');

      expect(resultado.dias, hasLength(1));
      expect(resultado.dias.single.nombre, 'Pecho');
      expect(resultado.dias.single.ejercicios, hasLength(1));

      final ejercicio = resultado.dias.single.ejercicios.single;
      expect(ejercicio.nombre, 'Press banca');
      expect(ejercicio.series, 4);
      expect(ejercicio.repsMin, 8);
      expect(ejercicio.repsMax, 12);
    });

    test('varios días separados por encabezados', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Press banca 4x8-12

Día 2: Espalda
Dominadas 4x6-10
Remo con barra 3x8-10
''');

      expect(resultado.dias, hasLength(2));
      expect(resultado.dias[0].nombre, 'Pecho');
      expect(resultado.dias[0].ejercicios, hasLength(1));
      expect(resultado.dias[1].nombre, 'Espalda');
      expect(resultado.dias[1].ejercicios, hasLength(2));
    });

    test('quita bullets y numeración de la línea', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
- Press banca 4x8-12
* Aperturas 3x12-15
• Fondos 3x10
1. Press militar 4x8
''');

      final nombres =
          resultado.dias.single.ejercicios.map((e) => e.nombre).toList();
      expect(
        nombres,
        ['Press banca', 'Aperturas', 'Fondos', 'Press militar'],
      );
    });

    test('reps: rango, número único y formato "series de"', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Press banca 4x8-12
Press militar 4x10
Aperturas 3 series de 12-15
''');

      final ejercicios = resultado.dias.single.ejercicios;
      expect(ejercicios[0].repsMin, 8);
      expect(ejercicios[0].repsMax, 12);
      expect(ejercicios[1].repsMin, 10);
      expect(ejercicios[1].repsMax, 10);
      expect(ejercicios[2].series, 3);
      expect(ejercicios[2].repsMin, 12);
      expect(ejercicios[2].repsMax, 15);
    });

    test('el prefijo de encabezado de día se quita sin importar mayúsculas '
        'ni acentos', () {
      final resultado = ImportadorRutina.parsear('''
DÍA 2 - Espalda
Dominadas 4x6-10
''');

      expect(resultado.dias.single.nombre, 'Espalda');
    });

    test('un encabezado de día sin ejercicios debajo se descarta y su '
        'línea queda en lineasNoReconocidas', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Press banca 4x8-12

Día 2: Espalda

Día 3: Pierna
Sentadilla 4x8-10
''');

      expect(resultado.dias.map((d) => d.nombre), ['Pecho', 'Pierna']);
      expect(resultado.lineasNoReconocidas, contains('Día 2: Espalda'));
    });

    test('un título/nota suelto antes del primer encabezado real no se '
        'pierde en silencio ni genera un día vacío', () {
      final resultado = ImportadorRutina.parsear('''
Rutina de 5 días para hipertrofia
Día 1: Pecho
Press banca 4x8-12
''');

      expect(resultado.dias, hasLength(1));
      expect(resultado.dias.single.nombre, 'Pecho');
      expect(resultado.dias.single.ejercicios, hasLength(1));
      expect(
        resultado.lineasNoReconocidas,
        contains('Rutina de 5 días para hipertrofia'),
      );
    });

    test('un ejercicio antes de cualquier encabezado abre un día con '
        'nombre vacío', () {
      final resultado = ImportadorRutina.parsear('Press banca 4x8-12');

      expect(resultado.dias, hasLength(1));
      expect(resultado.dias.single.nombre, isEmpty);
      expect(resultado.dias.single.ejercicios.single.nombre, 'Press banca');
    });

    test('un nombre de ejercicio demasiado largo se trunca a 100 '
        'caracteres', () {
      final nombreLargo = 'A' * 150;
      final resultado = ImportadorRutina.parsear('$nombreLargo 4x8-12');

      expect(resultado.dias.single.ejercicios.single.nombre.length, 100);
    });

    test('"al fallo" sin número de reps se registra como ejercicio (no '
        'como un encabezado de día nuevo) con series por defecto', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Espalda
Dominadas al fallo
''');

      expect(resultado.dias, hasLength(1));
      final ejercicio = resultado.dias.single.ejercicios.single;
      expect(ejercicio.nombre, 'Dominadas');
      expect(ejercicio.series, 3);
    });

    test('"N fallo" y "N al fallo" capturan el número de series indicado',
        () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Fondos entre bancos 3 fallo
Dominadas 4 al fallo
''');

      final ejercicios = resultado.dias.single.ejercicios;
      expect(ejercicios[0].nombre, 'Fondos entre bancos');
      expect(ejercicios[0].series, 3);
      expect(ejercicios[1].nombre, 'Dominadas');
      expect(ejercicios[1].series, 4);
    });

    test('una lista de reps por serie ("10, 8, 8, 6", pirámide '
        'descendente) se interpreta como esa cantidad de series con el '
        'rango completo', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho
Press banca 10, 8, 8, 6
''');

      final ejercicio = resultado.dias.single.ejercicios.single;
      expect(ejercicio.nombre, 'Press banca');
      expect(ejercicio.series, 4);
      expect(ejercicio.repsMin, 6);
      expect(ejercicio.repsMax, 10);
    });

    test(
        'un ejercicio que perdió su columna de series (foto real: '
        '"Remo horizontal a una mano con mancuerna" sin su "3 x 8") no '
        'se convierte en un día fantasma que le roba los ejercicios '
        'siguientes al día real', () {
      final resultado = ImportadorRutina.parsear('''
MARTES Espalda - Biceps
Dominadas 3x8
Remo horizontal a una mano con mancuerna
Remo sentado en polea con agarre abierto 2x8
Polea al pecho 3x8-10
''');

      expect(resultado.dias, hasLength(1));
      expect(resultado.dias.single.nombre, 'MARTES Espalda - Biceps');
      expect(
        resultado.dias.single.ejercicios.map((e) => e.nombre).toList(),
        ['Dominadas', 'Remo sentado en polea con agarre abierto', 'Polea al pecho'],
      );
      expect(
        resultado.lineasNoReconocidas,
        contains('Remo horizontal a una mano con mancuerna'),
      );
    });

    test(
        'un encabezado de día real sin patrón de día de la semana ni '
        '"Día N" (p. ej. "Push", "Full body") sigue abriendo un día '
        'nuevo mientras el día anterior ya tenga ejercicios', () {
      final resultado = ImportadorRutina.parsear('''
Push
Press banca 4x8-12

Pull
Dominadas 4x6-10
''');

      expect(resultado.dias, hasLength(2));
      expect(resultado.dias[0].nombre, 'Push');
      expect(resultado.dias[1].nombre, 'Pull');
    });

    test(
        'un día real cuyo PRIMER ejercicio perdió su columna de series no '
        'se descarta como "vacío" (foto real: "JUEVES Hombros - '
        'Antebrazos" se perdía y "Press frontal con barra 3x" — un '
        'ejercicio roto, sin el "10" tras la x — quedaba de nombre de día '
        'en su lugar)', () {
      final resultado = ImportadorRutina.parsear('''
MARTES Espalda - Biceps
Dominadas 3x8
JUEVES Hombros - Antebrazos
Press frontal con barra 3x
Pajaros 3x10
Press Arnold 4x10
''');

      expect(resultado.dias, hasLength(2));
      expect(resultado.dias[0].nombre, 'MARTES Espalda - Biceps');
      expect(resultado.dias[1].nombre, 'JUEVES Hombros - Antebrazos');
      expect(
        resultado.dias[1].ejercicios.map((e) => e.nombre).toList(),
        ['Pajaros', 'Press Arnold'],
      );
      expect(
        resultado.lineasNoReconocidas,
        contains('Press frontal con barra 3x'),
      );
    });

    test(
        'una tabla con "al fallo" repetido ya no se fragmenta en días '
        'fantasma (regresión del bug donde una rutina de 2 días se leía '
        'como 32 "días")', () {
      final resultado = ImportadorRutina.parsear('''
Día 1: Pecho y espalda
Press banca inclinado 4 x 12
Dominadas al fallo
Aperturas inclinadas 3x12
Jalón tras nuca 3 x 12
Dominadas al fallo
Remo con barra 3 x 12
''');

      expect(resultado.dias, hasLength(1));
      expect(resultado.dias.single.ejercicios, hasLength(6));
    });
  });

  group('ImportadorRutina.buscarCoincidencia', () {
    test('match exacto', () {
      final catalogo = [ejercicio(1, 'Sentadilla')];
      final match = ImportadorRutina.buscarCoincidencia('Sentadilla', catalogo);
      expect(match?.id, 1);
    });

    test('match insensible a mayúsculas y acentos', () {
      final catalogo = [ejercicio(1, 'Sentadilla')];
      final match = ImportadorRutina.buscarCoincidencia('sentadílla', catalogo);
      expect(match?.id, 1);
    });

    test('match por typo vía distancia de edición', () {
      final catalogo = [ejercicio(1, 'Sentadilla')];
      final match = ImportadorRutina.buscarCoincidencia('sentadila', catalogo);
      expect(match?.id, 1);
    });

    test('match por variante de redacción vía solapamiento de palabras', () {
      final catalogo = [ejercicio(1, 'Press de banca (barra)')];
      final match = ImportadorRutina.buscarCoincidencia('Press banca', catalogo);
      expect(match?.id, 1);
    });

    test('el guardrail evita fusionar un nombre corto con una variante '
        'distinta mucho más larga', () {
      final catalogo = [
        ejercicio(1, 'Press banca inclinado con mancuernas'),
      ];
      final match = ImportadorRutina.buscarCoincidencia('Press banca', catalogo);
      expect(match, isNull);
    });

    test('sin coincidencia suficiente retorna null', () {
      final catalogo = [ejercicio(1, 'Sentadilla')];
      final match =
          ImportadorRutina.buscarCoincidencia('Press militar', catalogo);
      expect(match, isNull);
    });

    test('match por variante de plural y orden de palabras (via stemming)',
        () {
      final catalogo = [ejercicio(1, 'Curl de bíceps con mancuernas')];
      final match =
          ImportadorRutina.buscarCoincidencia('Curls mancuerna biceps', catalogo);
      expect(match?.id, 1);
    });

    test(
        'el guardrail de grupo muscular evita confundir tríceps con '
        'cuádriceps aunque el texto se parezca mucho', () {
      // Antes de este guardrail, la sola distancia de edición entre
      // "extension de triceps" y "extension de cuadriceps" (comparten el
      // sufijo "riceps") cruzaba el umbral y las fusionaba por error.
      final catalogo = [ejercicio(1, 'Extensión de cuádriceps')];
      final match = ImportadorRutina.buscarCoincidencia(
          'Extensión de tríceps', catalogo);
      expect(match, isNull);
    });

    test(
        'el guardrail de ángulo evita confundir press inclinado con press '
        'declinado aunque casi todo el texto sea igual', () {
      final catalogo = [ejercicio(1, 'Press banca declinado')];
      final match = ImportadorRutina.buscarCoincidencia(
          'Press banca inclinado', catalogo);
      expect(match, isNull);
    });

    test(
        'el guardrail de grupo muscular no bloquea cuando ambos nombres '
        'mencionan el mismo músculo', () {
      final catalogo = [
        ejercicio(1, 'Extensión de tríceps en polea alta con cuerda'),
      ];
      final match = ImportadorRutina.buscarCoincidencia(
          'Extension triceps polea cuerda', catalogo);
      expect(match?.id, 1);
    });
  });
}
