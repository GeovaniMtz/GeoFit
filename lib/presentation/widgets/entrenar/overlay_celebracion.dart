import 'package:flutter/material.dart';

/// Overlay que se muestra tras registrar la última serie de un ejercicio:
/// celebra brevemente y deja que se toque para adelantar el avance
/// automático (igual patrón que "toca para saltar" del descanso).
class OverlayCelebracion extends StatelessWidget {
  final bool esUltimoEjercicio;
  final String? nombreProximo;
  final VoidCallback onSaltar;

  const OverlayCelebracion({
    super.key,
    required this.esUltimoEjercicio,
    required this.nombreProximo,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onSaltar,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        builder: (context, opacidad, child) =>
            Opacity(opacity: opacidad, child: child),
        child: Container(
          color: colorScheme.surface.withValues(alpha: 0.97),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, valor, child) =>
                    Transform.scale(scale: valor, child: child),
                child: Icon(Icons.check_circle,
                    size: 72, color: colorScheme.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                esUltimoEjercicio
                    ? '¡Última serie hecha!'
                    : '¡Ejercicio completado!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (nombreProximo != null) ...[
                const SizedBox(height: 8),
                Text('Siguiente: $nombreProximo',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 20),
              Text('Toca para continuar',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
