import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/detalle_sesion_screen.dart';
import '../presentation/screens/entrenar_screen.dart';
import '../presentation/screens/importar_rutina_screen.dart';
import '../presentation/screens/main_shell.dart';
import '../presentation/screens/rutina_form_screen.dart';
import '../presentation/widgets/rutina_form/borrador.dart';

/// "Entro un nivel más adentro": de una lista a su detalle/edición
/// (Rutinas → editar, Home → Entrenar).
CustomTransitionPage<T> _paginaDrillIn<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        fillColor: Theme.of(context).colorScheme.surface,
        child: child,
      );
    },
  );
}

/// "Estoy creando algo nuevo": sube desde abajo, como una hoja modal
/// (nueva rutina, importar rutina).
CustomTransitionPage<T> _paginaCrear<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.vertical,
        fillColor: Theme.of(context).colorScheme.surface,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/rutinas/nueva',
      pageBuilder: (context, state) => _paginaCrear(
        state,
        RutinaFormScreen(diasIniciales: state.extra as List<DiaBorrador>?),
      ),
    ),
    GoRoute(
      path: '/rutinas/importar',
      pageBuilder: (context, state) => _paginaCrear(
        state,
        const ImportarRutinaScreen(),
      ),
    ),
    GoRoute(
      path: '/rutinas/:id/editar',
      pageBuilder: (context, state) => _paginaDrillIn(
        state,
        RutinaFormScreen(rutinaId: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/historial/:sesionId',
      pageBuilder: (context, state) => _paginaDrillIn(
        state,
        DetalleSesionScreen(
          sesionId: int.parse(state.pathParameters['sesionId']!),
        ),
      ),
    ),
    GoRoute(
      path: '/entrenar/:rutinaDiaId',
      pageBuilder: (context, state) => _paginaDrillIn(
        state,
        EntrenarScreen(
          rutinaDiaId: int.parse(state.pathParameters['rutinaDiaId']!),
        ),
      ),
    ),
  ],
);
