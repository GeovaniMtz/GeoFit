import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/theme.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/comunes.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(temaControllerProvider);
    final unidad = ref.watch(unidadPesoProvider);

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
          const EncabezadoSeccion('Unidad de peso'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(GeoLiftSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cambia cómo se muestran y capturan los pesos. Tu '
                    'historial no se modifica.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: GeoLiftSpacing.lg),
                  SegmentedButton<UnidadPeso>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: UnidadPeso.kg,
                        tooltip: 'Kilogramos',
                        label: Text('KG'),
                      ),
                      ButtonSegment(
                        value: UnidadPeso.lb,
                        tooltip: 'Libras',
                        label: Text('LB'),
                      ),
                    ],
                    selected: {unidad},
                    onSelectionChanged: (seleccion) {
                      ref
                          .read(unidadPesoProvider.notifier)
                          .cambiarUnidad(seleccion.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GeoLiftSpacing.xxl),
          const EncabezadoSeccion('Respaldo'),
          const _TarjetaRespaldo(),
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

/// Exportar toda la base a un archivo (para guardarlo en Drive, WhatsApp…)
/// y restaurarla desde uno. Sin esto, reinstalar la app o cambiar de
/// teléfono borra todo el historial.
class _TarjetaRespaldo extends ConsumerStatefulWidget {
  const _TarjetaRespaldo();

  @override
  ConsumerState<_TarjetaRespaldo> createState() => _TarjetaRespaldoState();
}

class _TarjetaRespaldoState extends ConsumerState<_TarjetaRespaldo> {
  bool _ocupado = false;

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _exportar() async {
    setState(() => _ocupado = true);
    try {
      await ref
          .read(respaldoServiceProvider)
          .exportarYCompartir(ref.read(databaseProvider));
    } catch (_) {
      _avisar('No se pudo crear el respaldo.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _restaurar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar un respaldo?'),
        content: const Text(
          'Todos tus datos actuales (rutinas, historial, progreso y ajustes) '
          'se reemplazan por los del respaldo. Si tienes algo nuevo que no '
          'esté en ese archivo, expórtalo primero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELEGIR ARCHIVO'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    setState(() => _ocupado = true);
    try {
      final restaurado = await ref
          .read(respaldoServiceProvider)
          .elegirYRestaurar(ref.read(databaseProvider));
      if (!restaurado) return;
      refrescarTodosLosDatos(ref);
      _avisar('Respaldo restaurado.');
    } on RespaldoInvalido catch (e) {
      _avisar(e.mensaje);
    } catch (_) {
      _avisar('No se pudo restaurar el respaldo. Tus datos no cambiaron.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page,
                GeoLiftSpacing.page, GeoLiftSpacing.page, GeoLiftSpacing.sm),
            child: Text(
              'Tus datos solo viven en este teléfono. Guarda un respaldo en '
              'Drive, WhatsApp o donde quieras para no perderlos al '
              'reinstalar o cambiar de cel.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const _EstadoRespaldoAutomatico(),
          if (_ocupado)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: GeoLiftSpacing.page),
              child: LinearProgressIndicator(minHeight: 4),
            ),
          ListTile(
            enabled: !_ocupado,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: GeoLiftSpacing.page),
            leading: const IconoEnCaja(Icons.ios_share_rounded),
            title: const Text('Exportar respaldo'),
            subtitle: const Text('Crea un archivo con todos tus datos'),
            onTap: _exportar,
          ),
          ListTile(
            enabled: !_ocupado,
            contentPadding: const EdgeInsets.fromLTRB(
                GeoLiftSpacing.page, 0, GeoLiftSpacing.page, GeoLiftSpacing.sm),
            leading: const IconoEnCaja(Icons.settings_backup_restore_rounded),
            title: const Text('Restaurar respaldo'),
            subtitle: const Text('Reemplaza tus datos por los de un archivo'),
            onTap: _restaurar,
          ),
        ],
      ),
    );
  }
}

/// "Automático cada semana · último hace 3 días · en Documentos/GeoLift".
class _EstadoRespaldoAutomatico extends ConsumerWidget {
  const _EstadoRespaldoAutomatico();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoRespaldoAutomaticoProvider);
    final datos = estado.valueOrNull;
    if (datos == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final partes = p.split(datos.carpeta);
    final enDocumentos = partes.length >= 2 &&
        partes[partes.length - 2] == 'Documents' &&
        partes.last == 'GeoLift';
    final cuando = _haceCuanto(datos.ultimo);
    final donde = enDocumentos
        ? 'en Documentos/GeoLift'
        : 'en la carpeta de la app (se borra si la desinstalas)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(GeoLiftSpacing.page, GeoLiftSpacing.xs,
          GeoLiftSpacing.page, GeoLiftSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_repeat_rounded,
              size: 18, color: colorScheme.secondary),
          const SizedBox(width: GeoLiftSpacing.sm),
          Expanded(
            child: Text(
              'Automático cada semana · $cuando · $donde',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  static String _haceCuanto(DateTime? fecha) {
    if (fecha == null) return 'todavía sin respaldos';
    final dias = DateTime.now().difference(fecha).inDays;
    return switch (dias) {
      0 => 'último hoy',
      1 => 'último ayer',
      _ => 'último hace $dias días',
    };
  }
}
