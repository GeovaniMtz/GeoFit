/// Unidad en la que el usuario ve y captura los pesos.
///
/// La base de datos siempre guarda kilogramos: la unidad solo cambia cómo se
/// muestran y capturan los valores. Así cambiar de kg a lb (o al revés) no
/// toca ni reinterpreta el historial ya registrado.
enum UnidadPeso {
  kg,
  lb;

  static const double librasPorKilo = 2.2046226218;

  static UnidadPeso desdeTexto(String valor) =>
      valor == 'lb' ? UnidadPeso.lb : UnidadPeso.kg;

  /// Como se guarda en `Configuracion.unidadPeso`.
  String get texto => name;

  /// Etiqueta corta para la interfaz ("KG" / "LB").
  String get etiqueta => name.toUpperCase();

  /// Incremento de los botones −/+ al ajustar el peso de una serie: el disco
  /// más chico que se suele cargar por lado en cada sistema.
  double get paso => this == UnidadPeso.kg ? 2.5 : 5;

  /// Peso de arranque cuando el ejercicio no tiene historial (la barra
  /// olímpica en cada sistema).
  double get pesoInicial => this == UnidadPeso.kg ? 20 : 45;

  /// Kilos guardados → valor en esta unidad.
  double desdeKg(double kg) => this == UnidadPeso.kg ? kg : kg * librasPorKilo;

  /// Valor en esta unidad → kilos para guardar.
  double aKg(double valor) =>
      this == UnidadPeso.kg ? valor : valor / librasPorKilo;

  /// Kilos guardados → valor en esta unidad redondeado al medio más cercano,
  /// para que un registro hecho en la otra unidad (p. ej. 60 kg → 132.28 lb)
  /// arranque en un número que se pueda cargar en la barra.
  double desdeKgRedondeado(double kg) => (desdeKg(kg) * 2).round() / 2;

  /// Kilos → kilos equivalentes al múltiplo de [paso] más cercano en esta
  /// unidad (2.5 kg o 5 lb): un peso sugerido que se pueda cargar en la
  /// barra, p. ej. el 90% de 62.5 kg (56.25) → 57.5 kg.
  double redondearAPasoKg(double kg) =>
      aKg((desdeKg(kg) / paso).round() * paso);

  /// Kilos guardados → texto en esta unidad, sin decimales cuando el valor
  /// es entero ("60", "132.5").
  String formatear(double kg, {int decimales = 1}) {
    final valor = desdeKg(kg);
    final redondeado = double.parse(valor.toStringAsFixed(decimales));
    return redondeado == redondeado.roundToDouble()
        ? redondeado.toStringAsFixed(0)
        : redondeado.toStringAsFixed(decimales);
  }

  /// Como [formatear] pero con la unidad pegada ("60 kg").
  String formatearConUnidad(double kg, {int decimales = 1}) =>
      '${formatear(kg, decimales: decimales)} $name';
}
