import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../data/database.dart';

/// Nombre del ejercicio, su objetivo (series, rango de reps, descanso) en
/// chips y, si hay, cuál sigue.
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre ?? 'Ejercicio',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: GeoLiftSpacing.md),
        Wrap(
          spacing: GeoLiftSpacing.sm,
          runSpacing: GeoLiftSpacing.sm,
          children: [
            _ChipObjetivo(
              icono: Icons.layers_outlined,
              texto: '${objetivo.seriesObjetivo} series',
            ),
            _ChipObjetivo(
              icono: Icons.repeat_rounded,
              texto: '${objetivo.repsMin}-${objetivo.repsMax} reps',
            ),
            _ChipObjetivo(
              icono: Icons.timer_outlined,
              texto: '${objetivo.descansoSeg}s',
            ),
          ],
        ),
        if (nombreProximo != null) ...[
          const SizedBox(height: GeoLiftSpacing.md),
          Row(
            children: [
              Icon(Icons.arrow_forward_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: GeoLiftSpacing.xs),
              Expanded(
                child: Text(
                  'Próximo ejercicio: $nombreProximo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Un dato del objetivo del ejercicio como chip con ícono, en vez de una
/// sola línea larga de texto.
class _ChipObjetivo extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipObjetivo({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: GeoLiftSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
