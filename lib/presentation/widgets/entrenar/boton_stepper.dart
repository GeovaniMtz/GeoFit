import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Botón cuadrado +/- grande, pensado para tocarse con el pulgar mientras se
/// ajustan peso o reps entre series.
class BotonStepper extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onPressed;
  final double tamano;
  final String tooltip;
  const BotonStepper({
    super.key,
    required this.icono,
    required this.onPressed,
    this.tamano = 60,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grande = tamano >= 56;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: grande ? 30 : 22,
      style: IconButton.styleFrom(
        fixedSize: Size.square(tamano),
        minimumSize: Size.square(tamano),
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.onSurface,
        disabledBackgroundColor: colorScheme.surfaceContainerHigh,
        disabledForegroundColor:
            colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GeoLiftRadius.md),
        ),
      ),
      icon: Icon(icono),
    );
  }
}
