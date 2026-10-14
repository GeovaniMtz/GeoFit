import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(temaControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
            GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xl),
        children: [
          const EncabezadoSeccion('Apariencia'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(GeoLiftSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Claro, oscuro o lo que diga el sistema.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: GeoLiftSpacing.lg),
                  // Solo íconos: sol, luna y "auto" se entienden solos. El
                  // nombre de cada opción queda en su tooltip.
                  SegmentedButton<TemaApp>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TemaApp.sistema,
                        tooltip: 'Sistema',
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: TemaApp.claro,
                        tooltip: 'Claro',
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: TemaApp.oscuro,
                        tooltip: 'Oscuro',
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {tema},
                    onSelectionChanged: (seleccion) {
                      ref
                          .read(temaControllerProvider.notifier)
                          .cambiarTema(seleccion.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GeoLiftSpacing.xxl),
          const EncabezadoSeccion('Acerca de'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(GeoLiftSpacing.page),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconoEnCaja(Icons.fitness_center_rounded),
                  const SizedBox(width: GeoLiftSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GeoLift',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: GeoLiftSpacing.xs),
                        Text(
                          'Registra tus rutinas, tus pesos y tu progreso — y '
                          'recibe sugerencias de cuándo subir peso o bajar la '
                          'carga.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
