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

  /// Nombre que tenía en el catálogo el ejercicio de [ejercicioId] cuando se
  /// cargó este borrador (null si es nuevo). No se actualiza con cada edición
  /// del campo "Nombre": sirve para detectar, al guardar, si el usuario
  /// corrigió el nombre — en ese caso hay que reflejar el cambio también en
  /// el catálogo, en vez de descartarlo en silencio.
  final String? nombreEjercicioOriginal;

  EjercicioBorrador({
    this.rutinaEjercicioId,
    this.ejercicioId,
    required this.nombreEjercicio,
    this.seriesObjetivo = 3,
    this.repsMin = 8,
    this.repsMax = 12,
    this.descansoSeg = 90,
    this.nombreEjercicioOriginal,
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
