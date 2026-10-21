import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../domain/planificador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';
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
    final ruta = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              GeoLiftSpacing.page, 0, GeoLiftSpacing.page, GeoLiftSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nueva rutina',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: GeoLiftSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _OpcionOrigen(
                      icono: Icons.edit_note_rounded,
                      texto: 'Crear manualmente',
                      onTap: () => Navigator.pop(context, '/rutinas/nueva'),
                    ),
                  ),
                  const SizedBox(width: GeoLiftSpacing.md),
                  Expanded(
                    child: _OpcionOrigen(
                      icono: Icons.document_scanner_outlined,
                      texto: 'Importar desde texto',
                      onTap: () => Navigator.pop(context, '/rutinas/importar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      // Subido para quedar por encima de la barra de navegación flotante.
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton(
          onPressed: () => _elegirOrigenDeRutina(context),
          tooltip: 'Nueva rutina',
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: rutinas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => EstadoError(
          onReintentar: () => ref.invalidate(rutinasActivasProvider),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const EstadoVacio(
              icono: Icons.view_list_rounded,
              titulo: 'Sin rutinas todavía',
              detalle: 'Toca el botón + para crear la primera.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                GeoLiftSpacing.page,
                GeoLiftSpacing.sm,
                GeoLiftSpacing.page,
                GeoLiftSpacing.bajoBarra + 72),
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: GeoLiftSpacing.md),
            itemBuilder: (context, i) {
              final rutina = lista[i];
              return Card(
                child: InkWell(
                  onTap: () =>
                      _abrirFormulario(context, '/rutinas/${rutina.id}/editar'),
                  child: Padding(
                    padding: const EdgeInsets.all(GeoLiftSpacing.lg),
                    child: Row(
                      children: [
                        _Monograma(nombre: rutina.nombre),
                        const SizedBox(width: GeoLiftSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rutina.nombre,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: GeoLiftSpacing.xs),
                              _ResumenDeDias(rutinaId: rutina.id),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ],
                    ),
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

/// Inicial de la rutina en un cuadro de acento: le da a cada tarjeta un
/// ancla visual sin tener que inventar un ícono por rutina.
class _Monograma extends StatelessWidget {
  final String nombre;
  const _Monograma({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inicial =
        nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
      ),
      child: Text(
        inicial,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}

class _OpcionOrigen extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  const _OpcionOrigen(
      {required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeoLiftRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GeoLiftSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoEnCaja(icono),
              const SizedBox(height: GeoLiftSpacing.md),
              Text(texto,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
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
    final estilo = Theme.of(context).textTheme.bodySmall;

    return dias.when(
      loading: () => Text('Cargando días…', style: estilo),
      error: (e, _) => Text('No se pudo cargar.', style: estilo),
      data: (lista) {
        if (lista.isEmpty) return Text('Sin días configurados', style: estilo);

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
                style: estilo?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Text(resumen,
                style: estilo, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        );
      },
    );
  }
}
