import 'package:flutter/material.dart';

import 'ajustes_screen.dart';
import 'historial_screen.dart';
import 'home_screen.dart';
import 'progreso_screen.dart';
import 'rutinas_screen.dart';

/// Cascarón con navegación inferior entre las 5 secciones principales.
/// Los sub-flujos (crear rutina, entrenar, editar) se navegan con go_router
/// por encima de este shell.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
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
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _indice,
          onDestinationSelected: _irAPantalla,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Rutinas',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Progreso',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Historial',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
