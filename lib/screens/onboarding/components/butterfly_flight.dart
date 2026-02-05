import 'package:flutter/material.dart';
import 'dart:math';

/// Butterfly flight animation for onboarding screen 2
class ButterflyFlight extends StatelessWidget {
  final AnimationController butterflyController;
  final AnimationController cycleController;
  final String butterflyAsset;

  const ButterflyFlight({
    Key? key,
    required this.butterflyController,
    required this.cycleController,
    this.butterflyAsset = "lib/assets/images/onboarding/salon_butterfly.png",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([butterflyController, cycleController]),
      builder: (context, child) {
        final butterflies = <Widget>[];
        final random = Random(42); // Fixed seed for consistent randomness across frames

        // Calculate global opacity based on cycle progress
        double globalOpacity = 1.0;
        double cycleProgress = cycleController.value;

        if (cycleProgress > 0.7 && cycleProgress <= 0.8) {
          // Fade out (70% → 80%)
          globalOpacity = 1.0 - ((cycleProgress - 0.7) / 0.1);
        } else if (cycleProgress > 0.8 && cycleProgress <= 0.9) {
          // Pause (80% → 90%)
          globalOpacity = 0.0;
        } else if (cycleProgress > 0.9) {
          // Fade in (90% → 100%)
          globalOpacity = (cycleProgress - 0.9) / 0.1;
        }

        // Generate butterflies based on controller value
        for (int i = 0; i < 8; i++) {
          // Calculate progress for this butterfly
          // Offset each butterfly by i/8 of the cycle
          double progress = (butterflyController.value + (i / 8)) % 1.0;

          // Flight path parameters
          // Start point: Bottom right (closer to phone)
          final double startX = 10 + (random.nextDouble() * 30);
          final double startY = random.nextDouble() * 20;

          // End point: Fly up and slightly right
          final double endX = startX + 30 + (random.nextDouble() * 40);
          final double flightHeight = 900 + random.nextDouble() * 100;

          // Interpolate position based on progress
          // Use linear interpolation for constant speed
          double currentX = startX + (endX - startX) * progress;

          // Add sway (sine wave)
          // Sway amplitude: 15.0, Frequency: 2 full waves (4 * pi)
          currentX += sin(progress * pi * 4) * 15;

          double currentY = (-50 + startY) + flightHeight * progress;

          // Scale
          final double scale = random.nextDouble() * 0.2 + 0.8;

          // Opacity: Fade in at start, fade out at end
          double opacity = 1.0;
          if (progress < 0.1) {
            opacity = progress / 0.1;
          } else if (progress > 0.8) {
            opacity = 1.0 - ((progress - 0.8) / 0.2);
          }

          // Apply global cycle opacity
          opacity = opacity * globalOpacity;

          butterflies.add(
            Positioned(
              bottom: currentY,
              left: MediaQuery.of(context).size.width / 2 + currentX - 50,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: (progress * 0.5) - 0.25,
                  child: Image.asset(
                    butterflyAsset,
                    width: 200 * scale,
                    height: 200 * scale,
                  ),
                ),
              ),
            ),
          );
        }
        return Stack(children: butterflies);
      },
    );
  }
}
