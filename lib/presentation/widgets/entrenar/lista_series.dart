import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/unidad_peso.dart';
import '../../controllers/ejercicio_controller.dart';
import '../comunes.dart';

/// Series ya registradas hoy en este ejercicio, la más reciente arriba:
/// "Serie 2 · 60 kg × 8  @8".
class ListaSeries extends StatelessWidget {
  final List<SerieRegistrada> series;
  final UnidadPeso unidad;

  const ListaSeries({super.key, required this.series, required this.unidad});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EncabezadoSeccion('Sets registrados'),
        for (final s in series)
          Padding(
            padding: const EdgeInsets.only(bottom: GeoLiftSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: GeoLiftSpacing.lg, vertical: GeoLiftSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(GeoLiftRadius.md),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: colorScheme.secondary),
                  const SizedBox(width: GeoLiftSpacing.md),
                  Expanded(
                    child: Text('Serie ${s.numeroSet}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Text(
                    '${unidad.formatear(s.pesoKg)} ${unidad.name} × ${s.reps}'
                    '${s.rpe == null ? '' : '  @${s.rpe!.toStringAsFixed(0)}'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
