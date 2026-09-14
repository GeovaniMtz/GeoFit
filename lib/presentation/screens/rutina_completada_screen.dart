import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../domain/frases_motivacionales.dart';
import '../widgets/entrenar/confeti.dart';

/// Pantalla de cierre al registrar la última serie del último ejercicio de
/// la sesión: celebra con confeti y una frase motivadora elegida al azar.
class RutinaCompletadaScreen extends StatefulWidget {
  final VoidCallback onVolver;
  const RutinaCompletadaScreen({super.key, required this.onVolver});

  @override
  State<RutinaCompletadaScreen> createState() => _RutinaCompletadaScreenState();
}

class _RutinaCompletadaScreenState extends State<RutinaCompletadaScreen> {
  // Se elige una sola vez al entrar a la pantalla, no en cada build.
  late final String _frase = fraseMotivacionalAleatoria();

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ConfetiCelebracion()),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    const SizedBox(height: 24),
                    Text(
                      '¡RUTINA COMPLETADA!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"$_frase"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.onVolver,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
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
