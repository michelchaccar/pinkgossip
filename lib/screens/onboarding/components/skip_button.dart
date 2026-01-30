import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' as ui;
import 'package:pinkGossip/localization/language/languages.dart';

/// Skip button with frosted glass effect for onboarding
class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 20,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: onPressed,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    Languages.of(context)!.skipText,
                    style: GoogleFonts.archivoBlack(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }
}
