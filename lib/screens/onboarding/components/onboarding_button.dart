import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinkGossip/utils/color_utils.dart';

/// Reusable 3D button for onboarding (salon and gossiper)
class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  static const Color _kVibrantPink = Color(0xFFFF1493);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 24, right: 8),
        decoration: BoxDecoration(
          color: AppColors.onboardingBubblegumPink,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardingShadowPink.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text with 3D Block Shadow (Extrusion)
            Stack(
              children: [
                // Layer 1 (Deepest)
                Positioned(
                  left: 3.0,
                  top: 3.0,
                  child: Text(
                    text,
                    style: GoogleFonts.archivoBlack(
                      fontSize: 20,
                      color: AppColors.onboardingDeepPink,
                    ),
                  ),
                ),
                // Layer 2
                Positioned(
                  left: 2.0,
                  top: 2.0,
                  child: Text(
                    text,
                    style: GoogleFonts.archivoBlack(
                      fontSize: 20,
                      color: AppColors.onboardingDeepPink,
                    ),
                  ),
                ),
                // Layer 3 (Closest to top)
                Positioned(
                  left: 1.0,
                  top: 1.0,
                  child: Text(
                    text,
                    style: GoogleFonts.archivoBlack(
                      fontSize: 20,
                      color: AppColors.onboardingDeepPink,
                    ),
                  ),
                ),
                // Main Text (Top)
                Text(
                  text,
                  style: GoogleFonts.archivoBlack(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Circular Icon
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _kVibrantPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
