import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animación de confeti para celebrar el fin de una rutina: partículas de
/// colores cayendo una sola vez. No hay paquete de confeti en el proyecto,
/// así que se dibuja a mano con [CustomPainter] en vez de sumar una
/// dependencia nueva solo para esto.
class ConfetiCelebracion extends StatefulWidget {
  const ConfetiCelebracion({super.key});

  @override
  State<ConfetiCelebracion> createState() => _ConfetiCelebracionState();
}

class _ConfetiCelebracionState extends State<ConfetiCelebracion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final List<_Particula> _particulas;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    final random = math.Random();
    _particulas = List.generate(50, (_) => _Particula(random));
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      const Color(0xFFFFC857),
      Theme.of(context).colorScheme.onSurface,
    ];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controlador,
        builder: (context, _) => CustomPaint(
          painter: _ConfetiPainter(
            particulas: _particulas,
            progreso: _controlador.value,
            colores: colores,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Parámetros aleatorios de una partícula, fijos por el resto de la
/// animación (se generan una vez en [initState], no en cada frame).
class _Particula {
  final double x;
  final double retraso;
  final double derivaAmplitud;
  final double derivaFase;
  final double velocidadGiro;
  final double giroInicial;
  final double tamano;
  final int colorIndice;
  final bool esCirculo;

  _Particula(math.Random random)
      : x = random.nextDouble(),
        retraso = random.nextDouble() * 0.25,
        derivaAmplitud = 14 + random.nextDouble() * 22,
        derivaFase = random.nextDouble() * math.pi * 2,
        velocidadGiro =
            (random.nextBool() ? 1 : -1) * (2 + random.nextDouble() * 4),
        giroInicial = random.nextDouble() * math.pi * 2,
        tamano = 5 + random.nextDouble() * 4,
        colorIndice = random.nextInt(4),
        esCirculo = random.nextBool();
}

class _ConfetiPainter extends CustomPainter {
  final List<_Particula> particulas;
  final double progreso;
  final List<Color> colores;

  _ConfetiPainter({
    required this.particulas,
    required this.progreso,
    required this.colores,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()..style = PaintingStyle.fill;

    for (final p in particulas) {
      final local = ((progreso - p.retraso) / (1 - p.retraso)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final caida = Curves.easeIn.transform(local);
      final y = -20 + caida * (size.height + 40);
      final x = p.x * size.width +
          math.sin(caida * math.pi * 2 + p.derivaFase) * p.derivaAmplitud;
      final opacidad = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      if (opacidad <= 0) continue;

      pintura.color = colores[p.colorIndice].withValues(alpha: opacidad);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.giroInicial + local * p.velocidadGiro * math.pi);
      if (p.esCirculo) {
        canvas.drawCircle(Offset.zero, p.tamano / 2, pintura);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.tamano,
            height: p.tamano * 1.7,
          ),
          pintura,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfetiPainter oldDelegate) =>
      oldDelegate.progreso != progreso;
}
