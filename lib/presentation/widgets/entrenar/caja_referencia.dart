import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Muestra el peso y las reps de la sesión anterior para este ejercicio,
/// como referencia rápida mientras se registra la serie de hoy.
class CajaReferencia extends StatelessWidget {
  final String peso;
  final int reps;
  const CajaReferencia({super.key, required this.peso, required this.reps});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GeoLiftSpacing.lg, vertical: GeoLiftSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
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
                    text: '$peso kg × $reps',
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
