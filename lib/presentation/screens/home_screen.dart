import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../domain/planificador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/anillo.dart';
import '../widgets/estado_error.dart';

final _miles = NumberFormat('#,##0');

/// Inicio: la semana de un vistazo (anillos de sesiones y volumen, métricas
/// y días entrenados), qué toca entrenar y lo último que se hizo.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasActivasProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: rutinas.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => EstadoError(
            onReintentar: () => ref.invalidate(rutinasActivasProvider),
          ),
          data: (lista) => ListView(
            padding: const EdgeInsets.fromLTRB(
                GeoLiftSpacing.page,
                GeoLiftSpacing.lg,
                GeoLiftSpacing.page,
                GeoLiftSpacing.bajoBarra),
            children: [
              const _Encabezado(),
              const SizedBox(height: GeoLiftSpacing.xl),
              const _AnillosSemana(),
              const SizedBox(height: GeoLiftSpacing.xl),
              const _MetricasSemana(),
              const SizedBox(height: GeoLiftSpacing.xl),
              if (lista.isEmpty)
                const _SinRutinas()
              else
                for (final rutina in lista) ...[
                  _TarjetaSiguiente(rutina: rutina),
                  const SizedBox(height: GeoLiftSpacing.md),
                ],
              const _TarjetaSemana(),
              const SizedBox(height: GeoLiftSpacing.md),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TarjetaUltimaSesion()),
                  SizedBox(width: GeoLiftSpacing.md),
                  Expanded(child: _TarjetaPesoCorporal()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Hoy" en grande, la fecha abajo.
class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GeoLiftSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoy', style: Theme.of(context).textTheme.displaySmall),
          Text(
            fecha[0].toUpperCase() + fecha.substring(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Anillo de fuera: sesiones de la semana contra la meta. Anillo de dentro:
/// volumen de la semana contra el de la semana pasada.
class _AnillosSemana extends ConsumerWidget {
  const _AnillosSemana();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenSemanaProvider).valueOrNull;
    final meta = ref.watch(metaSesionesSemanaProvider).valueOrNull ?? 4;
    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final extra = GeoLiftExtra.of(context);

    final sesiones = resumen?.sesiones ?? 0;
    final volumen = resumen?.volumenKg ?? 0;
    final anterior = resumen?.volumenSemanaAnteriorKg ?? 0;
    final progresoVolumen =
        anterior > 0 ? volumen / anterior : (volumen > 0 ? 1.0 : 0.0);

    return Column(
      children: [
        AnillosProgreso(
          tamano: 220,
          grosor: 18,
          etiquetaSemantica: '$sesiones de $meta sesiones esta semana',
          anillos: [
            Anillo(
                valor: sesiones / meta,
                color: colorScheme.primary,
                pista: extra.pistaAcento),
            Anillo(
                valor: progresoVolumen,
                color: colorScheme.secondary,
                pista: extra.pistaExito),
          ],
          // Ancho del hueco interior: el número se encoge antes de tocar los
          // anillos.
          child: SizedBox(
            width: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: NumeroConUnidad(
                    '$sesiones',
                    unidad: '/$meta',
                    tamano: 56,
                    color: colorScheme.primary,
                    colorUnidad: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: NumeroConUnidad(
                    _miles.format(unidad.desdeKg(volumen).round()),
                    unidad: unidad.etiqueta,
                    tamano: 20,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GeoLiftSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Leyenda(color: colorScheme.primary, texto: 'Sesiones'),
            const SizedBox(width: GeoLiftSpacing.lg),
            _Leyenda(
              color: colorScheme.secondary,
              texto: anterior > 0 ? 'Volumen vs. semana pasada' : 'Volumen',
            ),
          ],
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Series, PRs y tiempo entrenando de la semana.
class _MetricasSemana extends ConsumerWidget {
  const _MetricasSemana();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenSemanaProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;
    final minutos = (resumen?.segundos ?? 0) ~/ 60;

    Widget metrica(Widget valor, String etiqueta) => Expanded(
          child: Column(
            children: [
              valor,
              const SizedBox(height: 2),
              Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );

    return Row(
      children: [
        metrica(
            NumeroConUnidad('${resumen?.series ?? 0}', tamano: 26), 'series'),
        metrica(
            NumeroConUnidad('${resumen?.prs ?? 0}',
                tamano: 26, color: colorScheme.secondary),
            'PRs'),
        metrica(
          minutos >= 60
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NumeroConUnidad('${minutos ~/ 60}',
                        unidad: 'h', tamano: 26),
                    NumeroConUnidad('${minutos % 60}', unidad: 'm', tamano: 26),
                  ],
                )
              : NumeroConUnidad('$minutos', unidad: 'min', tamano: 26),
          'entrenando',
        ),
      ],
    );
  }
}

class _SinRutinas extends StatelessWidget {
  const _SinRutinas();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GeoLiftSpacing.xl),
        child: Column(
          children: [
            Text('Todavía no tienes una rutina.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: GeoLiftSpacing.sm),
            Text(
              'Arma tus días y ejercicios una vez y aquí te dirá qué toca.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: GeoLiftSpacing.lg),
            FilledButton.icon(
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
          ],
        ),
      ),
    );
  }
}

/// El día que toca de una rutina, con un ▶ grande para empezar, y los
/// demás días de la rutina como píldoras por si se quiere entrenar otro.
///
/// Qué día toca se calcula rotando a partir del último que se entrenó (ver
/// [diaQueToca], la misma lógica que la pantalla de Rutinas); no está atado
/// a la fecha de calendario.
class _TarjetaSiguiente extends ConsumerWidget {
  final Rutina rutina;
  const _TarjetaSiguiente({required this.rutina});

  void _entrenar(BuildContext context, RutinaDia dia) {
    HapticFeedback.mediumImpact();
    context.push('/entrenar/${dia.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(diasDeRutinaProvider(rutina.id)).valueOrNull;
    final ultimo = ref.watch(ultimoDiaEntrenadoProvider(rutina.id));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (dias == null) return const SizedBox.shrink();
    if (dias.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(GeoLiftSpacing.xl),
          child: Text('${rutina.nombre}: sin días configurados todavía.',
              style: textTheme.bodyMedium),
        ),
      );
    }

    final siguiente = ultimo.maybeWhen(
          data: (u) => diaQueToca(dias, u),
          orElse: () => null,
        ) ??
        dias.first;
    final otros = dias.where((d) => d.id != siguiente.id).toList();
    final ejercicios =
        ref.watch(ejerciciosDeDiaProvider(siguiente.id)).valueOrNull;

    return Card(
      child: InkWell(
        onTap: () => _entrenar(context, siguiente),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.xl,
              GeoLiftSpacing.lg, GeoLiftSpacing.lg, GeoLiftSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIGUIENTE',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(siguiente.nombreDia,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall),
                        Text(
                          ejercicios == null
                              ? rutina.nombre
                              : '${rutina.nombre} · ${ejercicios.length} '
                                  '${ejercicios.length == 1 ? 'ejercicio' : 'ejercicios'}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _entrenar(context, siguiente),
                    tooltip: 'Entrenar ${siguiente.nombreDia}',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(60, 60),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 32),
                  ),
                ],
              ),
              if (otros.isNotEmpty) ...[
                const SizedBox(height: GeoLiftSpacing.md),
                // Una sola fila que se desliza: con muchos días, o con
                // nombres largos ("Martes – Pierna completa (en la tarde)"),
                // no ocupa media pantalla ni se desborda.
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: otros.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: GeoLiftSpacing.sm),
                    itemBuilder: (context, i) {
                      final dia = otros[i];
                      return Tooltip(
                        message: 'Entrenar ${dia.nombreDia}',
                        child: Material(
                          color: colorScheme.surfaceContainerHigh,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () => _entrenar(context, dia),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 14, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded,
                                        size: 18,
                                        color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        dia.nombreDia,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Los 7 días de la semana con mini anillos: lleno = entrenado.
class _TarjetaSemana extends ConsumerWidget {
  const _TarjetaSemana();

  static const _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenSemanaProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;
    final extra = GeoLiftExtra.of(context);
    final hoy = DateTime.now().weekday;
    final inicio = resumen?.inicio;
    final rango = inicio == null
        ? ''
        : '${DateFormat('d', 'es').format(inicio)} – '
            '${DateFormat("d 'de' MMM", 'es').format(inicio.add(const Duration(days: 6)))}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GeoLiftSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Esta semana',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(rango, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: GeoLiftSpacing.md),
            Row(
              children: [
                for (var d = 1; d <= 7; d++)
                  Expanded(
                    child: Column(
                      children: [
                        AnillosProgreso(
                          tamano: 34,
                          grosor: 5,
                          anillos: [
                            Anillo(
                              valor:
                                  (resumen?.diasEntrenados.contains(d) ?? false)
                                      ? 1
                                      : 0,
                              color: colorScheme.primary,
                              pista: d == hoy
                                  ? extra.pistaExito
                                  : colorScheme.surfaceContainerHighest,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _letras[d - 1],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: d == hoy
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: d == hoy
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// La sesión más reciente; tocarla abre su detalle.
class _TarjetaUltimaSesion extends ConsumerWidget {
  const _TarjetaUltimaSesion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiones = ref.watch(historialDeSesionesProvider).valueOrNull;
    final ultima =
        (sesiones == null || sesiones.isEmpty) ? null : sesiones.first;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final minutos = (ultima?.sesion.duracionSeg ?? 0) ~/ 60;

    return _TarjetaChica(
      titulo: 'Último',
      onTap: ultima == null
          ? null
          : () => context.push('/historial/${ultima.sesion.id}'),
      child: ultima == null
          ? Text('Sin sesiones', style: textTheme.bodyMedium)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${ultima.nombreDia} · ${_haceCuanto(ultima.sesion.fecha)}',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: GeoLiftSpacing.sm),
                minutos > 0
                    ? NumeroConUnidad('$minutos',
                        unidad: 'MIN', tamano: 30, color: colorScheme.primary)
                    : NumeroConUnidad('${ultima.totalSets}',
                        unidad: 'SETS', tamano: 30, color: colorScheme.primary),
              ],
            ),
    );
  }

  static String _haceCuanto(DateTime fecha) {
    final hoy = DateTime.now();
    final dias = DateTime(hoy.year, hoy.month, hoy.day)
        .difference(DateTime(fecha.year, fecha.month, fecha.day))
        .inDays;
    return switch (dias) {
      0 => 'hoy',
      1 => 'ayer',
      _ => 'hace $dias días',
    };
  }
}

/// El último peso corporal y una mini gráfica de los anteriores.
class _TarjetaPesoCorporal extends ConsumerWidget {
  const _TarjetaPesoCorporal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registros = ref.watch(historialPesoCorporalProvider).valueOrNull;
    final unidad = ref.watch(unidadPesoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final extra = GeoLiftExtra.of(context);

    if (registros == null || registros.isEmpty) {
      return _TarjetaChica(
        titulo: 'Peso corporal',
        child: Text('Regístralo en Progreso',
            style: Theme.of(context).textTheme.bodySmall),
      );
    }

    final recientes = registros.length > 6
        ? registros.sublist(registros.length - 6)
        : registros;
    final pesos = recientes.map((r) => r.peso).toList();
    final minimo = pesos.reduce((a, b) => a < b ? a : b);
    final maximo = pesos.reduce((a, b) => a > b ? a : b);

    return _TarjetaChica(
      titulo: 'Peso corporal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumeroConUnidad(unidad.formatear(pesos.last),
              unidad: unidad.etiqueta,
              tamano: 30,
              color: colorScheme.secondary),
          const SizedBox(height: GeoLiftSpacing.sm),
          SizedBox(
            height: 26,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < pesos.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      width: 7,
                      height: maximo == minimo
                          ? 18
                          : 10 + 16 * (pesos[i] - minimo) / (maximo - minimo),
                      decoration: BoxDecoration(
                        color: i == pesos.length - 1
                            ? colorScheme.secondary
                            : extra.pistaExito,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaChica extends StatelessWidget {
  final String titulo;
  final Widget child;
  final VoidCallback? onTap;
  const _TarjetaChica({required this.titulo, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GeoLiftSpacing.lg),
          child: SizedBox(
            height: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
