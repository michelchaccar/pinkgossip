import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text with pink outline and glow effect for onboarding titles
class OutlinedText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double fontSize;
  final double height;

  const OutlinedText(
    this.text, {
    Key? key,
    this.textAlign = TextAlign.start,
    this.fontSize = 46,
    this.height = 0.9,
  }) : super(key: key);

  static const Color _kVibrantPink = Color(0xFFFF1493);
  static const Color _kPalePink = Color(0xFFFFE5F5);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          textAlign: textAlign,
          style: GoogleFonts.archivoBlack(
            fontSize: fontSize,
            height: height,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = _kVibrantPink,
          ),
        ),
        // Fill
        Text(
          text,
          textAlign: textAlign,
          style: GoogleFonts.archivoBlack(
            fontSize: fontSize,
            height: height,
            color: _kPalePink,
            shadows: [
              BoxShadow(
                color: _kVibrantPink.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 0),
              )
            ],
          ),
        ),
      ],
    );
  }
}
