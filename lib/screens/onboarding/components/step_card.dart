import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinkGossip/screens/onboarding/config/responsive_config.dart';

/// Card with butterfly for onboarding screen 4
class StepCard extends StatelessWidget {
  final String text;
  final int delay;
  final OnboardingResponsiveConfig config;
  final bool isRightAligned;
  final String butterflyAsset;

  const StepCard({
    Key? key,
    required this.text,
    required this.delay,
    required this.config,
    this.isRightAligned = false,
    this.butterflyAsset = "lib/assets/images/onboarding/salon_butterfly.png",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isRightAligned) ...[
            _buildButterfly(),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: config.screen4CardTextFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          if (isRightAligned) ...[
            const SizedBox(width: 12),
            _buildButterfly(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).moveX(begin: isRightAligned ? 50 : -50, end: 0);
  }

  Widget _buildButterfly() {
    return Transform.rotate(
      angle: 0.4,
      child: Transform.flip(
        flipX: true,
        child: Image.asset(
          butterflyAsset,
          width: config.screen4CardButterflySize,
          height: config.screen4CardButterflySize,
        ),
      ),
    );
  }
}
