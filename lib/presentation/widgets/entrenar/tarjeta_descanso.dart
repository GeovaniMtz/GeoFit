import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Cuenta regresiva del descanso entre series, con una barra que se va
/// vaciando. Tocarla termina el descanso antes de tiempo.
class TarjetaDescanso extends StatelessWidget {
  final int restantes;
  final int total;
  final VoidCallback onSaltar;

  const TarjetaDescanso({
    super.key,
    required this.restantes,
    required this.total,
    required this.onSaltar,
  });

  static String formatearTiempo(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraccion = total <= 0 ? 0.0 : (restantes / total).clamp(0.0, 1.0);
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
        onTap: onSaltar,
        child: Padding(
          padding: const EdgeInsets.all(GeoLiftSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: colorScheme.primary),
                  const SizedBox(width: GeoLiftSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DESCANSO',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: colorScheme.primary)),
                        Text('Toca para saltar',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    formatearTiempo(restantes),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: GeoLiftSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                child: LinearProgressIndicator(
                  value: fraccion,
                  minHeight: 6,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
