import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Título pequeño en mayúsculas que encabeza un bloque de contenido
/// ("TUS RUTINAS", "PESO CORPORAL"…), con una acción opcional a la derecha
/// — normalmente un botón de solo ícono.
class EncabezadoSeccion extends StatelessWidget {
  final String texto;
  final Widget? accion;
  const EncabezadoSeccion(this.texto, {super.key, this.accion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GeoLiftSpacing.md),
      child: SizedBox(
        height: accion == null ? null : 48,
        child: Row(
          children: [
            Expanded(
              child: Text(texto.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall),
            ),
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}

/// Etiqueta corta de estado (p. ej. "SIGUIENTE", "PR") en el color de
/// acento o en el que se le pase.
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color? color;
  const Etiqueta(this.texto, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: c,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Ícono dentro de un cuadro redondeado con fondo tenue del color dado.
/// Es el "avatar" común de filas y estados vacíos.
class IconoEnCaja extends StatelessWidget {
  final IconData icono;
  final double tamano;
  final Color? color;
  const IconoEnCaja(this.icono, {super.key, this.tamano = 44, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(
            tamano >= 64 ? GeoLiftRadius.lg : GeoLiftRadius.md),
      ),
      child: Icon(icono, color: c, size: tamano * 0.5),
    );
  }
}

/// Estado vacío común a todas las pantallas: ícono grande, un título, una
/// línea de ayuda y (opcional) la acción principal para salir de él.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final Widget? accion;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeoLiftSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoEnCaja(icono, tamano: 80),
            const SizedBox(height: GeoLiftSpacing.xl),
            Text(titulo,
                textAlign: TextAlign.center, style: textTheme.titleLarge),
            if (detalle != null) ...[
              const SizedBox(height: GeoLiftSpacing.sm),
              Text(detalle!,
                  textAlign: TextAlign.center, style: textTheme.bodyMedium),
            ],
            if (accion != null) ...[
              const SizedBox(height: GeoLiftSpacing.xl),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
