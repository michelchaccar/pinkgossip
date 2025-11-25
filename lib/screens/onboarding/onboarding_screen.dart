import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
            top: 80,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOutlinedText("WELCOME ON"),
                _buildOutlinedText("PINK GOSSIP"),
              ],
            ).animate().moveY(begin: -100, end: 0, duration: 800.ms, delay: 200.ms, curve: Curves.easeOut).fadeIn(),
          ),

          // Skip Button (Fade-in)
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: _cancelOnboarding,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.rubik(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          // Description Card (Right-to-left animation)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Butterfly (Flying animation)
                  Positioned(
                    top: -100,
                    left: -80,
                    child: Image.asset(
                      "lib/assets/images/onboarding/salon_butterfly.png",
                      width: 120,
                      height: 120,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .moveY(begin: 0, end: -10, duration: 2000.ms, curve: Curves.easeInOut)
                        .then()
                        .moveY(begin: -10, end: 0, duration: 2000.ms, curve: Curves.easeInOut)
                        .animate() // Separate animation for entrance
                        .moveX(begin: -200, end: 0, duration: 1500.ms, delay: 1200.ms, curve: Curves.easeOut)
                        .fadeIn(duration: 500.ms, delay: 1200.ms),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      children: [
                        const TextSpan(text: "You’re about to turn your beauty salon clients into your best "),
                        TextSpan(
                          text: "marketers.",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE91E8C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().moveX(begin: 100, end: 0, duration: 800.ms, delay: 1000.ms, curve: Curves.easeOut).fadeIn(),
          ),

          // Let's Start Button (Bottom-to-top animation)
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _completeOnboarding,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBBDEFB), Color(0xFFE1BEE7), Color(0xFFF8BBD0)], // Blue-Purple-Pink pastel gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "LET'S START",
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
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
            fontSize: 42,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = const Color(0xFFFF1493), // Deep Pink
          ),
        ),
        // Fill
        Text(
          text,
          style: GoogleFonts.archivoBlack(
            fontSize: 42,
            color: const Color(0xFFFFE5F5), // Light Pink
            shadows: [
              BoxShadow(
                color: const Color(0xFFFF1493).withOpacity(0.3),
                blurRadius: 20,
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
