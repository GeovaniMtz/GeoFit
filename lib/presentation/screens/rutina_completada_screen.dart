import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../domain/frases_motivacionales.dart';
import '../providers/providers.dart';
import '../widgets/entrenar/confeti.dart';

/// Pantalla de cierre al registrar la última serie del último ejercicio de
/// la sesión: celebra con confeti y una frase motivadora elegida al azar,
/// muestra cuánto duró la sesión y deja anotar algo sobre ella ("me dolió
/// el hombro", "dormí mal") antes de volver.
class RutinaCompletadaScreen extends ConsumerStatefulWidget {
  final int sesionId;
  final VoidCallback onVolver;
  const RutinaCompletadaScreen({
    super.key,
    required this.sesionId,
    required this.onVolver,
  });

  @override
  ConsumerState<RutinaCompletadaScreen> createState() =>
      _RutinaCompletadaScreenState();
}

class _RutinaCompletadaScreenState
    extends ConsumerState<RutinaCompletadaScreen> {
  // Se elige una sola vez al entrar a la pantalla, no en cada build.
  late final String _frase = fraseMotivacionalAleatoria();
  final _controladorNotas = TextEditingController();
  late final AppDatabase _db = ref.read(databaseProvider);
  int? _duracionSeg;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final sesion = await _db.obtenerSesion(widget.sesionId);
    if (!mounted) return;
    setState(() {
      _duracionSeg = sesion.duracionSeg;
      // Si ya se habían escrito notas (p. ej. se reabrió la sesión), se
      // retoman en vez de pisarlas con un campo vacío.
      if (_controladorNotas.text.isEmpty && sesion.notas != null) {
        _controladorNotas.text = sesion.notas!;
      }
    });
  }

  @override
  void dispose() {
    // Se guarda también al salir por el botón de regresar del sistema, no
    // solo con "VOLVER AL INICIO". No se espera: dispose() no es async.
    _db.guardarNotasSesion(widget.sesionId, _controladorNotas.text);
    _controladorNotas.dispose();
    super.dispose();
  }

  Future<void> _volver() async {
    await _db.guardarNotasSesion(widget.sesionId, _controladorNotas.text);
    widget.onVolver();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duracion = _duracionSeg;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ConfetiCelebracion()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: GeoLiftSpacing.xxl,
                    vertical: GeoLiftSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, valor, child) => Transform.scale(
                        scale: valor,
                        child: child,
                      ),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.secondary, width: 2),
                        ),
                        child: Icon(Icons.emoji_events,
                            size: 52, color: colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(height: GeoLiftSpacing.xl),
                    Text(
                      '¡RUTINA COMPLETADA!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (duracion != null && duracion > 0) ...[
                      const SizedBox(height: GeoLiftSpacing.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: GeoLiftSpacing.xs),
                          Text(
                            formatearDuracion(duracion),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: GeoLiftSpacing.lg),
                    Text(
                      '"$_frase"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: GeoLiftSpacing.xl),
                    TextField(
                      controller: _controladorNotas,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notas de la sesión (opcional)',
                        hintText: 'p. ej. me molestó el hombro en el press',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: GeoLiftSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _volver,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: const Text('VOLVER AL INICIO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segundos → "48 min" / "1 h 05 min" / "40 s".
String formatearDuracion(int segundos) {
  if (segundos < 60) return '$segundos s';
  final minutos = segundos ~/ 60;
  if (minutos < 60) return '$minutos min';
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  return '$horas h ${resto.toString().padLeft(2, '0')} min';
}
