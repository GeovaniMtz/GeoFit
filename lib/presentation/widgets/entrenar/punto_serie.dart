import 'package:flutter/material.dart';

enum EstadoPunto { pendiente, actual, hecho }

/// Un punto del indicador de progreso de series (p. ej. ●●○○ para 2 de 4
/// series hechas), con un estilo distinto para la serie actual.
class PuntoSerie extends StatelessWidget {
  final EstadoPunto estado;
  const PuntoSerie({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (estado) {
      case EstadoPunto.hecho:
        return Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
        );
      case EstadoPunto.actual:
        return Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
        );
      case EstadoPunto.pendiente:
        return Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
