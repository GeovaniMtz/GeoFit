import 'package:flutter/material.dart';

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
    this.tamano = 56,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grande = tamano >= 56;
    return SizedBox(
      width: tamano,
      height: tamano,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: colorScheme.surfaceContainerHigh,
          disabledBackgroundColor: colorScheme.surfaceContainerHigh,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(grande ? 14 : 10),
          ),
        ),
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icono,
            size: grande ? 26 : 18,
            color: onPressed == null
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
