import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/data/database.dart';
import 'package:geolift/domain/planificador_rutina.dart';

void main() {
  RutinaDia dia(int id, int orden) =>
      RutinaDia(id: id, rutinaId: 1, nombreDia: 'Día $orden', orden: orden);

  group('diaQueToca', () {
    test('sin días configurados no hay nada que tocar', () {
      expect(diaQueToca(const [], null), isNull);
    });

    test('sin historial le toca el primer día', () {
      final dias = [dia(1, 0), dia(2, 1), dia(3, 2)];
      expect(diaQueToca(dias, null)!.id, 1);
    });

    test('rota al siguiente día tras el último entrenado', () {
      final dias = [dia(1, 0), dia(2, 1), dia(3, 2)];
      expect(diaQueToca(dias, dia(1, 0))!.id, 2);
      expect(diaQueToca(dias, dia(2, 1))!.id, 3);
    });

    test('vuelve al primero tras completar la vuelta', () {
      final dias = [dia(1, 0), dia(2, 1), dia(3, 2)];
      expect(diaQueToca(dias, dia(3, 2))!.id, 1);
    });

    test('si el último entrenado ya no está en la rutina, vuelve al primero',
        () {
      final dias = [dia(1, 0), dia(2, 1)];
      expect(diaQueToca(dias, dia(99, 5))!.id, 1);
    });
  });
}
