import 'package:drift/drift.dart';

import '../database.dart';

/// Consultas sobre sesiones de entrenamiento y los sets registrados en ellas
/// (tablas `SesionesEntrenamiento` y `RegistrosSet`).
extension SesionesQueries on AppDatabase {
  Future<int> iniciarSesion(int rutinaDiaId) => into(sesionesEntrenamiento)
      .insert(SesionesEntrenamientoCompanion.insert(rutinaDiaId: rutinaDiaId));

  /// La sesión de hoy para este día de rutina, si ya se empezó una — para
  /// retomarla en vez de crear una nueva cada vez que se reabre "Entrenar"
  /// (p. ej. al salir con el botón de regresar y volver a entrar).
  Future<SesionesEntrenamientoData?> sesionDeHoy(int rutinaDiaId) {
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDia = inicioDia.add(const Duration(days: 1));
    final query = select(sesionesEntrenamiento)
      ..where((s) =>
          s.rutinaDiaId.equals(rutinaDiaId) &
          s.fecha.isBiggerOrEqualValue(inicioDia) &
          s.fecha.isSmallerThanValue(finDia))
      ..orderBy([(s) => OrderingTerm.desc(s.fecha)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Retoma la sesión de hoy de [rutinaDiaId] si ya existe una; si no, crea
  /// una nueva. Así salir de "Entrenar" y volver a entrar el mismo día no
  /// reinicia el progreso desde el primer ejercicio.
  Future<int> iniciarOResumirSesion(int rutinaDiaId) async {
    final existente = await sesionDeHoy(rutinaDiaId);
    if (existente != null) return existente.id;
    return iniciarSesion(rutinaDiaId);
  }

  Future<int> registrarSet(RegistrosSetCompanion datos) =>
      into(registrosSet).insert(datos);

  Future<SesionesEntrenamientoData> obtenerSesion(int sesionId) =>
      (select(sesionesEntrenamiento)..where((s) => s.id.equals(sesionId)))
          .getSingle();

  /// Guarda como duración de la sesión el tiempo transcurrido desde que se
  /// empezó hasta [hasta] (por defecto, ahora). Se llama tras cada serie, así
  /// que una sesión que se deja a medias conserva la duración hasta su
  /// última serie registrada en vez de quedarse sin dato.
  Future<void> actualizarDuracionSesion(int sesionId, {DateTime? hasta}) async {
    final sesion = await obtenerSesion(sesionId);
    final fin = hasta ?? DateTime.now();
    final segundos = fin.difference(sesion.fecha).inSeconds;
    await (update(sesionesEntrenamiento)..where((s) => s.id.equals(sesionId)))
        .write(SesionesEntrenamientoCompanion(
      duracionSeg: Value(segundos < 0 ? 0 : segundos),
    ));
  }

  /// Guarda (o borra, si viene vacía) la nota libre de la sesión — p. ej.
  /// "me dolió el hombro en el press".
  Future<void> guardarNotasSesion(int sesionId, String? notas) {
    final limpia = notas?.trim();
    return (update(sesionesEntrenamiento)..where((s) => s.id.equals(sesionId)))
        .write(SesionesEntrenamientoCompanion(
      notas: Value(limpia == null || limpia.isEmpty ? null : limpia),
    ));
  }

  /// Todos los sets ya registrados en [sesionId], de cualquier ejercicio —
  /// para saber en qué ejercicio y serie retomar al reabrir la sesión.
  Future<List<RegistrosSetData>> setsDeSesion(int sesionId) =>
      (select(registrosSet)..where((r) => r.sesionId.equals(sesionId))).get();

  /// Los sets ya registrados en [sesionId] para un ejercicio puntual, en
  /// orden — para retomar el conteo de series y la lista de "sets
  /// registrados" si se vuelve a entrar a mitad de ese ejercicio.
  Future<List<RegistrosSetData>> setsDeEjercicioEnSesion(
    int sesionId,
    int rutinaEjercicioId,
  ) =>
      (select(registrosSet)
            ..where((r) =>
                r.sesionId.equals(sesionId) &
                r.rutinaEjercicioId.equals(rutinaEjercicioId))
            ..orderBy([(r) => OrderingTerm.asc(r.numeroSet)]))
          .get();

  /// Historial de sets de un ejercicio del catálogo (p.ej. "Press de banca"),
  /// sin importar en qué rutina o día se hizo — así el progreso y los PRs se
  /// comparan contra el movimiento en sí, no contra una rutina en particular.
  /// Más reciente primero.
  Future<List<RegistroConFecha>> historialPorEjercicio(int ejercicioId) async {
    final query = select(registrosSet).join([
      innerJoin(rutinaEjercicios,
          rutinaEjercicios.id.equalsExp(registrosSet.rutinaEjercicioId)),
      innerJoin(sesionesEntrenamiento,
          sesionesEntrenamiento.id.equalsExp(registrosSet.sesionId)),
    ])
      ..where(rutinaEjercicios.ejercicioId.equals(ejercicioId))
      ..orderBy([OrderingTerm.desc(sesionesEntrenamiento.fecha)]);

    final filas = await query.get();
    return filas
        .map((f) => RegistroConFecha(
              registro: f.readTable(registrosSet),
              fecha: f.readTable(sesionesEntrenamiento).fecha,
            ))
        .toList();
  }

  /// Resumen de la semana de [ahora] (lunes a domingo) y el volumen de la
  /// semana anterior, para comparar.
  Future<ResumenSemana> resumenSemana(DateTime ahora) async {
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicio = hoy.subtract(Duration(days: hoy.weekday - 1));
    final fin = inicio.add(const Duration(days: 7));
    final inicioAnterior = inicio.subtract(const Duration(days: 7));

    final sesiones = await (select(sesionesEntrenamiento)
          ..where((s) =>
              s.fecha.isBiggerOrEqualValue(inicioAnterior) &
              s.fecha.isSmallerThanValue(fin)))
        .get();
    final porId = {for (final s in sesiones) s.id: s};
    final sets = porId.isEmpty
        ? <RegistrosSetData>[]
        : await (select(registrosSet)
              ..where((r) => r.sesionId.isIn(porId.keys)))
            .get();

    final sesionesConSeries = <int>{};
    final dias = <int>{};
    var series = 0;
    var prs = 0;
    var volumen = 0.0;
    var volumenAnterior = 0.0;
    for (final set in sets) {
      final sesion = porId[set.sesionId]!;
      if (sesion.fecha.isBefore(inicio)) {
        volumenAnterior += set.peso * set.reps;
        continue;
      }
      sesionesConSeries.add(sesion.id);
      dias.add(sesion.fecha.weekday);
      series++;
      if (set.esPr) prs++;
      volumen += set.peso * set.reps;
    }
    final segundos = sesionesConSeries.fold<int>(
        0, (total, id) => total + (porId[id]!.duracionSeg ?? 0));

    return ResumenSemana(
      inicio: inicio,
      sesiones: sesionesConSeries.length,
      diasEntrenados: dias,
      series: series,
      prs: prs,
      volumenKg: volumen,
      volumenSemanaAnteriorKg: volumenAnterior,
      segundos: segundos,
    );
  }

  /// Todo lo de una sesión para la pantalla de detalle: el día entrenado y
  /// cada ejercicio con sus series, en el orden en que se ENTRENARON (por
  /// el primer set de cada uno — si se aplazó un ejercicio, aparece donde
  /// de verdad se hizo, no donde estaba en la rutina). Null si la sesión ya
  /// no existe.
  Future<DetalleSesion?> detalleDeSesion(int sesionId) async {
    final cabecera = await (select(sesionesEntrenamiento).join([
      innerJoin(rutinaDias,
          rutinaDias.id.equalsExp(sesionesEntrenamiento.rutinaDiaId)),
    ])
          ..where(sesionesEntrenamiento.id.equals(sesionId)))
        .getSingleOrNull();
    if (cabecera == null) return null;

    final filas = await (select(registrosSet).join([
      innerJoin(rutinaEjercicios,
          rutinaEjercicios.id.equalsExp(registrosSet.rutinaEjercicioId)),
      innerJoin(
          ejercicios, ejercicios.id.equalsExp(rutinaEjercicios.ejercicioId)),
    ])
          ..where(registrosSet.sesionId.equals(sesionId))
          ..orderBy([OrderingTerm.asc(registrosSet.id)]))
        .get();

    // Map conserva el orden de inserción: el del primer set de cada uno.
    final porEjercicio = <int, EjercicioDeSesion>{};
    for (final f in filas) {
      final re = f.readTable(rutinaEjercicios);
      porEjercicio
          .putIfAbsent(
            re.id,
            () => EjercicioDeSesion(
              ejercicioId: re.ejercicioId,
              nombre: f.readTable(ejercicios).nombre,
              series: [],
            ),
          )
          .series
          .add(f.readTable(registrosSet));
    }
    for (final e in porEjercicio.values) {
      e.series.sort((a, b) => a.numeroSet.compareTo(b.numeroSet));
    }

    return DetalleSesion(
      sesion: cabecera.readTable(sesionesEntrenamiento),
      nombreDia: cabecera.readTable(rutinaDias).nombreDia,
      ejercicios: porEjercicio.values.toList(),
    );
  }

  /// Sesiones pasadas con el nombre del día entrenado y un resumen (sets y
  /// volumen total) para que Historial no necesite un query por sesión.
  Future<List<SesionResumen>> historialDeSesiones() async {
    final query = select(sesionesEntrenamiento).join([
      innerJoin(rutinaDias,
          rutinaDias.id.equalsExp(sesionesEntrenamiento.rutinaDiaId)),
    ])
      ..orderBy([OrderingTerm.desc(sesionesEntrenamiento.fecha)]);

    final filas = await query.get();
    final idsDeSesion =
        filas.map((f) => f.readTable(sesionesEntrenamiento).id).toList();

    final sets = idsDeSesion.isEmpty
        ? <RegistrosSetData>[]
        : await (select(registrosSet)
              ..where((r) => r.sesionId.isIn(idsDeSesion)))
            .get();

    final setsPorSesion = <int, List<RegistrosSetData>>{};
    for (final set in sets) {
      setsPorSesion.putIfAbsent(set.sesionId, () => []).add(set);
    }

    return filas.map((f) {
      final sesion = f.readTable(sesionesEntrenamiento);
      final setsDeSesion = setsPorSesion[sesion.id] ?? const [];
      final volumen = setsDeSesion.fold<double>(
          0, (acumulado, s) => acumulado + s.peso * s.reps);
      return SesionResumen(
        sesion: sesion,
        nombreDia: f.readTable(rutinaDias).nombreDia,
        totalSets: setsDeSesion.length,
        volumenTotal: volumen,
      );
    }).toList();
  }
}

/// Combina un [RegistrosSet] con la fecha de la sesión a la que pertenece,
/// para que las gráficas de progreso no necesiten un segundo query.
class RegistroConFecha {
  final RegistrosSetData registro;
  final DateTime fecha;
  const RegistroConFecha({required this.registro, required this.fecha});
}

/// Una sesión de entrenamiento pasada, con el nombre del día y el resumen
/// (sets totales y volumen) que muestra la pantalla de Historial.
class SesionResumen {
  final SesionesEntrenamientoData sesion;
  final String nombreDia;
  final int totalSets;
  final double volumenTotal;
  const SesionResumen({
    required this.sesion,
    required this.nombreDia,
    required this.totalSets,
    required this.volumenTotal,
  });
}

/// Una sesión con sus ejercicios y series, para la pantalla de detalle.
class DetalleSesion {
  final SesionesEntrenamientoData sesion;
  final String nombreDia;

  /// En el orden en que se entrenaron.
  final List<EjercicioDeSesion> ejercicios;

  const DetalleSesion({
    required this.sesion,
    required this.nombreDia,
    required this.ejercicios,
  });

  int get totalSeries =>
      ejercicios.fold(0, (total, e) => total + e.series.length);

  /// Σ peso × reps de todas las series, en kg.
  double get volumenKg =>
      ejercicios.fold(0.0, (total, e) => total + e.volumenKg);

  int get totalPrs => ejercicios.fold(
      0, (total, e) => total + e.series.where((s) => s.esPr).length);
}

/// Un ejercicio dentro de una sesión, con sus series en orden.
class EjercicioDeSesion {
  final int ejercicioId;
  final String nombre;
  final List<RegistrosSetData> series;

  const EjercicioDeSesion({
    required this.ejercicioId,
    required this.nombre,
    required this.series,
  });

  double get volumenKg =>
      series.fold(0.0, (total, s) => total + s.peso * s.reps);
}

/// Lo entrenado en una semana (lunes a domingo), para el anillo y las
/// métricas de Inicio. Solo cuentan las sesiones con al menos una serie:
/// abrir "Entrenar" y salir sin registrar nada no suma.
class ResumenSemana {
  /// Lunes 00:00 de la semana.
  final DateTime inicio;
  final int sesiones;

  /// Días entrenados, 1 = lunes … 7 = domingo.
  final Set<int> diasEntrenados;
  final int series;
  final int prs;
  final double volumenKg;
  final double volumenSemanaAnteriorKg;
  final int segundos;

  const ResumenSemana({
    required this.inicio,
    required this.sesiones,
    required this.diasEntrenados,
    required this.series,
    required this.prs,
    required this.volumenKg,
    required this.volumenSemanaAnteriorKg,
    required this.segundos,
  });
}
