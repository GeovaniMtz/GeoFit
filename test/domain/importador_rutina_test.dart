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
  });
}
