import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../domain/planificador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/estado_error.dart';

class RutinasScreen extends ConsumerWidget {
  const RutinasScreen({super.key});

  Future<void> _abrirFormulario(BuildContext context, String ruta) async {
    final resultado = await context.push<String>(ruta);
    if (!context.mounted) return;
    final mensaje = switch (resultado) {
      'guardado' => 'Rutina guardada.',
      'eliminado' => 'Rutina eliminada.',
      _ => null,
    };
    if (mensaje != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _elegirOrigenDeRutina(BuildContext context) async {
    final ruta = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Nueva rutina'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '/rutinas/nueva'),
            child: const ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Crear manualmente'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '/rutinas/importar'),
            child: const ListTile(
              leading: Icon(Icons.content_paste),
              title: Text('Importar desde texto'),
            ),
          ),
        ],
      ),
    );
    if (ruta == null || !context.mounted) return;
    await _abrirFormulario(context, ruta);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasActivasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _elegirOrigenDeRutina(context),
        icon: const Icon(Icons.add),
        label: const Text('NUEVA RUTINA'),
      ),
      body: rutinas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => EstadoError(
          onReintentar: () => ref.invalidate(rutinasActivasProvider),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Text('Crea tu primera rutina con el botón +'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final rutina = lista[i];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(rutina.nombre),
                  subtitle: _ResumenDeDias(rutinaId: rutina.id),
                  onTap: () =>
                      _abrirFormulario(context, '/rutinas/${rutina.id}/editar'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar rutina',
                    onPressed: () => _abrirFormulario(
                        context, '/rutinas/${rutina.id}/editar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Muestra los días configurados de la rutina y cuál de ellos toca hoy,
/// rotando a partir del último día que se entrenó (ver [diaQueToca]).
class _ResumenDeDias extends ConsumerWidget {
  final int rutinaId;
  const _ResumenDeDias({required this.rutinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(diasDeRutinaProvider(rutinaId));
    final ultimoEntrenado = ref.watch(ultimoDiaEntrenadoProvider(rutinaId));

    return dias.when(
      loading: () => const Text('Cargando días…'),
      error: (e, _) => const Text('No se pudo cargar.'),
      data: (lista) {
        if (lista.isEmpty) return const Text('Sin días configurados');

        final resumen = lista.map((RutinaDia d) => d.nombreDia).join(' · ');
        final diaDeHoy = ultimoEntrenado.maybeWhen(
          data: (ultimo) => diaQueToca(lista, ultimo),
          orElse: () => null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (diaDeHoy != null)
              Text(
                'Toca: ${diaDeHoy.nombreDia}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Text(resumen),
          ],
        );
      },
    );
  }
}
