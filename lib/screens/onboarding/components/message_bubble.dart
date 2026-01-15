import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinkGossip/screens/onboarding/config/responsive_config.dart';

/// Animated message bubble for onboarding screens
class MessageBubble extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final int delay;
  final OnboardingResponsiveConfig config;

  const MessageBubble({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.textColor = Colors.black87,
    required this.delay,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: config.screen5BubblePadding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.archivoBlack(
              fontSize: config.screen5BubbleTitleFontSize,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: config.screen5BubbleInnerSpacing),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: config.screen5BubbleSubtitleFontSize,
                color: textColor.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    ).animate().moveY(begin: 100, end: 0, duration: 600.ms, delay: delay.ms, curve: Curves.easeOut).fadeIn(delay: delay.ms);
  }
}
