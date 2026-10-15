import 'package:flutter/material.dart';

import 'punto_serie.dart';

/// Indicador de series del ejercicio (●●○○) con el texto "SERIE 2/4".
class ProgresoSeries extends StatelessWidget {
  final int numeroSet;
  final int totalSeries;

  const ProgresoSeries({
    super.key,
    required this.numeroSet,
    required this.totalSeries,
  });

  @override
  Widget build(BuildContext context) {
    final completas = numeroSet > totalSeries;
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 1; i <= totalSeries; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5),
                  child: PuntoSerie(
                    estado: i < numeroSet
                        ? EstadoPunto.hecho
                        : (i == numeroSet
                            ? EstadoPunto.actual
                            : EstadoPunto.pendiente),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SERIE ${completas ? totalSeries : numeroSet}/$totalSeries',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
