import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Un anillo de progreso con puntas redondas (como los de actividad de
/// Google Fit / Apple Fitness), dibujado sobre su pista apagada.
class Anillo {
  /// 0 a 1; se recorta a ese rango.
  final double valor;
  final Color color;
  final Color pista;

  const Anillo({required this.valor, required this.color, required this.pista});
}

/// Uno o varios anillos concéntricos (el primero por fuera) con [child] al
/// centro. El progreso se anima al cambiar.
class AnillosProgreso extends StatelessWidget {
  final List<Anillo> anillos;
  final double tamano;
  final double grosor;

  /// Espacio entre un anillo y el siguiente hacia dentro.
  final double separacion;
  final Widget? child;
  final String? etiquetaSemantica;

  const AnillosProgreso({
    super.key,
    required this.anillos,
    required this.tamano,
    this.grosor = 16,
    this.separacion = 6,
    this.child,
    this.etiquetaSemantica,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: etiquetaSemantica,
      child: SizedBox.square(
        dimension: tamano,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => CustomPaint(
            painter: _PintorAnillos(
              anillos: anillos,
              grosor: grosor,
              separacion: separacion,
              avance: t,
            ),
            child: child,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PintorAnillos extends CustomPainter {
  final List<Anillo> anillos;
  final double grosor;
  final double separacion;
  final double avance;

  _PintorAnillos({
    required this.anillos,
    required this.grosor,
    required this.separacion,
    required this.avance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    var radio = size.shortestSide / 2 - grosor / 2;
    for (final anillo in anillos) {
      final pista = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..color = anillo.pista;
      canvas.drawCircle(centro, radio, pista);

      final valor = anillo.valor.clamp(0.0, 1.0) * avance;
      if (valor > 0) {
        final arco = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor
          ..strokeCap = StrokeCap.round
          ..color = anillo.color;
        canvas.drawArc(
          Rect.fromCircle(center: centro, radius: radio),
          -math.pi / 2,
          2 * math.pi * valor,
          false,
          arco,
        );
      }
      radio -= grosor + separacion;
    }
  }

  @override
  bool shouldRepaint(_PintorAnillos old) =>
      old.avance != avance ||
      old.grosor != grosor ||
      old.separacion != separacion ||
      old.anillos.length != anillos.length ||
      Iterable.generate(anillos.length).any((i) =>
          old.anillos[i].valor != anillos[i].valor ||
          old.anillos[i].color != anillos[i].color);
}

/// Un número grande con su unidad chiquita pegada: "62.5KG", "52MIN".
/// Son dos textos separados (número y unidad) para que cada uno tenga su
/// tamaño y se puedan encontrar por separado.
class NumeroConUnidad extends StatelessWidget {
  final String numero;
  final String? unidad;
  final double tamano;
  final Color? color;
  final Color? colorUnidad;

  const NumeroConUnidad(
    this.numero, {
    super.key,
    this.unidad,
    required this.tamano,
    this.color,
    this.colorUnidad,
  });

  @override
  Widget build(BuildContext context) {
    final colorNumero = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(numero, style: estiloNumero(tamano, color: colorNumero)),
        if (unidad != null)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              unidad!,
              style: estiloNumero(tamano * 0.42,
                  color: colorUnidad ?? colorNumero),
            ),
          ),
      ],
    );
  }
}
