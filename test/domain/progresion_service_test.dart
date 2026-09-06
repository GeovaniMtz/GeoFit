import 'package:flutter_test/flutter_test.dart';
import 'package:geolift/domain/progresion_service.dart';

void main() {
  final servicio = ProgresionService();

  SerieRealizada serie(int reps,
          {int min = 8, int max = 12, double peso = 60}) =>
      SerieRealizada(
        peso: peso,
        reps: reps,
        repsMinObjetivo: min,
        repsMaxObjetivo: max,
      );

  group('ProgresionService.evaluar', () {
    test('sugiere subir peso tras 2 sesiones al tope del rango', () {
      final sesiones = [
        [serie(12), serie(12), serie(12)],
        [serie(12), serie(12), serie(12)],
      ];

      final sugerencia = servicio.evaluar(sesiones, esTrenInferior: false);

      expect(sugerencia.tipo, TipoSugerencia.subirPeso);
      expect(sugerencia.incrementoKg, ProgresionService.incrementoTrenSuperior);
    });

    test('usa el incremento de tren inferior cuando corresponde', () {
      final sesiones = [
        [serie(12), serie(12)],
        [serie(12), serie(12)],
      ];

      final sugerencia = servicio.evaluar(sesiones, esTrenInferior: true);

      expect(sugerencia.incrementoKg, ProgresionService.incrementoTrenInferior);
    });

    test('sugiere deload tras fallar el mínimo 2 sesiones seguidas', () {
      final sesiones = [
        [serie(5), serie(6)],
        [serie(4), serie(5)],
      ];

      final sugerencia = servicio.evaluar(sesiones, esTrenInferior: false);

      expect(sugerencia.tipo, TipoSugerencia.deload);
    });

    test('no sugiere nada con rendimiento mixto', () {
      final sesiones = [
        [serie(10), serie(9)],
        [serie(8), serie(9)],
      ];

      final sugerencia = servicio.evaluar(sesiones, esTrenInferior: false);

      expect(sugerencia.tipo, TipoSugerencia.ninguna);
    });

    test('no sugiere nada sin suficiente historial', () {
      final sugerencia = servicio.evaluar([
        [serie(12)]
      ], esTrenInferior: false);

      expect(sugerencia.tipo, TipoSugerencia.ninguna);
    });
  });

  test('e1rm usa la fórmula de Epley', () {
    expect(servicio.e1rm(100, 10), closeTo(133.33, 0.01));
    expect(servicio.e1rm(100, 1), closeTo(103.33, 0.01));
  });

  test('pesoDeDeload aplica el 90%', () {
    expect(servicio.pesoDeDeload(100), 90.0);
  });

  test('volumen suma reps x peso de cada serie', () {
    final series = [serie(10, peso: 50), serie(8, peso: 55)];
    expect(servicio.volumen(series), 10 * 50 + 8 * 55);
  });

  group('esNuevoPr', () {
    test('es PR si no hay historial previo', () {
      expect(
        servicio.esNuevoPr(e1rmNuevo: 100, e1rmMaximoPrevio: null),
        isTrue,
      );
    });

    test('es PR solo si supera el máximo histórico', () {
      expect(
        servicio.esNuevoPr(e1rmNuevo: 110, e1rmMaximoPrevio: 105),
        isTrue,
      );
      expect(
        servicio.esNuevoPr(e1rmNuevo: 100, e1rmMaximoPrevio: 105),
        isFalse,
      );
    });
  });
}
