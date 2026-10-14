import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../domain/planificador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';
import '../widgets/estado_error.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasActivasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GeoLift')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
                      GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xl),
                  children: [
                    const EncabezadoSeccion('Tus rutinas activas'),
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
      padding: const EdgeInsets.fromLTRB(
          GeoLiftSpacing.page, 0, GeoLiftSpacing.page, GeoLiftSpacing.lg),
      child: Text(
        'Hoy es $texto',
        style: Theme.of(context)
            .textTheme
            .titleMedium
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
    return EstadoVacio(
      icono: Icons.fitness_center,
      titulo: 'Todavía no tienes una rutina.',
      detalle: 'Arma tus días y ejercicios una vez y aquí te dirá qué toca.',
      accion: FilledButton.icon(
        onPressed: () async {
          final resultado = await context.push<String>('/rutinas/nueva');
          if (resultado == 'guardado' && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rutina guardada.')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('CREAR MI PRIMERA RUTINA'),
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
/// botón de ▶ para poder entrenar cualquiera.
class _TarjetaRutina extends ConsumerWidget {
  final Rutina rutina;
  const _TarjetaRutina({required this.rutina});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(diasDeRutinaProvider(rutina.id));
    final ultimoEntrenado = ref.watch(ultimoDiaEntrenadoProvider(rutina.id));

    return dias.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: GeoLiftSpacing.lg),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => const Padding(
        padding: EdgeInsets.only(bottom: GeoLiftSpacing.lg),
        child: Text('No se pudo cargar.'),
      ),
      data: (listaDias) {
        final diaDeHoy = ultimoEntrenado.maybeWhen(
          data: (ultimo) => diaQueToca(listaDias, ultimo),
          orElse: () => null,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: GeoLiftSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.all(GeoLiftSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.md,
                      GeoLiftSpacing.md, GeoLiftSpacing.md, GeoLiftSpacing.sm),
                  child: Text(rutina.nombre,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                if (listaDias.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.md, 0,
                        GeoLiftSpacing.md, GeoLiftSpacing.md),
                    child: Text('Sin días configurados todavía.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  for (final dia in listaDias)
                    _FilaDia(dia: dia, esSiguiente: dia.id == diaDeHoy?.id),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Una fila por día: su nombre y un botón ▶ para entrenarlo. El día que
/// toca se resalta con fondo de acento y un ▶ relleno; los demás llevan un
/// ▶ discreto.
class _FilaDia extends StatelessWidget {
  final RutinaDia dia;
  final bool esSiguiente;
  const _FilaDia({required this.dia, required this.esSiguiente});

  void _entrenar(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.push('/entrenar/${dia.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tooltip = 'Entrenar ${dia.nombreDia}';

    return Padding(
      padding: const EdgeInsets.only(top: GeoLiftSpacing.xs),
      child: Material(
        color: esSiguiente
            ? colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(GeoLiftRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(GeoLiftRadius.md),
          onTap: () => _entrenar(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                GeoLiftSpacing.md, GeoLiftSpacing.sm, GeoLiftSpacing.sm,
                GeoLiftSpacing.sm),
            child: Row(
              children: [
                Flexible(
                  child: Text(dia.nombreDia,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (esSiguiente) ...[
                  const SizedBox(width: GeoLiftSpacing.sm),
                  const Etiqueta('SIGUIENTE'),
                ],
                const Spacer(),
                esSiguiente
                    ? IconButton.filled(
                        onPressed: () => _entrenar(context),
                        tooltip: tooltip,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                      )
                    : IconButton(
                        onPressed: () => _entrenar(context),
                        tooltip: tooltip,
                        style: IconButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
