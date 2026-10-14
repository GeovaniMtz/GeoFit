import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification_service.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../providers/providers.dart';
import '../widgets/entrenar/panel_ejercicio.dart';
import '../widgets/estado_error.dart';
import 'rutina_completada_screen.dart';

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
  bool _rutinaCompletada = false;

  // Orden efectivo de los ejercicios del día para ESTA sesión: normalmente
  // coincide con el orden de la rutina, pero "aplazar" reordena moviendo un
  // ejercicio al final. Es puramente en memoria — no se guarda en la base de
  // datos, así que si se sale de "Entrenar" y se vuelve a entrar, el orden
  // vuelve a ser el original (ver _crearSesion).
  List<RutinaEjercicio>? _colaEjercicios;

  // Animación breve de "arranque" mostrada al entrar a la pantalla, antes
  // de que se vea el primer ejercicio.
  bool _mostrandoIntro = true;

  // Riverpod no permite leer providers (ref.read) dentro de dispose(): se
  // guarda la referencia desde antes para poder cancelar la notificación
  // ahí sin tocar `ref`.
  late final NotificacionEntrenamientoService _notificaciones =
      ref.read(notificationServiceProvider);

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
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
        _colaEjercicios = List<RutinaEjercicio>.of(ejercicios);
      });
    }
  }

  /// Manda el ejercicio en [indice] al final de la cola de esta sesión y
  /// pasa al que quede en su lugar — para cuando no se puede hacer ese
  /// ejercicio en este momento (p. ej. la máquina está ocupada) pero sí el
  /// resto. Los sets ya registrados de ese ejercicio quedan intactos y se
  /// retoman cuando le vuelva a tocar.
  void _aplazarEjercicio(int indice) {
    final cola = _colaEjercicios;
    if (cola == null || indice >= cola.length - 1) return;
    setState(() {
      final ejercicio = cola.removeAt(indice);
      cola.add(ejercicio);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rutinaCompletada) {
      return RutinaCompletadaScreen(
        sesionId: _sesionId!,
        onVolver: () => Navigator.of(context).pop(),
      );
    }

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
                    padding: const EdgeInsets.only(right: GeoLiftSpacing.page),
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
        // Avance de la sesión completa (ejercicio actual / total): da
        // contexto de "cuánto falta" sin tener que leer el contador.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: GeoLiftSpacing.page),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GeoLiftRadius.sm),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: ejerciciosAsync.maybeWhen(
                  data: (ejercicios) => ejercicios.isEmpty
                      ? 0
                      : (_indiceEjercicio + 1) / ejercicios.length,
                  orElse: () => 0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _sesionId == null
              ? const Center(child: CircularProgressIndicator())
              : ejerciciosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EstadoError(
                    onReintentar: () => ref.invalidate(
                        ejerciciosDeDiaProvider(widget.rutinaDiaId)),
                  ),
                  data: (_) {
                    final cola = _colaEjercicios;
                    if (cola == null || cola.isEmpty) {
                      return const Center(
                        child: Text('Este día todavía no tiene ejercicios.'),
                      );
                    }
                    final indice = _indiceEjercicio >= cola.length
                        ? cola.length - 1
                        : _indiceEjercicio;
                    final esUltimo = indice == cola.length - 1;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: PanelEjercicio(
                        key: ValueKey(cola[indice].id),
                        objetivo: cola[indice],
                        proximoObjetivo: esUltimo ? null : cola[indice + 1],
                        sesionId: _sesionId!,
                        numeroEjercicio: indice + 1,
                        totalEjercicios: cola.length,
                        esUltimoEjercicio: esUltimo,
                        onSiguienteEjercicio: esUltimo
                            ? null
                            : () =>
                                setState(() => _indiceEjercicio = indice + 1),
                        onAplazarEjercicio:
                            esUltimo ? null : () => _aplazarEjercicio(indice),
                        onRutinaCompletada: () =>
                            setState(() => _rutinaCompletada = true),
                      ),
                    );
                  },
                ),
          if (_mostrandoIntro)
            _IntroEntrenar(
              onFin: () {
                if (mounted) setState(() => _mostrandoIntro = false);
              },
            ),
        ],
      ),
    );
  }
}

/// Animación breve de "arranque" que cubre la pantalla al entrar a
/// "Entrenar": un ícono que rebota al aparecer y luego todo se desvanece
/// para dar paso al primer ejercicio.
class _IntroEntrenar extends StatefulWidget {
  final VoidCallback onFin;
  const _IntroEntrenar({required this.onFin});

  @override
  State<_IntroEntrenar> createState() => _IntroEntrenarState();
}

class _IntroEntrenarState extends State<_IntroEntrenar>
    with SingleTickerProviderStateMixin {
  // Un solo AnimationController maneja todo el intro (rebote de ícono y
  // luego desvanecido) en vez de Timers sueltos: su ticker mantiene
  // "programado" un frame durante todo el trayecto sin huecos, así
  // pumpAndSettle() en los tests espera el intro completo en vez de darlo
  // por terminado a medio camino.
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _escala = CurvedAnimation(
    parent: _controlador,
    curve: const Interval(0, 0.55, curve: Curves.elasticOut),
  );
  late final Animation<double> _opacidad = CurvedAnimation(
    parent: _controlador,
    curve: const Interval(0.7, 1, curve: Curves.easeIn),
  ).drive(Tween(begin: 1, end: 0));

  @override
  void initState() {
    super.initState();
    _controlador.forward().whenComplete(widget.onFin);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controlador,
          builder: (context, child) => Opacity(
            opacity: _opacidad.value,
            child: Container(
              color: colorScheme.surface,
              alignment: Alignment.center,
              child: Transform.scale(scale: _escala.value, child: child),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 64, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text('¡A ENTRENAR!',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
