import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification_service.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/entrenar/panel_ejercicio.dart';
import '../widgets/estado_error.dart';

/// Pantalla de sesión activa: se enfoca en UN ejercicio a la vez con
/// controles grandes de peso/reps pensados para tocarse con el pulgar entre
/// series, y avanza al siguiente ejercicio cuando el actual está completo.
class EntrenarScreen extends ConsumerStatefulWidget {
  final int rutinaDiaId;
  const EntrenarScreen({super.key, required this.rutinaDiaId});

  @override
  ConsumerState<EntrenarScreen> createState() => _EntrenarScreenState();
}

class _EntrenarScreenState extends ConsumerState<EntrenarScreen> {
  int? _sesionId;
  int _indiceEjercicio = 0;

  // Riverpod no permite leer providers (ref.read) dentro de dispose(): se
  // guarda la referencia desde antes para poder cancelar la notificación
  // ahí sin tocar `ref`.
  late final NotificacionEntrenamientoService _notificaciones =
      ref.read(notificationServiceProvider);

  @override
  void initState() {
    super.initState();
    _crearSesion();
  }

  @override
  void dispose() {
    // No se dispara al avanzar de ejercicio (PanelEjercicio se recrea pero
    // esta pantalla sigue montada) — solo al salir de verdad de "Entrenar".
    // No se espera el Future: dispose() no puede ser async.
    _notificaciones.cancelar();
    super.dispose();
  }

  Future<void> _crearSesion() async {
    final db = ref.read(databaseProvider);
    // Fire-and-forget: no bloquea la creación de la sesión con el diálogo
    // de permisos del sistema.
    unawaited(_notificaciones.solicitarPermiso());
    final id = await db.iniciarOResumirSesion(widget.rutinaDiaId);
    final ejercicios = await db.ejerciciosDeDia(widget.rutinaDiaId);
    final setsPrevios = await db.setsDeSesion(id);

    final setsPorEjercicio = <int, int>{};
    for (final set in setsPrevios) {
      setsPorEjercicio[set.rutinaEjercicioId] =
          (setsPorEjercicio[set.rutinaEjercicioId] ?? 0) + 1;
    }

    // Retoma en el primer ejercicio que todavía no completó sus series en
    // esta sesión; si ya están todas completas, se queda en el último.
    var indice = 0;
    for (var i = 0; i < ejercicios.length; i++) {
      indice = i;
      final hechos = setsPorEjercicio[ejercicios[i].id] ?? 0;
      if (hechos < ejercicios[i].seriesObjetivo) break;
    }

    if (mounted) {
      setState(() {
        _sesionId = id;
        _indiceEjercicio = indice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosAsync =
        ref.watch(ejerciciosDeDiaProvider(widget.rutinaDiaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenar'),
        actions: [
          ejerciciosAsync.maybeWhen(
            data: (ejercicios) => ejercicios.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        'Ejercicio ${_indiceEjercicio + 1} de '
                        '${ejercicios.length}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: _sesionId == null
          ? const Center(child: CircularProgressIndicator())
          : ejerciciosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EstadoError(
                onReintentar: () =>
                    ref.invalidate(ejerciciosDeDiaProvider(widget.rutinaDiaId)),
              ),
              data: (ejercicios) {
                if (ejercicios.isEmpty) {
                  return const Center(
                    child: Text('Este día todavía no tiene ejercicios.'),
                  );
                }
                final indice = _indiceEjercicio >= ejercicios.length
                    ? ejercicios.length - 1
                    : _indiceEjercicio;
                final esUltimo = indice == ejercicios.length - 1;
                return PanelEjercicio(
                  key: ValueKey(ejercicios[indice].id),
                  objetivo: ejercicios[indice],
                  proximoObjetivo: esUltimo ? null : ejercicios[indice + 1],
                  sesionId: _sesionId!,
                  numeroEjercicio: indice + 1,
                  totalEjercicios: ejercicios.length,
                  esUltimoEjercicio: esUltimo,
                  onSiguienteEjercicio: esUltimo
                      ? null
                      : () => setState(() => _indiceEjercicio = indice + 1),
                );
              },
            ),
    );
  }
}
