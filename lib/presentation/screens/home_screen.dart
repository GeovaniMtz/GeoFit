import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../domain/planificador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/estado_error.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasActivasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GeoLift')),
      body: Column(
        children: [
          const _EncabezadoDeHoy(),
          Expanded(
            child: rutinas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => EstadoError(
                onReintentar: () => ref.invalidate(rutinasActivasProvider),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return const _SinRutinas();
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    Text('TUS RUTINAS ACTIVAS',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 12),
                    for (final rutina in lista) _TarjetaRutina(rutina: rutina),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EncabezadoDeHoy extends StatelessWidget {
  const _EncabezadoDeHoy();

  @override
  Widget build(BuildContext context) {
    final texto = _capitalizar(
      DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now()),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Hoy es $texto',
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}

class _SinRutinas extends StatelessWidget {
  const _SinRutinas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            const Text('Todavía no tienes una rutina.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final resultado = await context.push<String>('/rutinas/nueva');
                if (resultado == 'guardado' && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rutina guardada.')),
                  );
                }
              },
              child: const Text('CREAR MI PRIMERA RUTINA'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cada rutina calcula por su cuenta cuál de sus días toca a continuación
/// (rotando a partir del último que se entrenó — ver [diaQueToca], la misma
/// lógica que usa la pantalla de Rutinas), y lo marca con una etiqueta
/// "SIGUIENTE". No está atado a la fecha de calendario: si todavía no se ha
/// entrenado ningún día, el primero se marca como siguiente aunque el
/// usuario no vaya a empezar hoy. El resto de los días conserva su propio
/// botón para poder entrenar cualquiera.
class _TarjetaRutina extends ConsumerWidget {
  final Rutina rutina;
  const _TarjetaRutina({required this.rutina});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(diasDeRutinaProvider(rutina.id));
    final ultimoEntrenado = ref.watch(ultimoDiaEntrenadoProvider(rutina.id));
    final colorScheme = Theme.of(context).colorScheme;

    return dias.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('No se pudo cargar.'),
      ),
      data: (listaDias) {
        final diaDeHoy = ultimoEntrenado.maybeWhen(
          data: (ultimo) => diaQueToca(listaDias, ultimo),
          orElse: () => null,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rutina.nombre.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(height: 10),
              if (listaDias.isEmpty)
                Text('Sin días configurados todavía.',
                    style: Theme.of(context).textTheme.bodyMedium)
              else
                for (final dia in listaDias)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(dia.nombreDia,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              if (dia.id == diaDeHoy?.id) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SIGUIENTE',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.push('/entrenar/${dia.id}');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                colorScheme.primary.withValues(alpha: 0.14),
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          child: const Text('ENTRENAR'),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
