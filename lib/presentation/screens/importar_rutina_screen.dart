import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/clasificador_ejercicio.dart';
import '../../domain/importador_rutina.dart';
import '../providers/providers.dart';
import '../widgets/rutina_form/borrador.dart';

/// Permite pegar una rutina completa como texto libre (de una nota,
/// cuaderno, etc.) y la convierte en días/ejercicios que se entregan, ya
/// prellenados, a [RutinaFormScreen] para revisar y guardar — evita tener
/// que abrir el diálogo de "agregar ejercicio" una vez por cada ejercicio.
class ImportarRutinaScreen extends ConsumerStatefulWidget {
  const ImportarRutinaScreen({super.key});

  @override
  ConsumerState<ImportarRutinaScreen> createState() =>
      _ImportarRutinaScreenState();
}

class _ImportarRutinaScreenState extends ConsumerState<ImportarRutinaScreen> {
  final _controladorTexto = TextEditingController();
  ResultadoImportacion? _resultado;
  List<DiaBorrador>? _diasParaRevisar;
  bool _analizando = false;
  bool _escaneando = false;

  @override
  void dispose() {
    _controladorTexto.dispose();
    super.dispose();
  }

  /// Toma o elige una foto de la rutina, la pasa por OCR y agrega el texto
  /// reconocido al campo de texto — el usuario lo revisa y corrige ahí
  /// mismo (el OCR falla seguido con letra manuscrita) antes de "ANALIZAR".
  Future<void> _escanear(ImageSource origen) async {
    XFile? foto;
    try {
      foto = await ImagePicker().pickImage(source: origen, imageQuality: 85);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo abrir la cámara o la galería.'),
      ));
      return;
    }
    if (foto == null) return; // el usuario canceló

    setState(() => _escaneando = true);
    try {
      final texto = await ref
          .read(escanerRutinaServiceProvider)
          .reconocerTexto(foto.path);
      if (!mounted) return;

      if (texto.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'No se reconoció texto en la foto. Prueba con más luz o '
            'acercando más la cámara.',
          ),
        ));
        return;
      }

      setState(() {
        final actual = _controladorTexto.text;
        _controladorTexto.text =
            actual.trim().isEmpty ? texto : '$actual\n$texto';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Texto reconocido: revísalo y corrige lo que haga falta antes '
          'de analizar.',
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo leer el texto de la foto.'),
      ));
    } finally {
      if (mounted) setState(() => _escaneando = false);
    }
  }

  Future<void> _analizar() async {
    setState(() {
      _analizando = true;
      _resultado = null;
      _diasParaRevisar = null;
    });

    final resultado = ImportadorRutina.parsear(_controladorTexto.text);
    final catalogo = await ref.read(catalogoDeEjerciciosProvider.future);

    final dias = <DiaBorrador>[];
    for (final diaParseado in resultado.dias) {
      final dia = DiaBorrador()..controladorNombre.text = diaParseado.nombre;
      for (final ejercicioParseado in diaParseado.ejercicios) {
        final match =
            ImportadorRutina.buscarCoincidencia(ejercicioParseado.nombre, catalogo);
        final nombreFinal = match?.nombre ?? ejercicioParseado.nombre;
        dia.ejercicios.add(EjercicioBorrador(
          ejercicioId: match?.id,
          nombreEjercicio: nombreFinal,
          seriesObjetivo: ejercicioParseado.series,
          repsMin: ejercicioParseado.repsMin,
          repsMax: ejercicioParseado.repsMax,
          descansoSeg: ClasificadorEjercicio.descansoSugeridoSeg(nombreFinal),
        ));
      }
      dias.add(dia);
    }

    if (!mounted) return;
    setState(() {
      _resultado = resultado;
      _diasParaRevisar = dias;
      _analizando = false;
    });
  }

  Future<void> _continuar() async {
    final resultado = await context.push<String>(
      '/rutinas/nueva',
      extra: _diasParaRevisar,
    );
    if (!mounted) return;
    // Si el usuario descartó la revisión (resultado nulo), nos quedamos en
    // esta pantalla con el texto pegado intacto por si quiere corregirlo.
    if (resultado == 'guardado') {
      Navigator.of(context).pop('guardado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;
    final dias = _diasParaRevisar;
    final puedeContinuar = resultado != null && resultado.totalEjercicios > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Importar rutina')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Escanea o pega tu rutina completa: un ejercicio por línea con '
            'series y reps (p. ej. "Sentadilla 4x8-12"). Separa los días '
            'con un encabezado como "Día 1: Pecho".',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _escaneando
                      ? null
                      : () => _escanear(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _escaneando
                      ? null
                      : () => _escanear(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          if (_escaneando) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controladorTexto,
            maxLines: 12,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText: 'Día 1: Pecho\n'
                  'Press banca 4x8-12\n'
                  'Aperturas con mancuerna 3x12-15\n'
                  '\n'
                  'Día 2: Espalda\n'
                  'Dominadas 4x6-10\n'
                  '...',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _analizando ? null : _analizar,
              child: _analizando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ANALIZAR'),
            ),
          ),
          if (resultado != null && dias != null) ...[
            const SizedBox(height: 20),
            Text(
              '${dias.length} días, ${resultado.totalEjercicios} '
              'ejercicios detectados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < resultado.dias.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dias[i].controladorNombre.text.isEmpty
                            ? 'Día ${i + 1}'
                            : dias[i].controladorNombre.text,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      for (var j = 0; j < resultado.dias[i].ejercicios.length; j++)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${resultado.dias[i].ejercicios[j].nombre} · '
                            '${dias[i].ejercicios[j].seriesObjetivo}x'
                            '${dias[i].ejercicios[j].repsMin}-'
                            '${dias[i].ejercicios[j].repsMax} · '
                            '${dias[i].ejercicios[j].ejercicioId != null ? 'Coincide con: ${dias[i].ejercicios[j].nombreEjercicio}' : 'Ejercicio nuevo'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (resultado.lineasNoReconocidas.isNotEmpty)
              ExpansionTile(
                title: Text(
                  '${resultado.lineasNoReconocidas.length} líneas no '
                  'reconocidas',
                ),
                children: [
                  for (final linea in resultado.lineasNoReconocidas)
                    ListTile(dense: true, title: Text(linea)),
                ],
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: puedeContinuar ? _continuar : null,
                child: const Text('CONTINUAR'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
