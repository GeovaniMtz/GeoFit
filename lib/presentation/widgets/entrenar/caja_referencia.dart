import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Muestra el peso y las reps de la sesión anterior para este ejercicio,
/// como referencia rápida mientras se registra la serie de hoy.
class CajaReferencia extends StatelessWidget {
  final String peso;
  final int reps;

  /// Unidad ya elegida por el usuario ("kg" / "lb"), para la etiqueta.
  final String unidad;
  const CajaReferencia({
    super.key,
    required this.peso,
    required this.reps,
    this.unidad = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GeoLiftSpacing.lg, vertical: GeoLiftSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'Sesión anterior: '),
                  TextSpan(
                    text: '$peso $unidad × $reps',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' reps'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
