import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/domain/clasificador_ejercicio.dart';

void main() {
  group('ClasificadorEjercicio.esTrenInferior', () {
    test('usa el grupo muscular del catálogo', () {
      expect(
          ClasificadorEjercicio.esTrenInferior('Lo que sea',
              grupoMuscular: 'Pierna'),
          isTrue);
      expect(
          ClasificadorEjercicio.esTrenInferior('Lo que sea',
              grupoMuscular: 'Glúteo'),
          isTrue);
    });

    test('si el grupo no ayuda, decide por el nombre', () {
      expect(
          ClasificadorEjercicio.esTrenInferior('Sentadilla búlgara',
              grupoMuscular: 'Sin clasificar'),
          isTrue);
      expect(ClasificadorEjercicio.esTrenInferior('Prensa inclinada'), isTrue);
      expect(ClasificadorEjercicio.esTrenInferior('Hip thrust'), isTrue);
    });

    test('torso no es tren inferior', () {
      expect(
          ClasificadorEjercicio.esTrenInferior('Press de banca',
              grupoMuscular: 'Pecho'),
          isFalse);
      expect(ClasificadorEjercicio.esTrenInferior('Jalón al pecho'), isFalse);
    });
  });
}
