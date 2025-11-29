import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'dart:ui' as ui;
import 'dart:math';

class OnboardingScreen extends StatefulWidget {
  final String userType; // "1" for User, "2" for Salon (Consistent with LoginModel logic)
  final String userId;

  const OnboardingScreen({
    Key? key,
    required this.userType,
    required this.userId,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _butterflyController;
  late AnimationController _cycleController;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed_${widget.userId}', true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _cancelOnboarding() {
    Navigator.of(context).pop();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Temporary debug state
  bool _forceSalon = false;

  @override
  void initState() {
    super.initState();
    print("DEBUG: OnboardingScreen received userType: ${widget.userType}");
    _butterflyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _cycleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _butterflyController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic: Show Salon if userType is "2" OR if we force it for debugging
    if (widget.userType == "2" || _forceSalon) {
      return _buildSalonOnboarding();
    } else {
      return Scaffold(
        // Wrap the User onboarding in a Scaffold to add the debug button
        body: _buildUserOnboarding(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _forceSalon = true;
            });
          },
          label: const Text("Debug: Show Salon View"),
          icon: const Icon(Icons.remove_red_eye),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSalonOnboarding() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce button navigation
        children: [
          _buildSalonOnboardingStep1(),
          _buildSalonOnboardingStep2(),
        ],
      ),
    );
  }

