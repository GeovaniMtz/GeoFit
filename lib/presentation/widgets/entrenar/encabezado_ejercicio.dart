import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../data/database.dart';

/// Nombre del ejercicio en grande, su objetivo en una línea ("4 × 8–12
/// reps · 90 s descanso") y, si hay, cuál sigue.
class EncabezadoEjercicio extends StatelessWidget {
  final String? nombre;
  final RutinaEjercicio objetivo;
  final String? nombreProximo;

  const EncabezadoEjercicio({
    super.key,
    required this.nombre,
    required this.objetivo,
    required this.nombreProximo,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre ?? 'Ejercicio', style: textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(
          '${objetivo.seriesObjetivo} × ${objetivo.repsMin}–${objetivo.repsMax} '
          'reps · ${objetivo.descansoSeg} s descanso',
          style: textTheme.bodyMedium,
        ),
        if (nombreProximo != null) ...[
          const SizedBox(height: GeoLiftSpacing.xs),
          Row(
            children: [
              Icon(Icons.arrow_forward_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: GeoLiftSpacing.xs),
              Expanded(
                child: Text(
                  'Próximo ejercicio: $nombreProximo',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
