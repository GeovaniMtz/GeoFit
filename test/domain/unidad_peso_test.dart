import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/domain/unidad_peso.dart';

void main() {
  group('UnidadPeso', () {
    test('kg no convierte nada', () {
      expect(UnidadPeso.kg.desdeKg(60), 60);
      expect(UnidadPeso.kg.aKg(60), 60);
      expect(UnidadPeso.kg.formatear(60), '60');
      expect(UnidadPeso.kg.formatear(62.5), '62.5');
    });

    test('lb convierte ida y vuelta sin perder el valor', () {
      final kg = UnidadPeso.lb.aKg(135);
      expect(kg, closeTo(61.235, 0.001));
      expect(UnidadPeso.lb.desdeKg(kg), closeTo(135, 1e-9));
      expect(UnidadPeso.lb.formatear(kg), '135');
    });

    test('desdeKgRedondeado deja un valor cargable al cambiar de unidad', () {
      // 60 kg = 132.277 lb → 132.5
      expect(UnidadPeso.lb.desdeKgRedondeado(60), 132.5);
      // 100 lb = 45.359 kg → 45.5
      expect(UnidadPeso.kg.desdeKgRedondeado(UnidadPeso.lb.aKg(100)), 45.5);
    });

    test('paso y peso inicial dependen del sistema', () {
      expect(UnidadPeso.kg.paso, 2.5);
      expect(UnidadPeso.lb.paso, 5);
      expect(UnidadPeso.kg.pesoInicial, 20);
      expect(UnidadPeso.lb.pesoInicial, 45);
    });

    test('desdeTexto cae en kg ante cualquier valor desconocido', () {
      expect(UnidadPeso.desdeTexto('lb'), UnidadPeso.lb);
      expect(UnidadPeso.desdeTexto('kg'), UnidadPeso.kg);
      expect(UnidadPeso.desdeTexto(''), UnidadPeso.kg);
    });

    test('formatearConUnidad agrega la unidad en minúsculas', () {
      expect(UnidadPeso.kg.formatearConUnidad(80), '80 kg');
      expect(
          UnidadPeso.lb.formatearConUnidad(UnidadPeso.lb.aKg(225)), '225 lb');
    });
  });
}
