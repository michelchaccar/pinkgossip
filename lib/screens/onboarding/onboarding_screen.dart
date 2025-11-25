import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'dart:ui' as ui;

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

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  // Temporary debug state
  bool _forceSalon = false;

  @override
  void initState() {
    super.initState();
    print("DEBUG: OnboardingScreen received userType: ${widget.userType}");
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
      body: Stack(
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
                    filter:  ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms)),

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
            bottom: 50,
            right: 20,
            child: GestureDetector(
              onTap: _completeOnboarding,
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(left: 24, right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF94C2),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4081).withOpacity(0.4),
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
                            Languages.of(context)!.letsStartText,
                            style: GoogleFonts.archivoBlack(
                              fontSize: 20,
                              color: const Color(0xFFC51162),
                            ),
                          ),
                        ),
                        // Layer 2
                        Positioned(
                          left: 2.0,
                          top: 2.0,
                          child: Text(
                            Languages.of(context)!.letsStartText,
                            style: GoogleFonts.archivoBlack(
                              fontSize: 20,
                              color: const Color(0xFFC51162),
                            ),
                          ),
                        ),
                        // Layer 3 (Closest to top)
                        Positioned(
                          left: 1.0,
                          top: 1.0,
                          child: Text(
                            Languages.of(context)!.letsStartText,
                            style: GoogleFonts.archivoBlack(
                              fontSize: 20,
                              color: const Color(0xFFC51162),
                            ),
                          ),
                        ),
                        // Main Text (Top)
                        Text(
                          Languages.of(context)!.letsStartText,
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
                        color: Color(0xFFF50057),
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
            ).animate().moveY(begin: 100, end: 0, duration: 300.ms, delay: 300.ms, curve: Curves.easeOut).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedText(String text) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: GoogleFonts.archivoBlack(
            fontSize: 46,
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
          style: GoogleFonts.archivoBlack(
            fontSize: 46,
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
