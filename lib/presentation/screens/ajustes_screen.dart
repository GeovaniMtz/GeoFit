import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(temaControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text('GeoLift',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Registra tus rutinas, tus pesos y tu progreso — y '
                  'recibe sugerencias de cuándo subir peso o bajar la '
                  'carga.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apariencia',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Elige si GeoLift se ve claro, oscuro, o sigue el ajuste '
                    'del sistema.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<TemaApp>(
                    segments: const [
                      ButtonSegment(
                        value: TemaApp.sistema,
                        label: Text('Sistema'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: TemaApp.claro,
                        label: Text('Claro'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: TemaApp.oscuro,
                        label: Text('Oscuro'),
                        icon: Icon(Icons.dark_mode_outlined),
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
        ],
      ),
    );
  }
}
