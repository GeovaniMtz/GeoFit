import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _crearSesion();
  }

  Future<void> _crearSesion() async {
    final db = ref.read(databaseProvider);
    final id = await db.iniciarSesion(widget.rutinaDiaId);
    if (mounted) setState(() => _sesionId = id);
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
                  sesionId: _sesionId!,
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
