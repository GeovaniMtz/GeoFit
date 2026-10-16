import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../providers/providers.dart';

import 'ajustes_screen.dart';
import 'historial_screen.dart';
import 'home_screen.dart';
import 'progreso_screen.dart';
import 'rutinas_screen.dart';

/// Cascarón con navegación inferior entre las 5 secciones principales.
/// Los sub-flujos (crear rutina, entrenar, editar) se navegan con go_router
/// por encima de este shell.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  int _indice = 0;

  /// Pestañas que ya se visitaron al menos una vez. Solo esas se construyen
  /// de verdad dentro del IndexedStack: las demás quedan en blanco hasta que
  /// se les da tap, para no disparar en el arranque las consultas de las 5
  /// pantallas al mismo tiempo (todas compiten por la misma conexión a la
  /// base de datos, y eso retrasa justo la de Inicio, la que sí se ve).
  final Set<int> _visitadas = {0};

  /// Fade through entre pestañas: se apaga la pestaña actual y luego se
  /// enciende la nueva, en vez del corte seco de un IndexedStack a secas.
  /// El índice solo cambia cuando ya está todo invisible (ver
  /// [_irAPantalla]), así que el salto de contenido nunca se alcanza a ver.
  late final _controladorFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  )..value = 1;

  static const _pantallas = [
    HomeScreen(),
    RutinasScreen(),
    ProgresoScreen(),
    HistorialScreen(),
    AjustesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Tras el primer cuadro, para no competir con las consultas de Inicio.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => unawaited(_respaldoAutomatico()));
  }

  /// Crea el respaldo semanal si ya toca. Nunca debe tumbar la app: si
  /// falla (sin espacio, sin permiso…) se intenta la próxima vez que se abra.
  Future<void> _respaldoAutomatico() async {
    try {
      final auto = await ref.read(respaldoAutomaticoProvider.future);
      final creado = await auto.respaldarSiToca(ref.read(databaseProvider));
      if (creado != null && mounted) {
        ref.invalidate(estadoRespaldoAutomaticoProvider);
      }
    } catch (_) {}
  }

  Future<void> _irAPantalla(int i) async {
    if (i == _indice) return;
    await _controladorFade.reverse();
    if (!mounted) return;
    setState(() {
      _indice = i;
      _visitadas.add(i);
    });
    await _controladorFade.forward();
  }

  @override
  void dispose() {
    _controladorFade.dispose();
    super.dispose();
  }

  static const _secciones = [
    (icono: Icons.radio_button_checked_rounded, etiqueta: 'Inicio'),
    (icono: Icons.format_list_bulleted_rounded, etiqueta: 'Rutinas'),
    (icono: Icons.insights_rounded, etiqueta: 'Progreso'),
    (icono: Icons.history_rounded, etiqueta: 'Historial'),
    (icono: Icons.tune_rounded, etiqueta: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _controladorFade,
            child: IndexedStack(
              index: _indice,
              children: [
                for (var i = 0; i < _pantallas.length; i++)
                  _visitadas.contains(i)
                      ? _pantallas[i]
                      : const SizedBox.shrink(),
              ],
            ),
          ),
          // La barra flota sobre el contenido (las pantallas dejan
          // GeoLiftSpacing.bajoBarra de espacio al final para no taparse).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: GeoLiftSpacing.md),
                child: Center(
                  child: _BarraFlotante(
                    secciones: _secciones,
                    indice: _indice,
                    onElegir: _irAPantalla,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación en forma de píldora que flota sobre el contenido:
/// la sección activa muestra ícono y nombre; las demás solo el ícono (su
/// nombre queda en el tooltip y para lectores de pantalla).
class _BarraFlotante extends StatelessWidget {
  final List<({IconData icono, String etiqueta})> secciones;
  final int indice;
  final ValueChanged<int> onElegir;

  const _BarraFlotante({
    required this.secciones,
    required this.indice,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.96),
      shape: const StadiumBorder(),
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < secciones.length; i++)
              _ItemBarra(
                icono: secciones[i].icono,
                etiqueta: secciones[i].etiqueta,
                activo: i == indice,
                onTap: () => onElegir(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ItemBarra({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = activo ? colorScheme.secondary : colorScheme.onSurfaceVariant;
    return Tooltip(
      message: etiqueta,
      child: Semantics(
        button: true,
        selected: activo,
        label: etiqueta,
        excludeSemantics: true,
        child: Material(
          color:
              activo ? colorScheme.surfaceContainerHighest : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: activo ? 16 : 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, color: color, size: 24),
                  if (activo) ...[
                    const SizedBox(width: 6),
                    Text(
                      etiqueta,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
