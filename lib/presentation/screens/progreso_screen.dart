import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';
import '../widgets/estado_error.dart';

class ProgresoScreen extends ConsumerStatefulWidget {
  const ProgresoScreen({super.key});

  @override
  ConsumerState<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends ConsumerState<ProgresoScreen> {
  int? _ejercicioSeleccionado;

  Future<void> _registrarPesoCorporal(BuildContext context) async {
    final controlador = TextEditingController();
    final peso = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar peso corporal'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'kg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controlador.text.replaceAll(',', '.')),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (peso == null) return;
    await ref.read(databaseProvider).registrarPesoCorporal(peso);
    ref.invalidate(historialPesoCorporalProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosEnUso = ref.watch(ejerciciosEnUsoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: ejerciciosEnUso.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EstadoError(
          onReintentar: () => ref.invalidate(ejerciciosEnUsoProvider),
        ),
        data: (ejercicios) {
          if (ejercicios.isEmpty) {
            return const EstadoVacio(
              icono: Icons.show_chart_rounded,
              titulo: 'Aún no hay progreso que mostrar',
              detalle: 'Agrega ejercicios a una rutina y entrena para ver '
                  'tu progreso aquí.',
            );
          }
          // La lista puede reducirse en caliente (se archivó una rutina, se
          // quitó un ejercicio) mientras esta pantalla sigue viva de fondo,
          // así que no basta con fijar la selección una sola vez.
          if (_ejercicioSeleccionado == null ||
              !ejercicios.any((e) => e.id == _ejercicioSeleccionado)) {
            _ejercicioSeleccionado = ejercicios.first.id;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
                GeoLiftSpacing.sm, GeoLiftSpacing.page, GeoLiftSpacing.xl),
            children: [
              const EncabezadoSeccion('Fuerza'),
              DropdownButtonFormField<int>(
                initialValue: _ejercicioSeleccionado,
                decoration: const InputDecoration(labelText: 'Ejercicio'),
                isExpanded: true,
                items: [
                  for (final ej in ejercicios)
                    DropdownMenuItem(
                      value: ej.id,
                      child: Text(ej.nombre, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (valor) =>
                    setState(() => _ejercicioSeleccionado = valor),
              ),
              const SizedBox(height: GeoLiftSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(GeoLiftSpacing.page),
                  child: _GraficaE1rm(ejercicioId: _ejercicioSeleccionado!),
                ),
              ),
              const SizedBox(height: GeoLiftSpacing.xxl),
              EncabezadoSeccion(
                'Peso corporal',
                accion: IconButton(
                  onPressed: () => _registrarPesoCorporal(context),
                  tooltip: 'Registrar peso corporal',
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(GeoLiftSpacing.page),
                  child: _GraficaPesoCorporal(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GraficaE1rm extends ConsumerWidget {
  final int ejercicioId;
  const _GraficaE1rm({required this.ejercicioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialPorEjercicioProvider(ejercicioId));
    final servicio = ref.watch(progresionServiceProvider);

    return historial.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Text('No se pudo cargar.'),
      data: (registros) {
        if (registros.isEmpty) {
          return const Text(
            'Todavía no hay sets registrados para este ejercicio.',
          );
        }

        // De más antiguo a más reciente, para que la gráfica avance de izq. a der.
        final ordenados = registros.reversed.toList();
        final mejorPr = registros
            .where((r) => r.registro.esPr)
            .map((r) => servicio.e1rm(r.registro.peso, r.registro.reps))
            .fold<double?>(null, (max, v) => max == null || v > max ? v : max);

        final puntos = <FlSpot>[
          for (var i = 0; i < ordenados.length; i++)
            FlSpot(
                i.toDouble(),
                servicio.e1rm(
                    ordenados[i].registro.peso, ordenados[i].registro.reps)),
        ];

        final gridColor = Theme.of(context).colorScheme.outlineVariant;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1RM estimado (fórmula de Epley)',
                style: Theme.of(context).textTheme.titleMedium),
            if (mejorPr != null)
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    const TextSpan(text: 'Mejor marca: '),
                    TextSpan(
                      text: '${mejorPr.toStringAsFixed(1)} kg e1RM',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: gridColor, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= ordenados.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('d/M').format(ordenados[i].fecha),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: puntos,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GraficaPesoCorporal extends ConsumerWidget {
  const _GraficaPesoCorporal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialPesoCorporalProvider);

    return historial.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Text('No se pudo cargar.'),
      data: (registros) {
        if (registros.isEmpty) {
          return const Text('Todavía no has registrado tu peso corporal.');
        }
        final puntos = <FlSpot>[
          for (var i = 0; i < registros.length; i++)
            FlSpot(i.toDouble(), registros[i].peso),
        ];
        return SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: puntos,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.secondary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
