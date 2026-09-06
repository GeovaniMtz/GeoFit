import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../widgets/estado_error.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiones = ref.watch(historialDeSesionesProvider);
    final formato = DateFormat('EEEE d MMMM, HH:mm', 'es');

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: sesiones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EstadoError(
          onReintentar: () => ref.invalidate(historialDeSesionesProvider),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Text('Todavía no has registrado ninguna sesión.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final resumen = lista[i];
              final fechaCapitalizada = _capitalizar(
                formato.format(resumen.sesion.fecha),
              );
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Icon(Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  title: Text(fechaCapitalizada),
                  subtitle: Text(
                    resumen.totalSets == 0
                        ? resumen.nombreDia
                        : '${resumen.nombreDia} · ${resumen.totalSets} '
                            'sets · ${resumen.volumenTotal.toStringAsFixed(0)} '
                            'kg volumen',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
