import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/repositories/entrenamiento_repository.dart';
import '../../domain/clasificador_ejercicio.dart';
import '../../domain/progresion_service.dart';
import '../providers/providers.dart';

/// Qué identifica a un panel de ejercicio: el ejercicio objetivo, la sesión
/// y su lugar en la cola. Es un record, así que dos paneles con los mismos
/// datos comparten controlador y uno con otra posición en la cola (p. ej.
/// tras aplazarlo) arranca uno nuevo que retoma desde la base.
typedef ArgsEjercicio = ({
  RutinaEjercicio objetivo,
  int sesionId,
  int numeroEjercicio,
  int totalEjercicios,
  bool esUltimoEjercicio,
  int? proximoEjercicioId,
});

/// Una serie ya registrada hoy, como se muestra en la lista del panel.
typedef SerieRegistrada = ({
  int numeroSet,
  double pesoKg,
  int reps,
  double? rpe,
});

/// Estado inmutable de un ejercicio en la sesión activa. Los widgets solo
/// lo dibujan; todos los cambios pasan por [EjercicioController].
class EstadoEjercicio {
  /// Mientras se leen de la base las series previas, el historial y la
  /// sugerencia.
  final bool cargando;

  final String? nombreEjercicio;
  final String? nombreProximo;

  final int numeroSet;
  final int totalSeries;

  /// Siempre en kg (como se guarda); la unidad elegida solo cambia cómo se
  /// muestra y de cuánto en cuánto suben los botones −/+.
  final double pesoKg;
  final int reps;

  /// Esfuerzo percibido (6–10) de la serie que se va a registrar; opcional.
  final double? rpe;

  final bool guardando;
  final int segundosDescanso;

  /// Cuántos descansos llegaron a cero solos (no saltados): la interfaz lo
  /// usa para vibrar al terminar, incluso con el teléfono guardado.
  final int descansosTerminados;

  /// Se registró la última serie: la interfaz celebra y avanza.
  final bool celebrando;

  /// Más reciente primero.
  final List<SerieRegistrada> registradas;

  /// Serie más reciente del historial al abrir el panel ("sesión anterior").
  final RegistroConFecha? referencia;

  final Sugerencia? sugerencia;

  const EstadoEjercicio({
    required this.cargando,
    required this.nombreEjercicio,
    required this.nombreProximo,
    required this.numeroSet,
    required this.totalSeries,
    required this.pesoKg,
    required this.reps,
    required this.rpe,
    required this.guardando,
    required this.segundosDescanso,
    required this.descansosTerminados,
    required this.celebrando,
    required this.registradas,
    required this.referencia,
    required this.sugerencia,
  });

  bool get seriesCompletas => numeroSet > totalSeries;
  bool get descansando => segundosDescanso > 0;

  /// Se puede registrar la serie actual en este momento.
  bool get puedeRegistrar =>
      !cargando && !guardando && !descansando && !seriesCompletas;

  static const _igual = Object();

  EstadoEjercicio copyWith({
    bool? cargando,
    Object? nombreEjercicio = _igual,
    Object? nombreProximo = _igual,
    int? numeroSet,
    double? pesoKg,
    int? reps,
    Object? rpe = _igual,
    bool? guardando,
    int? segundosDescanso,
    int? descansosTerminados,
    bool? celebrando,
    List<SerieRegistrada>? registradas,
    Object? referencia = _igual,
    Object? sugerencia = _igual,
  }) {
    return EstadoEjercicio(
      cargando: cargando ?? this.cargando,
      nombreEjercicio: identical(nombreEjercicio, _igual)
          ? this.nombreEjercicio
          : nombreEjercicio as String?,
      nombreProximo: identical(nombreProximo, _igual)
          ? this.nombreProximo
          : nombreProximo as String?,
      numeroSet: numeroSet ?? this.numeroSet,
      totalSeries: totalSeries,
      pesoKg: pesoKg ?? this.pesoKg,
      reps: reps ?? this.reps,
      rpe: identical(rpe, _igual) ? this.rpe : rpe as double?,
      guardando: guardando ?? this.guardando,
      segundosDescanso: segundosDescanso ?? this.segundosDescanso,
      descansosTerminados: descansosTerminados ?? this.descansosTerminados,
      celebrando: celebrando ?? this.celebrando,
      registradas: registradas ?? this.registradas,
      referencia: identical(referencia, _igual)
          ? this.referencia
          : referencia as RegistroConFecha?,
      sugerencia: identical(sugerencia, _igual)
          ? this.sugerencia
          : sugerencia as Sugerencia?,
    );
  }
}

