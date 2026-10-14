import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const ProviderScope(child: GeoLiftApp()));
}

class GeoLiftApp extends ConsumerWidget {
  const GeoLiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(temaControllerProvider);
    // Se carga la unidad de peso desde el arranque (no hasta la primera
    // pantalla que la use), para que Entrenar ya la tenga lista al abrir.
    ref.watch(unidadPesoProvider);
    return MaterialApp.router(
      title: 'GeoLift',
      debugShowCheckedModeBanner: false,
      theme: geoLiftLightTheme(),
      darkTheme: geoLiftDarkTheme(),
      themeMode: tema.modo,
      routerConfig: appRouter,
    );
  }
}
