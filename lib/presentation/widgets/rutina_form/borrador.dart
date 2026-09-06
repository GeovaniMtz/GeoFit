import 'package:flutter/material.dart';

/// Ejercicio objetivo dentro de un día, mientras se arma el formulario
/// (todavía no existe en la base de datos hasta que se guarda la rutina).
class EjercicioBorrador {
  /// Id de la fila en RutinaEjercicios si este ejercicio ya estaba guardado
  /// (se editó una rutina existente); null si es nuevo y falta insertarlo.
  int? rutinaEjercicioId;
  int? ejercicioId;
  String nombreEjercicio;
  int seriesObjetivo;
  int repsMin;
  int repsMax;
  int descansoSeg;

  EjercicioBorrador({
    this.rutinaEjercicioId,
    this.ejercicioId,
    required this.nombreEjercicio,
    this.seriesObjetivo = 3,
    this.repsMin = 8,
    this.repsMax = 12,
    this.descansoSeg = 90,
  });
}

class DiaBorrador {
  /// Id de la fila en RutinaDias si este día ya estaba guardado; null si es
  /// un día nuevo agregado en esta edición.
  int? diaId;
  final controladorNombre = TextEditingController();
  final List<EjercicioBorrador> ejercicios = [];

  /// Ids (en RutinaEjercicios) de los ejercicios que tenía este día al
  /// cargar el formulario, para saber cuáles se quitaron y borrarlos al
  /// guardar.
  final Set<int> idsOriginalesDeEjercicios = {};
}
