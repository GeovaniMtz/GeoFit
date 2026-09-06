import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/rutina_form/borrador.dart';
import '../widgets/rutina_form/tarjeta_dia.dart';

/// Crea (o en el futuro edita) una rutina completa: nombre, días y los
/// ejercicios objetivo de cada día. Todo se guarda de un jalón al presionar
/// "Guardar rutina".
class RutinaFormScreen extends ConsumerStatefulWidget {
  final int? rutinaId;
  const RutinaFormScreen({super.key, this.rutinaId});

  @override
  ConsumerState<RutinaFormScreen> createState() => _RutinaFormScreenState();
}

class _RutinaFormScreenState extends ConsumerState<RutinaFormScreen> {
  final _controladorNombreRutina = TextEditingController();
  final List<DiaBorrador> _dias = [DiaBorrador()];
  bool _guardando = false;
  bool _cargando = false;
  bool _eliminando = false;

  /// Hay cambios sin guardar: si el usuario intenta salir, se le confirma
  /// antes de perderlos (ver [PopScope] en [build]).
  bool _sucio = false;
  void _marcarSucio() {
    // setState (no solo la asignación) para que el PopScope de build()
    // vea el canPop actualizado de inmediato.
    if (!_sucio) setState(() => _sucio = true);
  }

  DiaBorrador _nuevoDiaBorrador() {
    final dia = DiaBorrador();
    dia.controladorNombre.addListener(_marcarSucio);
    return dia;
  }

  @override
  void initState() {
    super.initState();
    _controladorNombreRutina.addListener(_marcarSucio);
    for (final dia in _dias) {
      dia.controladorNombre.addListener(_marcarSucio);
    }

    final rutinaId = widget.rutinaId;
    if (rutinaId != null) {
      // Se asigna directo (sin setState): todavía no ocurre el primer
      // build, así que ya se reflejará en él.
      _cargando = true;
      _cargarRutinaExistente(rutinaId);
    }
  }

  Future<void> _cargarRutinaExistente(int rutinaId) async {
    final db = ref.read(databaseProvider);

    final rutina = await db.obtenerRutina(rutinaId);
    final dias = await db.diasDeRutina(rutinaId);

    final diasCargados = <DiaBorrador>[];
    for (final dia in dias) {
      final diaBorrador = DiaBorrador()
        ..diaId = dia.id
        ..controladorNombre.text = dia.nombreDia;

      final ejercicios = await db.ejerciciosDeDiaConNombre(dia.id);
      for (final e in ejercicios) {
        diaBorrador.ejercicios.add(EjercicioBorrador(
          rutinaEjercicioId: e.rutinaEjercicio.id,
          ejercicioId: e.rutinaEjercicio.ejercicioId,
          nombreEjercicio: e.nombreEjercicio,
          seriesObjetivo: e.rutinaEjercicio.seriesObjetivo,
          repsMin: e.rutinaEjercicio.repsMin,
          repsMax: e.rutinaEjercicio.repsMax,
          descansoSeg: e.rutinaEjercicio.descansoSeg,
        ));
        diaBorrador.idsOriginalesDeEjercicios.add(e.rutinaEjercicio.id);
      }
      diasCargados.add(diaBorrador);
    }

    if (!mounted) return;
    setState(() {
      _controladorNombreRutina.text = rutina.nombre;
      for (final dia in _dias) {
        dia.controladorNombre.dispose();
      }
      _dias
        ..clear()
        ..addAll(diasCargados.isEmpty ? [_nuevoDiaBorrador()] : diasCargados);
      for (final dia in diasCargados) {
        dia.controladorNombre.addListener(_marcarSucio);
      }
      _cargando = false;
      // Los cambios de arriba son de carga, no del usuario — no cuentan
      // como pendientes por guardar.
      _sucio = false;
    });
  }

  @override
  void dispose() {
    _controladorNombreRutina.dispose();
    for (final dia in _dias) {
      dia.controladorNombre.dispose();
    }
    super.dispose();
  }

  void _agregarDia() => setState(() {
        _dias.add(_nuevoDiaBorrador());
        _sucio = true;
      });

  void _agregarEjercicio(DiaBorrador dia, EjercicioBorrador ejercicio) {
    setState(() {
      dia.ejercicios.add(ejercicio);
      _sucio = true;
    });
  }

  void _editarEjercicio(
      DiaBorrador dia, int indice, EjercicioBorrador actualizado) {
    setState(() {
      dia.ejercicios[indice] = actualizado;
      _sucio = true;
    });
  }

  Future<void> _guardar() async {
    if (_controladorNombreRutina.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponle un nombre a la rutina.')),
      );
      return;
    }

    setState(() => _guardando = true);
    final db = ref.read(databaseProvider);

