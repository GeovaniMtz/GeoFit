import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../anillo.dart';

/// La "consola" de la serie actual: un anillo que se llena con las series
/// hechas y, al centro, el peso en grande con su unidad y las reps; debajo
/// los −/+ de peso y de reps en dos píldoras, y el selector de RPE. Solo
/// dibuja y reenvía los toques; si [habilitada] es false se apagan.
class ConsolaPesoReps extends StatelessWidget {
  final int numeroSet;
  final int totalSeries;
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
    required this.numeroSet,
    required this.totalSeries,
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
    final completas = numeroSet > totalSeries;
    final serieMostrada = completas ? totalSeries : numeroSet;
    final hechas = (numeroSet - 1).clamp(0, totalSeries);

    return Column(
      children: [
        Center(
          child: AnillosProgreso(
            tamano: 240,
            grosor: 18,
            etiquetaSemantica: 'Serie $serieMostrada de $totalSeries',
            anillos: [
              Anillo(
                valor: totalSeries == 0 ? 0 : hechas / totalSeries,
                color: colorScheme.primary,
                pista: GeoLiftExtra.of(context).pistaAcento,
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SERIE $serieMostrada/$totalSeries',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                // "137.5LB" a 60 puntos no cabe dentro del anillo: se encoge
                // lo necesario para no desbordarse.
                SizedBox(
                  width: 184,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: NumeroConUnidad(
                      pesoTexto,
                      unidad: unidadEtiqueta,
                      tamano: 60,
                      colorUnidad: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('× ',
                        style: estiloNumero(22,
                            color: colorScheme.onSurfaceVariant)),
                    Text('$reps', style: estiloNumero(22)),
                    Text(' REPS',
                        style: estiloNumero(13,
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GeoLiftSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _PildoraStepper(
                etiqueta: 'PESO',
                tooltipMenos: 'Restar peso',
                tooltipMas: 'Sumar peso',
                onMenos: habilitada ? onBajarPeso : null,
                onMas: habilitada ? onSubirPeso : null,
              ),
            ),
            const SizedBox(width: GeoLiftSpacing.md),
            Expanded(
              child: _PildoraStepper(
                etiqueta: 'REPS',
                tooltipMenos: 'Restar repeticiones',
                tooltipMas: 'Sumar repeticiones',
                onMenos: habilitada ? onBajarReps : null,
                onMas: habilitada ? onSubirReps : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: GeoLiftSpacing.md),
        SelectorRpe(valor: rpe, onCambio: habilitada ? onElegirRpe : null),
      ],
    );
  }
}

/// − ETIQUETA + dentro de una píldora, pensada para el pulgar.
class _PildoraStepper extends StatelessWidget {
  final String etiqueta;
  final String tooltipMenos;
  final String tooltipMas;
  final VoidCallback? onMenos;
  final VoidCallback? onMas;

  const _PildoraStepper({
    required this.etiqueta,
    required this.tooltipMenos,
    required this.tooltipMas,
    required this.onMenos,
    required this.onMas,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final estiloBoton = IconButton.styleFrom(
      backgroundColor: colorScheme.surfaceContainerHighest,
      minimumSize: const Size(52, 52),
    );
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerLow,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenos,
            tooltip: tooltipMenos,
            style: estiloBoton,
            icon: const Icon(Icons.remove_rounded, size: 26),
          ),
          Expanded(
            child: Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
            ),
          ),
          IconButton(
            onPressed: onMas,
            tooltip: tooltipMas,
            style: estiloBoton,
            icon: const Icon(Icons.add_rounded, size: 26),
          ),
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
          child: SizedBox(
            width: 40,
            child: Text('RPE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    )),
          ),
        ),
        for (var i = 0; i < _valores.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Tooltip(
                message: _descripciones[i],
                child: Material(
                  color: valor == _valores[i]
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerLow,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onCambio == null
                        ? null
                        : () => onCambio!(
                            valor == _valores[i] ? null : _valores[i]),
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          _valores[i].toStringAsFixed(0),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
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
