import 'package:flutter/material.dart';

/// Estado de error genérico para pantallas que dependen de datos async: en
/// vez de mostrar la excepción cruda, un mensaje amigable y (si aplica) un
/// botón para reintentar releyendo el provider que falló.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const EstadoError({
    super.key,
    this.mensaje = 'Algo salió mal. Intenta de nuevo.',
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onReintentar,
                child: const Text('REINTENTAR'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