    try {
      final nombreRutina = _controladorNombreRutina.text.trim();
      int rutinaId;
      if (widget.rutinaId != null) {
        rutinaId = widget.rutinaId!;
        await db.actualizarNombreRutina(rutinaId, nombreRutina);
      } else {
        rutinaId = await db.crearRutina(nombreRutina);
      }

      for (var i = 0; i < _dias.length; i++) {
        final dia = _dias[i];
        final nombreDia = dia.controladorNombre.text.trim().isEmpty
            ? 'Día ${i + 1}'
            : dia.controladorNombre.text.trim();

        int diaId;
        if (dia.diaId != null) {
          diaId = dia.diaId!;
          await db.actualizarDia(diaId, nombreDia, i);
        } else {
          diaId = await db.crearDia(rutinaId, nombreDia, i);
        }

        final idsConservados = <int>{};
        for (var j = 0; j < dia.ejercicios.length; j++) {
          final ej = dia.ejercicios[j];
          var ejercicioId = ej.ejercicioId;
          ejercicioId ??= await db.crearEjercicio(EjerciciosCompanion.insert(
            nombre: ej.nombreEjercicio,
            grupoMuscular: 'Sin clasificar',
            esPersonalizado: const Value(true),
          ));

          if (ej.rutinaEjercicioId != null) {
            await db.actualizarEjercicioDeRutina(
              ej.rutinaEjercicioId!,
              orden: j,
              seriesObjetivo: ej.seriesObjetivo,
              repsMin: ej.repsMin,
              repsMax: ej.repsMax,
              descansoSeg: ej.descansoSeg,
            );
            idsConservados.add(ej.rutinaEjercicioId!);
          } else {
            final nuevoId = await db
                .agregarEjercicioARutina(RutinaEjerciciosCompanion.insert(
              rutinaDiaId: diaId,
              ejercicioId: ejercicioId,
              orden: Value(j),
              seriesObjetivo: Value(ej.seriesObjetivo),
              repsMin: Value(ej.repsMin),
              repsMax: Value(ej.repsMax),
              descansoSeg: Value(ej.descansoSeg),
            ));
            idsConservados.add(nuevoId);
          }
        }

        for (final idOriginal in dia.idsOriginalesDeEjercicios) {
          if (!idsConservados.contains(idOriginal)) {
            await db.eliminarEjercicioDeRutina(idOriginal);
          }
        }
      }

      ref.invalidate(rutinasActivasProvider);
      ref.invalidate(diasDeRutinaProvider(rutinaId));
      ref.invalidate(ejerciciosEnUsoProvider);
      _sucio = false;
      if (mounted) Navigator.of(context).pop('guardado');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<bool> _confirmarDescartarCambios() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Tienes cambios sin guardar en esta rutina. Si sales ahora, se '
          'pierden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DESCARTAR'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  Future<void> _confirmarEliminar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta rutina?'),
        content: const Text(
          'Dejará de aparecer en tu lista de rutinas. Tu historial de '
          'entrenamientos con ella se conserva y sigue contando para tus '
          'gráficas de progreso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmado == true) _eliminarRutina();
  }

  Future<void> _eliminarRutina() async {
    final rutinaId = widget.rutinaId;
    if (rutinaId == null) return;

    setState(() => _eliminando = true);
    final db = ref.read(databaseProvider);
    try {
      await db.archivarRutina(rutinaId);
      ref.invalidate(rutinasActivasProvider);
      ref.invalidate(ejerciciosEnUsoProvider);
      _sucio = false;
      if (mounted) Navigator.of(context).pop('eliminado');
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<String>(
      canPop: !_sucio,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final descartar = await _confirmarDescartarCambios();
        if (descartar) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.rutinaId == null ? 'Nueva rutina' : 'Editar rutina'),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _controladorNombreRutina,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la rutina',
                      hintText: 'p. ej. Push / Pull / Legs',
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < _dias.length; i++)
                    TarjetaDia(
                      indice: i,
                      dia: _dias[i],
                      onAgregarEjercicio: (ejercicio) =>
                          _agregarEjercicio(_dias[i], ejercicio),
                      onEditarEjercicio: (idx, ejercicio) =>
                          _editarEjercicio(_dias[i], idx, ejercicio),
                      onQuitarEjercicio: (idx) => setState(() {
                        _dias[i].ejercicios.removeAt(idx);
                        _sucio = true;
                      }),
                    ),
                  OutlinedButton.icon(
                    onPressed: _agregarDia,
                    icon: const Icon(Icons.add),
                    label: const Text('AGREGAR DÍA'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_guardando || _eliminando) ? null : _guardar,
                      child: _guardando
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Text('GUARDAR RUTINA'),
                    ),
                  ),
                  if (widget.rutinaId != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: (_guardando || _eliminando)
                            ? null
                            : _confirmarEliminar,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        icon: _eliminando
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: const Text('ELIMINAR RUTINA'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