/// Lógica de UN ejercicio dentro de la sesión activa: retomar series ya
/// hechas, peso y reps de partida (historial + sugerencia de progresión),
/// registrar series (con PR y RPE), descanso entre series y notificación de
/// progreso. No conoce widgets: se prueba con un [ProviderContainer].
class EjercicioController
    extends AutoDisposeFamilyNotifier<EstadoEjercicio, ArgsEjercicio> {
  late EntrenamientoRepository _repo;
  Timer? _timerDescanso;
  bool _vivo = true;

  RutinaEjercicio get _objetivo => arg.objetivo;

  @override
  EstadoEjercicio build(ArgsEjercicio arg) {
    _repo = ref.read(entrenamientoRepositoryProvider);
    ref.onDispose(() {
      _vivo = false;
      _timerDescanso?.cancel();
    });

    final unidad = ref.read(unidadPesoProvider);
    Future.microtask(_cargar);
    return EstadoEjercicio(
      cargando: true,
      nombreEjercicio: null,
      nombreProximo: null,
      numeroSet: 1,
      totalSeries: arg.objetivo.seriesObjetivo,
      pesoKg: unidad.aKg(unidad.pesoInicial),
      reps: arg.objetivo.repsMin,
      rpe: null,
      guardando: false,
      segundosDescanso: 0,
      descansosTerminados: 0,
      celebrando: false,
      registradas: const [],
      referencia: null,
      sugerencia: null,
    );
  }

  /// Lee todo lo necesario para arrancar el panel:
  /// - Las series que esta sesión ya tenía para el ejercicio (se salió de
  ///   "Entrenar" a medias y se volvió a entrar): se retoma el conteo.
  /// - El historial: el último peso y reps sirven de punto de partida y de
  ///   referencia de "sesión anterior".
  /// - La sugerencia de progresión, que si existe precarga su peso (solo si
  ///   todavía no se registró ninguna serie hoy).
  Future<void> _cargar() async {
    final previas = await _repo.seriesEnSesion(arg.sesionId, _objetivo.id);
    final historial = await _repo.historial(_objetivo.ejercicioId);
    final ejercicio = await _repo.ejercicio(_objetivo.ejercicioId);
    final proximoId = arg.proximoEjercicioId;
    final proximo = proximoId == null ? null : await _repo.ejercicio(proximoId);
    if (!_vivo) return;

    final unidad = ref.read(unidadPesoProvider);
    var pesoKg = state.pesoKg;
    var reps = state.reps;
    if (historial.isNotEmpty) {
      // Se redondea al medio más cercano en la unidad actual, por si el
      // registro se hizo en la otra (60 kg → 132.5 lb, no 132.28).
      pesoKg =
          unidad.aKg(unidad.desdeKgRedondeado(historial.first.registro.peso));
      reps = historial.first.registro.reps;
    }

    final sugerencia =
        ejercicio == null ? null : _evaluarProgresion(historial, ejercicio);
    final pesoSugerido = sugerencia?.pesoSugeridoKg;
    if (pesoSugerido != null && previas.isEmpty) {
      pesoKg = unidad.redondearAPasoKg(pesoSugerido);
    }

    final numeroSet = previas.isEmpty ? 1 : previas.last.numeroSet + 1;
    state = state.copyWith(
      cargando: false,
      nombreEjercicio: ejercicio?.nombre,
      nombreProximo: proximo?.nombre,
      pesoKg: pesoKg,
      reps: reps,
      numeroSet: numeroSet,
      registradas: [
        for (final s in previas.reversed)
          (numeroSet: s.numeroSet, pesoKg: s.peso, reps: s.reps, rpe: s.rpe),
      ],
      referencia: historial.isEmpty ? null : historial.first,
      sugerencia: sugerencia,
      // Se salió de "Entrenar" justo después de la última serie, antes de
      // que el avance automático llegara a dispararse: se retoma ahora.
      celebrando: numeroSet > _objetivo.seriesObjetivo,
    );
    unawaited(_actualizarNotificacion());
  }

  /// Agrupa el historial por sesión (más reciente primero), sin la sesión
  /// en curso, y le pide al motor de progresión qué hacer hoy.
  Sugerencia? _evaluarProgresion(
      List<RegistroConFecha> historial, Ejercicio ejercicio) {
    final porSesion = <int, List<SerieRealizada>>{};
    for (final r in historial) {
      final registro = r.registro;
      if (registro.sesionId == arg.sesionId) continue;
      porSesion.putIfAbsent(registro.sesionId, () => []).add(SerieRealizada(
            peso: registro.peso,
            reps: registro.reps,
            repsMinObjetivo: _objetivo.repsMin,
            repsMaxObjetivo: _objetivo.repsMax,
            rpe: registro.rpe,
          ));
    }
    final sugerencia = ref.read(progresionServiceProvider).evaluar(
          porSesion.values.toList(),
          esTrenInferior: ClasificadorEjercicio.esTrenInferior(
            ejercicio.nombre,
            grupoMuscular: ejercicio.grupoMuscular,
          ),
        );
    return sugerencia.tipo == TipoSugerencia.ninguna ? null : sugerencia;
  }

  // ---- Ajustes de la serie actual -------------------------------------------

  double get _pasoKg {
    final unidad = ref.read(unidadPesoProvider);
    return unidad.aKg(unidad.paso);
  }

  void subirPeso() {
    if (state.seriesCompletas) return;
    state = state.copyWith(pesoKg: state.pesoKg + _pasoKg);
  }

  void bajarPeso() {
    if (state.seriesCompletas) return;
    state = state.copyWith(pesoKg: math.max(0, state.pesoKg - _pasoKg));
  }

  void subirReps() {
    if (state.seriesCompletas) return;
    state = state.copyWith(reps: math.min(50, state.reps + 1));
  }

  void bajarReps() {
    if (state.seriesCompletas) return;
    state = state.copyWith(reps: math.max(1, state.reps - 1));
  }

  /// Marca (o con null, desmarca) el RPE de la serie que se va a registrar.
  void elegirRpe(double? rpe) {
    if (state.seriesCompletas) return;
    state = state.copyWith(rpe: rpe);
  }

  // ---- Registrar -----------------------------------------------------------

  /// Guarda la serie actual. Devuelve si fue un PR (récord de 1RM estimado
  /// para el ejercicio), o null si en este momento no se podía registrar.
  /// Tras la última serie pasa a [EstadoEjercicio.celebrando]; si no, arranca
  /// el descanso.
  Future<bool?> registrarSerie() async {
    if (!state.puedeRegistrar) return null;
    state = state.copyWith(guardando: true);

    final servicio = ref.read(progresionServiceProvider);
    final historial = await _repo.historial(_objetivo.ejercicioId);
    final e1rmPrevio = historial.isEmpty
        ? null
        : historial
            .map((h) => servicio.e1rm(h.registro.peso, h.registro.reps))
            .reduce(math.max);
    final esPr = servicio.esNuevoPr(
      e1rmNuevo: servicio.e1rm(state.pesoKg, state.reps),
      e1rmMaximoPrevio: e1rmPrevio,
    );

    final serie = (
      numeroSet: state.numeroSet,
      pesoKg: state.pesoKg,
      reps: state.reps,
      rpe: state.rpe,
    );
    await _repo.registrarSerie(
      sesionId: arg.sesionId,
      rutinaEjercicioId: _objetivo.id,
      numeroSet: serie.numeroSet,
      pesoKg: serie.pesoKg,
      reps: serie.reps,
      rpe: serie.rpe,
      esPr: esPr,
    );
    if (!_vivo) return esPr;

    final esUltima = serie.numeroSet >= _objetivo.seriesObjetivo;
    state = state.copyWith(
      registradas: [serie, ...state.registradas],
      numeroSet: serie.numeroSet + 1,
      rpe: null,
      guardando: false,
      celebrando: esUltima,
    );
    unawaited(_actualizarNotificacion());
    if (!esUltima) _iniciarDescanso();
    return esPr;
  }

  // ---- Descanso -------------------------------------------------------------

  void _iniciarDescanso() {
    _timerDescanso?.cancel();
    state = state.copyWith(segundosDescanso: _objetivo.descansoSeg);
    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_vivo) {
        t.cancel();
        return;
      }
      if (state.segundosDescanso <= 1) {
        t.cancel();
        state = state.copyWith(
          segundosDescanso: 0,
          descansosTerminados: state.descansosTerminados + 1,
        );
      } else {
        state = state.copyWith(segundosDescanso: state.segundosDescanso - 1);
      }
    });
  }

  /// Cancela el temporizador del descanso sin tocar el estado. La llama el
  /// panel al desmontarse: Riverpod destruye este controlador un momento
  /// DESPUÉS de que se va el widget, y el temporizador no debe sobrevivirle
  /// a la pantalla ni un instante.
  void detenerDescanso() => _timerDescanso?.cancel();

  /// Termina el descanso antes de tiempo.
  void saltarDescanso() {
    if (!state.descansando) return;
    _timerDescanso?.cancel();
    state = state.copyWith(segundosDescanso: 0);
  }

  // ---- Notificación ---------------------------------------------------------

  /// Actualiza la notificación de progreso mientras queden series, o la
  /// retira si se acaba de completar el último ejercicio de la sesión.
  Future<void> _actualizarNotificacion() async {
    if (!_vivo) return;
    final servicio = ref.read(notificationServiceProvider);
    final total = _objetivo.seriesObjetivo;
    if (arg.esUltimoEjercicio && state.numeroSet > total) {
      await servicio.cancelar();
      return;
    }
    await servicio.mostrarProgreso(
      rutinaDiaId: _objetivo.rutinaDiaId,
      nombreEjercicio: state.nombreEjercicio ?? 'Ejercicio',
      numeroEjercicio: arg.numeroEjercicio,
      totalEjercicios: arg.totalEjercicios,
      numeroSet: math.min(state.numeroSet, total),
      totalSets: total,
    );
  }
}

final ejercicioControllerProvider = NotifierProvider.autoDispose
    .family<EjercicioController, EstadoEjercicio, ArgsEjercicio>(
        EjercicioController.new);
