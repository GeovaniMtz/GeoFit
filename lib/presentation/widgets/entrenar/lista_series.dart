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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EncabezadoSeccion('Sets registrados'),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < series.length; i++) ...[
                if (i > 0)
                  const Divider(indent: GeoLiftSpacing.lg, endIndent: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GeoLiftSpacing.lg,
                      vertical: GeoLiftSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: colorScheme.secondary),
                      const SizedBox(width: GeoLiftSpacing.md),
                      Expanded(
                        child: Text('Serie ${series[i].numeroSet}',
                            style: textTheme.bodyMedium),
                      ),
                      Text(
                        '${unidad.formatear(series[i].pesoKg)} ${unidad.name} × '
                        '${series[i].reps}'
                        '${series[i].rpe == null ? '' : '  @${series[i].rpe!.toStringAsFixed(0)}'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
