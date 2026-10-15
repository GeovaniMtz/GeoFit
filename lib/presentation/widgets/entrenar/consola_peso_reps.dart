import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import 'boton_stepper.dart';

/// La "consola" de la serie actual: peso al centro en grande, reps abajo,
/// ambos con steppers −/+ a los lados, y el selector de RPE. Solo dibuja y
/// reenvía los toques; si [habilitada] es false los controles se apagan.
class ConsolaPesoReps extends StatelessWidget {
  final String pesoTexto;
  final String unidadEtiqueta;
  final int reps;
  final double? rpe;
  final bool habilitada;
  final VoidCallback onSubirPeso;
  final VoidCallback onBajarPeso;
  final VoidCallback onSubirReps;
  final VoidCallback onBajarReps;
  final ValueChanged<double?> onElegirRpe;

  const ConsolaPesoReps({
    super.key,
    required this.pesoTexto,
    required this.unidadEtiqueta,
    required this.reps,
    required this.rpe,
    required this.habilitada,
    required this.onSubirPeso,
    required this.onBajarPeso,
    required this.onSubirReps,
    required this.onBajarReps,
    required this.onElegirRpe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(GeoLiftSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              BotonStepper(
                icono: Icons.remove_rounded,
                tooltip: 'Restar peso',
                onPressed: habilitada ? onBajarPeso : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(pesoTexto,
                        style: textTheme.displayMedium?.copyWith(height: 1.05)),
                    Text(unidadEtiqueta, style: textTheme.labelSmall),
                  ],
                ),
              ),
              BotonStepper(
                icono: Icons.add_rounded,
                tooltip: 'Sumar peso',
                onPressed: habilitada ? onSubirPeso : null,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: GeoLiftSpacing.lg),
            child: Divider(),
          ),
          Row(
            children: [
              BotonStepper(
                icono: Icons.remove_rounded,
                tamano: 48,
                tooltip: 'Restar repeticiones',
                onPressed: habilitada ? onBajarReps : null,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$reps', style: textTheme.headlineMedium),
                    const SizedBox(width: GeoLiftSpacing.sm),
                    Text('REPS', style: textTheme.labelSmall),
                  ],
                ),
              ),
              BotonStepper(
                icono: Icons.add_rounded,
                tamano: 48,
                tooltip: 'Sumar repeticiones',
                onPressed: habilitada ? onSubirReps : null,
              ),
            ],
          ),
          const SizedBox(height: GeoLiftSpacing.lg),
          SelectorRpe(valor: rpe, onCambio: habilitada ? onElegirRpe : null),
        ],
      ),
    );
  }
}

/// Esfuerzo percibido (RPE) de la serie: 6 = muy fácil … 10 = al fallo.
/// Es opcional — tocar el valor ya marcado lo desmarca.
class SelectorRpe extends StatelessWidget {
  final double? valor;
  final ValueChanged<double?>? onCambio;
  const SelectorRpe({super.key, required this.valor, required this.onCambio});

  static const _valores = [6.0, 7.0, 8.0, 9.0, 10.0];

  // Misma posición que en [_valores].
  static const _descripciones = [
    'RPE 6: podías hacer 4 o más reps extra',
    'RPE 7: te quedaban unas 3 reps',
    'RPE 8: te quedaban unas 2 reps',
    'RPE 9: te quedaba 1 rep',
    'RPE 10: al fallo, no salía otra',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Tooltip(
          message: 'Esfuerzo percibido (opcional)',
          child: Text('RPE', style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: GeoLiftSpacing.md),
        for (var i = 0; i < _valores.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Tooltip(
                message: _descripciones[i],
                child: Material(
                  color: valor == _valores[i]
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
                    onTap: onCambio == null
                        ? null
                        : () => onCambio!(
                            valor == _valores[i] ? null : _valores[i]),
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Text(
                          _valores[i].toStringAsFixed(0),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            color: valor == _valores[i]
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
