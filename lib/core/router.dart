import 'package:go_router/go_router.dart';

import '../presentation/screens/entrenar_screen.dart';
import '../presentation/screens/importar_rutina_screen.dart';
import '../presentation/screens/main_shell.dart';
import '../presentation/screens/rutina_form_screen.dart';
import '../presentation/widgets/rutina_form/borrador.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/rutinas/nueva',
      builder: (context, state) => RutinaFormScreen(
        diasIniciales: state.extra as List<DiaBorrador>?,
      ),
    ),
    GoRoute(
      path: '/rutinas/importar',
      builder: (context, state) => const ImportarRutinaScreen(),
    ),
    GoRoute(
      path: '/rutinas/:id/editar',
      builder: (context, state) => RutinaFormScreen(
        rutinaId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/entrenar/:rutinaDiaId',
      builder: (context, state) => EntrenarScreen(
        rutinaDiaId: int.parse(state.pathParameters['rutinaDiaId']!),
      ),
    ),
  ],
);