  Widget _buildButterflyFlight() {
    return AnimatedBuilder(
      animation: Listenable.merge([_butterflyController, _cycleController]),
      builder: (context, child) {
        final butterflies = <Widget>[];
        final random = Random(42); // Fixed seed for consistent randomness across frames

        // Calculate global opacity based on cycle progress
        double globalOpacity = 1.0;
        double cycleProgress = _cycleController.value;

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
          double progress = (_butterflyController.value + (i / 8)) % 1.0;

          // Flight path parameters
          // Start point: Bottom right (closer to phone)
          final double startX = 10 + (random.nextDouble() * 30); 
          final double startY = random.nextDouble() * 20; 
          
          // End point: Fly up and slightly right
          final double endX = startX + 30 + (random.nextDouble() * 40); 
          final double flightHeight = 900 + random.nextDouble() * 100; // Fly up higher to cover screen

          // Interpolate position based on progress
          // Use linear interpolation for constant speed
          double currentX = startX + (endX - startX) * progress;
          
          // Add sway (sine wave)
          // Sway amplitude: 15.0, Frequency: 2 full waves (4 * pi)
          currentX += sin(progress * pi * 4) * 15;

          double currentY = (-50 + startY) + flightHeight * progress; // Start from bottom: -50+startY and go UP

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
              bottom: currentY, // Strictly increasing value
              left: MediaQuery.of(context).size.width / 2 + currentX - 50,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: (progress * 0.5) - 0.25, // Slight rotation during flight
                  child: Image.asset(
                    "lib/assets/images/onboarding/salon_butterfly.png",
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

  Widget _buildSalonOnboardingStep1() {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Model (Bottom-to-top animation)
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "lib/assets/images/onboarding/salon_model.png",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
            ),
          ).animate().moveY(begin: 600, end: 0, duration: 1200.ms, curve: Curves.easeOut),
        ),

        // Title (Top-to-bottom animation)
        Positioned(
          top: 110,
          right: 20,
          left: 20, // Constrain width to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildOutlinedText(Languages.of(context)!.welcomeOnText),
              ),
              const SizedBox(height: 0),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildOutlinedText(Languages.of(context)!.pinkGossipText),
              ),
            ],
          ).animate().moveY(begin: -100, end: 0, duration: 800.ms, delay: 200.ms, curve: Curves.easeOut).fadeIn(),
        ),

        // Skip Button (Fade-in)
        Positioned(
          top: 0,
          right: 20,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: _cancelOnboarding,
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
                        style: GoogleFonts.rubik(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

        // Description Card (Right-to-left animation)
        Positioned(
          right: 20,
          top: MediaQuery.of(context).size.height * 0.52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
               // Card Content
              Container(
                width: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(20),
                   child: BackdropFilter(
                     filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                     child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: Languages.of(context)!.salonOnboardingDescPart1),
                          TextSpan(
                            text: Languages.of(context)!.salonOnboardingDescPart2,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFE91E8C),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                   ),
                ),
              ),
              
              // Butterfly (Flying animation) - Moved OUTSIDE container to overlap correctly
              Positioned(
                top: -150, // Overlapping top
                left: -160, // Overlapping left
                child: Image.asset(
                  "lib/assets/images/onboarding/salon_butterfly.png",
                  width: 320,
                  height: 320,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(begin: 0, end: -15, duration: 2000.ms, curve: Curves.easeInOut)
                    .then()
                    .moveY(begin: -15, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
                    .animate()
                    .moveX(begin: -200, end: 0, duration: 1500.ms, delay: 1200.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 500.ms, delay: 1200.ms),
              ),
            ],
          ).animate().moveX(begin: 100, end: 0, duration: 800.ms, delay: 1000.ms, curve: Curves.easeOut).fadeIn(),
        ),

        // Let's Start Button (Bottom-to-top animation)
        Positioned(
          bottom: 0,
          right: 20,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: _build3DButton(
                text: Languages.of(context)!.letsStartText,
                onPressed: _nextPage,
              ),
            ),
          ),
        ).animate().moveY(begin: 100, end: 0, duration: 300.ms, delay: 300.ms, curve: Curves.easeOut).fadeIn(),
      ],
    );
  }

  Widget _buildSalonOnboardingStep2() {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Phone Mockup (Center)
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100), 
              child: Image.asset(
                "lib/assets/images/onboarding/salon_phone_mockup.png",
                fit: BoxFit.contain,
                // Adjust height/width as needed based on the image aspect ratio
                height: MediaQuery.of(context).size.height * 0.65, 
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).moveY(begin: 50, end: 0, duration: 800.ms, curve: Curves.easeOut),
        ),

        // Butterfly Flight Animation
        Positioned.fill(
          child: _buildButterflyFlight(),
        ),

        // Title (Top)
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: _buildOutlinedText(
              Languages.of(context)!.whatIsPinkGossipText,
              textAlign: TextAlign.center,
            ),
          ).animate().moveY(begin: -50, end: 0, duration: 800.ms, curve: Curves.easeOut),
        ),

        // Description Card (Bottom)
        Positioned(
          bottom: 100, // Moved up to make room for button
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Rounded all corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.archivoBlack(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: Languages.of(context)!.salonOnboarding2Title.trim()),
                  _buildBulletPoint(Languages.of(context)!.salonOnboarding2DescPart1),
                  _buildBulletPoint(Languages.of(context)!.salonOnboarding2DescPart2),
                  _buildBulletPoint(Languages.of(context)!.salonOnboarding2DescPart3),
                ],
              ),
            ),
          ).animate().moveY(begin: 200, end: 0, duration: 800.ms, delay: 200.ms, curve: Curves.easeOut),
        ),

        // Continue Button (Bottom Right)
        Positioned(
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.continueText.toUpperCase(),
            onPressed: _completeOnboarding,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
      ],
    );
  }

  TextSpan _buildBulletPoint(String text) {
    final parts = text.split("->");
    final firstPart = parts.isNotEmpty ? parts[0].trim() : "";
    final secondPart = parts.length > 1 ? parts[1].trim() : "";

    return TextSpan(
      style: GoogleFonts.archivoBlack(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      children: [
        const TextSpan(text: "\n• "),
        TextSpan(text: "$firstPart "),
        const TextSpan(
          text: "➜ ",
          style: TextStyle(
            color: AppColors.onboardingVibrantPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: secondPart),
      ],
    );
  }

  Widget _build3DButton({required String text, required VoidCallback onPressed}) {
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
                color: AppColors.onboardingVibrantPink,
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

  Widget _buildOutlinedText(String text, {TextAlign textAlign = TextAlign.start, double fontSize = 46}) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          textAlign: textAlign,
          style: GoogleFonts.archivoBlack(
            fontSize: fontSize,
            height: 0.9,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = const Color(0xFFFF1493),
          ),
        ),
        // Fill
        Text(
          text,
          textAlign: textAlign,
          style: GoogleFonts.archivoBlack(
            fontSize: fontSize,
            height: 0.9,
            color: const Color(0xFFFFE5F5),
            shadows: [
              BoxShadow(
                color: const Color(0xFFFF1493).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 0),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserOnboarding() {
    // Keep the previous simple design for User for now, or update if needed.
    // The user only provided design for Salon.
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                height: 200,
                width: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Text(
                "Welcome to Pink Gossip!",
                textAlign: TextAlign.center,
                style: GoogleFonts.archivoBlack(
                  fontSize: 24,
                  color: AppColors.kBlackColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Discover the best salons, share your experiences, and connect with others.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.kTextColor,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _cancelOnboarding,
                child: Text(
                  "Cancel",
                  style: GoogleFonts.rubik(
                    color: AppColors.kTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
