import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/progresion_service.dart';

/// Qué hacer hoy con este ejercicio según las sesiones anteriores: subir
/// peso, mantenerlo o descargar. El peso ya viene precargado en los
/// controles; la tarjeta explica por qué.
class TarjetaSugerencia extends StatelessWidget {
  final Sugerencia sugerencia;
  final String pesoTexto;
  const TarjetaSugerencia(
      {super.key, required this.sugerencia, required this.pesoTexto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (IconData icono, Color color, String titulo) =
        switch (sugerencia.tipo) {
      TipoSugerencia.subirPeso => (
          Icons.trending_up_rounded,
          colorScheme.secondary,
          'Hoy sube a $pesoTexto',
        ),
      TipoSugerencia.mantener => (
          Icons.horizontal_rule_rounded,
          colorScheme.primary,
          'Hoy mantén $pesoTexto',
        ),
      TipoSugerencia.deload || TipoSugerencia.ninguna => (
          Icons.trending_down_rounded,
          colorScheme.error,
          'Hoy descarga a $pesoTexto',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(GeoLiftSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const SizedBox(width: GeoLiftSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: GeoLiftSpacing.xs),
                Text(sugerencia.motivo,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
