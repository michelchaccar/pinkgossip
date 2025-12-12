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

  // Consistent Colors
  static const Color _kVibrantPink = Color(0xFFFF1493); // DeepPink
  static const Color _kPalePink = Color(0xFFFFE5F5);

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
    if (widget.userType == "1" || _forceSalon) {
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
          _buildSalonOnboardingStep3(),
          _buildSalonOnboardingStep4(),
          _buildSalonOnboardingStep5(),
          _buildSalonOnboardingStep6(),
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
        _buildSkipButton(),

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
                        style: GoogleFonts.archivoBlack( // Changed to Archivo Black for consistency
                          fontSize: 24, 
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: Languages.of(context)!.salonOnboardingDescPart1),
                          TextSpan(
                            text: Languages.of(context)!.salonOnboardingDescPart2,
                            style: GoogleFonts.archivoBlack(
                              color: _kVibrantPink, // Use consistent pink
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
                top: -200, // Overlapping top
                left: -200, // Overlapping left
                child: Image.asset(
                  "lib/assets/images/onboarding/salon_butterfly.png",
                  width: 400,
                  height: 400,
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
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.letsStartText,
            onPressed: _nextPage,
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
                Localizations.localeOf(context).languageCode == 'en'
                    ? "lib/assets/images/onboarding/salon_phone_mockup_en.png"
                    : "lib/assets/images/onboarding/salon_phone_mockup_fr.png",
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
          top: 110,
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
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        // Skip Button
        _buildSkipButton(),
      ],
    );
  }

  Widget _buildSalonOnboardingStep3() {
    final config = _ResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Layer 1: Background (unchanged)
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Layer 2: Scrollable content
        SafeArea(
          child: SingleChildScrollView(
            physics: config.isVerySmall
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: config.topPadding),
                _buildStep3Title(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3TopCard(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3QRCode(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3Description(config),
                SizedBox(height: config.bottomSpacing), // Adaptive space for button
              ],
            ),
          ),
        ),

        // Layer 3: Fixed UI elements (unchanged)
        Positioned(
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.nextStepsText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        _buildSkipButton(),
      ],
    );
  }

  // Helper widgets for Screen 3
  Widget _buildStep3Title(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _buildOutlinedText(
          Languages.of(context)!.salonOnboarding3Title,
          textAlign: TextAlign.center,
          fontSize: config.titleFontSize,
        ),
      ),
    ).animate().moveY(begin: -50, end: 0, duration: 800.ms, curve: Curves.easeOut);
  }

  Widget _buildStep3TopCard(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: config.cardInsets,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            Transform.rotate(
              angle: 0.4,
              child: Transform.flip(
                flipX: true,
                child: Image.asset(
                  "lib/assets/images/onboarding/salon_butterfly.png",
                  width: config.butterflySize,
                  height: config.butterflySize,
                ),
              ),
            ),
            Expanded(
              child: Text(
                Languages.of(context)!.salonOnboarding3CardTitle,
                style: GoogleFonts.poppins(
                  fontSize: config.cardTitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveX(begin: -50, end: 0);
  }

  Widget _buildStep3QRCode(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Transform.scale(
              scale: config.qrCodeScale,
              child: Image.asset(
                "lib/assets/images/onboarding/code_QR.png",
                width: config.qrCodeSize,
                height: config.qrCodeSize,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 600.ms, delay: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStep3Description(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(config.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            style: GoogleFonts.archivoBlack(
              fontSize: config.bodyFontSize,
              color: Colors.black87,
              height: 1.3,
            ),
            children: [
              TextSpan(
                text: Languages.of(context)!.salonOnboarding3DescPart1,
                style: GoogleFonts.archivoBlack(
                  color: _kVibrantPink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: Languages.of(context)!.salonOnboarding3DescPart2,
                style: GoogleFonts.archivoBlack(
                  color: const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().moveY(begin: 100, end: 0, duration: 600.ms, delay: 600.ms, curve: Curves.easeOut);
  }

  // Helper widgets for Screen 4
  Widget _buildStep4Title(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: _buildOutlinedText(
          Languages.of(context)!.salonOnboarding4Title,
          textAlign: TextAlign.center,
          fontSize: config.screen4TitleFontSize,
          height: 1.1,
        ),
      ),
    ).animate().moveY(begin: -50, end: 0, duration: 800.ms, curve: Curves.easeOut);
  }

  Widget _buildStep4Cards(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildStep4Card(
            text: Languages.of(context)!.salonOnboarding4Card1,
            delay: 200,
            config: config,
          ),
          SizedBox(height: config.cardSpacing),
          _buildStep4Card(
            text: Languages.of(context)!.salonOnboarding4Card2,
            delay: 400,
            config: config,
          ),
          SizedBox(height: config.cardSpacing),
          _buildStep4Card(
            text: Languages.of(context)!.salonOnboarding4Card3,
            delay: 600,
            isRightAligned: true,
            config: config,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4BoomSection(_ResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.boomPadding,
          vertical: config.boomPadding * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.archivoBlack(
                  fontSize: config.boomTitleFontSize,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: "Boom",
                    style: GoogleFonts.archivoBlack(
                      color: _kVibrantPink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(text: " — "),
                  TextSpan(
                    text: Languages.of(context)!.salonOnboarding4BottomTitle.replaceAll("Boom — ", ""),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Languages.of(context)!.salonOnboarding4BottomDesc,
              style: GoogleFonts.archivoBlack(
                fontSize: config.boomDescFontSize,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ).animate().moveY(begin: 100, end: 0, duration: 600.ms, delay: 800.ms, curve: Curves.easeOut);
  }

  Widget _buildSalonOnboardingStep4() {
    final config = _ResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Layer 1: Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Layer 2: Scrollable content
        SafeArea(
          child: SingleChildScrollView(
            physics: config.isVerySmall
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: config.topPadding),
                _buildStep4Title(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep4Cards(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep4BoomSection(config),
                SizedBox(height: config.bottomSpacing),
              ],
            ),
          ),
        ),

        // Layer 3: Fixed UI elements
        Positioned(
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.whyChooseUsText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),

        _buildSkipButton(),
      ],
    );
  }

  Widget _buildSalonOnboardingStep5() {
    final config = _ResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Layer 1: Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Layer 2: Phone Mockup (Center, responsive size)
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: config.phoneBottomPadding),
              child: Image.asset(
                "lib/assets/images/onboarding/phone.png",
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * config.phoneHeightRatio,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).moveY(begin: 50, end: 0, duration: 800.ms, curve: Curves.easeOut),
        ),

        // Layer 3: Title (Top, responsive)
        Positioned(
          top: config.screen5TitleTop,
          left: 0,
          right: 0,
          child: Center(
            child: _buildOutlinedText(
              Languages.of(context)!.salonOnboarding5Title,
              textAlign: TextAlign.center,
              fontSize: config.screen5TitleFontSize,
              height: 1.2,
            ),
          ).animate().moveY(begin: -50, end: 0, duration: 800.ms, curve: Curves.easeOut),
        ),

        // Layer 4: Message Bubbles (Bottom, responsive)
        Positioned(
          bottom: config.bubblesBottom,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMessageBubble(
                title: Languages.of(context)!.salonOnboarding5Bubble1.split('\n')[0],
                subtitle: Languages.of(context)!.salonOnboarding5Bubble1.split('\n').length > 1
                    ? Languages.of(context)!.salonOnboarding5Bubble1.split('\n')[1]
                    : "",
                color: const Color(0xFFFFE5F5),
                delay: 200,
                config: config,
              ),
              SizedBox(height: config.bubbleSpacing),
              _buildMessageBubble(
                title: Languages.of(context)!.salonOnboarding5Bubble2.split('\n')[0],
                subtitle: Languages.of(context)!.salonOnboarding5Bubble2.split('\n').length > 1
                    ? Languages.of(context)!.salonOnboarding5Bubble2.split('\n')[1]
                    : "",
                color: const Color(0xFFFF69B4),
                textColor: Colors.white,
                delay: 400,
                config: config,
              ),
              SizedBox(height: config.bubbleSpacing),
              _buildMessageBubble(
                title: Languages.of(context)!.salonOnboarding5Bubble3.split('\n')[0],
                subtitle: Languages.of(context)!.salonOnboarding5Bubble3.split('\n').length > 1
                    ? Languages.of(context)!.salonOnboarding5Bubble3.split('\n')[1]
                    : "",
                color: const Color(0xFFFFE5F5),
                delay: 600,
                config: config,
              ),
              SizedBox(height: config.bubbleSpacing),
              _buildMessageBubble(
                title: Languages.of(context)!.salonOnboarding5Bubble4.split('\n')[0],
                subtitle: Languages.of(context)!.salonOnboarding5Bubble4.split('\n').length > 1
                    ? Languages.of(context)!.salonOnboarding5Bubble4.split('\n')[1]
                    : "",
                color: const Color(0xFFFF69B4),
                textColor: Colors.white,
                delay: 800,
                config: config,
              ),
            ],
          ),
        ),

        // Layer 5: Fixed UI elements
        Positioned(
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.areYouReadyText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

        _buildSkipButton(),
      ],
    );
  }

  Widget _buildMessageBubble({
    required String title,
    required String subtitle,
    required Color color,
    Color textColor = Colors.black87,
    required int delay,
    required _ResponsiveConfig config,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: config.bubblePadding,
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
              fontSize: config.bubbleTitleFontSize,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: config.bubbleSubtitleFontSize,
                color: textColor.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    ).animate().moveY(begin: 100, end: 0, duration: 600.ms, delay: delay.ms, curve: Curves.easeOut).fadeIn(delay: delay.ms);
  }

  Widget _buildStep4Card({
    required String text,
    required int delay,
    required _ResponsiveConfig config,
    bool isRightAligned = false,
  }) {
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
             Transform.rotate(
                angle: 0.4,
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset(
                    "lib/assets/images/onboarding/salon_butterfly.png",
                    width: config.cardButterflySize,
                    height: config.cardButterflySize,
                  ),
                ),
             ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: config.cardTextFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          if (isRightAligned) ...[
            const SizedBox(width: 12),
             Transform.rotate(
                angle: 0.4,
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset(
                    "lib/assets/images/onboarding/salon_butterfly.png",
                    width: config.cardButterflySize,
                    height: config.cardButterflySize,
                  ),
                ),
             ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).moveX(begin: isRightAligned ? 50 : -50, end: 0);
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
            color: _kVibrantPink,
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

  Widget _buildOutlinedText(String text, {TextAlign textAlign = TextAlign.start, double fontSize = 46, double height = 0.9}) {
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

  Widget _buildSkipButton() {
    return Positioned(
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

  Widget _buildSalonOnboardingStep6() {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Main Content in a Column for responsiveness
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: _buildOutlinedText(
                    Languages.of(context)!.salonOnboarding6Title,
                    textAlign: TextAlign.center,
                    fontSize: 42, 
                  ),
                ).animate().moveY(begin: -50, end: 0, duration: 800.ms, curve: Curves.easeOut),
              ),

              const Spacer(flex: 4),

              // Butterfly & Text Box
              SizedBox(
                height: 200, 
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Text Box
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width, 
                        margin: const EdgeInsets.only(left: 80), 
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), 
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.0), 
                          border: Border.all(color: _kVibrantPink, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: RichText(
                          textAlign: TextAlign.center, 
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 20, 
                              color: Colors.black87,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(text: Languages.of(context)!.salonOnboarding6Desc.split("Pink Gossip")[0]),
                              TextSpan(
                                text: "Pink Gossip",
                                style: GoogleFonts.poppins(
                                  color: _kVibrantPink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: Languages.of(context)!.salonOnboarding6Desc.split("Pink Gossip")[1]),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Butterfly
                    Positioned(
                      left: -80, 
                      top: -60, 
                      child: Transform.rotate(
                        angle: -0.15, 
                        child: Image.asset(
                          "lib/assets/images/onboarding/salon_butterfly.png",
                          width: 300, 
                          height: 300,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms, delay: 200.ms).moveX(begin: 50, end: 0, curve: Curves.easeOut),
              ),

              const Spacer(flex: 1),

              // Bottom Section: Phone + QR Code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Phone Mockup
                    Expanded(
                      flex: 4,
                      child: Transform.translate(
                        offset: const Offset(-40, 50), 
                        child: Transform.scale(
                          scale: 1.30,
                          child: Image.asset(
                            "lib/assets/images/onboarding/phone_2.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).animate().moveY(begin: 200, end: 0, duration: 800.ms, delay: 400.ms, curve: Curves.easeOut),
                    ),

                    // QR Code Section
                    Expanded(
                      flex: 3,
                      child: Transform.translate(
                        offset: const Offset(0, -80), 
                        child: Transform.scale(
                          scale: 1.2,
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Image.asset(
                                  "lib/assets/images/onboarding/code_QR_2.png",
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40), // Space for button alignment
                          ],
                        ),
                      ),
                      ).animate().scale(duration: 600.ms, delay: 600.ms, curve: Curves.easeOutBack),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),

        // "LET'S BEGIN" Button (Bottom Right)
        Positioned(
          bottom: 30,
          right: 20,
          child: _build3DButton(
            text: Languages.of(context)!.letsBeginText,
            onPressed: _completeOnboarding,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        // Skip Button
        _buildSkipButton(),
      ],
    );
  }
}

// Responsive configuration helper class with linear interpolation
class _ResponsiveConfig {
  final Size screenSize;

  _ResponsiveConfig(this.screenSize);

  // Screen height breakpoints
  static const double minScreenHeight = 667;  // iPhone SE
  static const double maxScreenHeight = 926;  // iPhone 17 Pro Max
  static const double verySmallThreshold = 667;

  // Font size ranges
  static const double minTitleFontSize = 32;
  static const double maxTitleFontSize = 46;
  static const double minBodyFontSize = 13;
  static const double maxBodyFontSize = 18;
  static const double minCardTitleFontSize = 14;
  static const double maxCardTitleFontSize = 19;

  // Image size ranges
  static const double minQrCodeSize = 180;
  static const double maxQrCodeSize = 280;
  static const double minQrCodeScale = 1.0;
  static const double maxQrCodeScale = 1.2;
  static const double minButterflySize = 70;
  static const double maxButterflySize = 95;

  // Spacing ranges
  static const double minVerticalSpacing = 12;
  static const double maxVerticalSpacing = 24;
  static const double minCardPadding = 12;
  static const double maxCardPadding = 24;
  static const double minTopPadding = 60;
  static const double maxTopPadding = 80;  // Larger top padding on bigger screens
  static const double minBottomSpacing = 100;
  static const double maxBottomSpacing = 160;

  // Card insets ranges
  static const double minCardInsetsHorizontal = 12;
  static const double maxCardInsetsHorizontal = 28;
  static const double minCardInsetsVertical = 8;
  static const double maxCardInsetsVertical = 14;

  // Screen 4 specific - Title font size
  static const double minScreen4TitleFontSize = 28;
  static const double maxScreen4TitleFontSize = 40;

  // Screen 4 specific - Card spacing
  static const double minCardSpacing = 12;
  static const double maxCardSpacing = 16;

  // Screen 4 specific - Card text & butterfly
  static const double minCardTextFontSize = 14;
  static const double maxCardTextFontSize = 17;
  static const double minCardButterflySize = 80;
  static const double maxCardButterflySize = 100;

  // Screen 4 specific - Boom section
  static const double minBoomTitleFontSize = 15;
  static const double maxBoomTitleFontSize = 18;
  static const double minBoomDescFontSize = 12;
  static const double maxBoomDescFontSize = 14;
  static const double minBoomPadding = 12;
  static const double maxBoomPadding = 20;

  // Screen 5 specific - Title
  static const double minScreen5TitleFontSize = 26;
  static const double maxScreen5TitleFontSize = 36;
  static const double minScreen5TitleTop = 60;
  static const double maxScreen5TitleTop = 90;

  // Screen 5 specific - Phone mockup
  static const double minPhoneHeightRatio = 0.50;  // 50% of screen height
  static const double maxPhoneHeightRatio = 0.65;  // 65% of screen height
  static const double minPhoneBottomPadding = 30;
  static const double maxPhoneBottomPadding = 50;

  // Screen 5 specific - Message bubbles
  static const double minBubbleSpacing = 8;
  static const double maxBubbleSpacing = 12;
  static const double minBubblePaddingH = 16;
  static const double maxBubblePaddingH = 20;
  static const double minBubblePaddingV = 10;
  static const double maxBubblePaddingV = 12;
  static const double minBubbleTitleFontSize = 12;
  static const double maxBubbleTitleFontSize = 14;
  static const double minBubbleSubtitleFontSize = 10;
  static const double maxBubbleSubtitleFontSize = 12;
  static const double minBubblesBottom = 100;
  static const double maxBubblesBottom = 120;

  // Linear interpolation between min and max values based on screen height
  double _interpolate(double minHeight, double maxHeight, double minValue, double maxValue) {
    final height = screenSize.height;
    if (height <= minHeight) return minValue;
    if (height >= maxHeight) return maxValue;

    // Calculate ratio and interpolate
    final ratio = (height - minHeight) / (maxHeight - minHeight);
    return minValue + (maxValue - minValue) * ratio;
  }

  // Helper: Check if screen is very small (for special cases like scroll)
  bool get isVerySmall => screenSize.height < verySmallThreshold;

  // Font sizes - smoothly adapt from iPhone SE to Pro Max
  double get titleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minTitleFontSize, maxTitleFontSize);
  double get bodyFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBodyFontSize, maxBodyFontSize);
  double get cardTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minCardTitleFontSize, maxCardTitleFontSize);

  // Image sizes - smoothly adapt
  double get qrCodeSize => _interpolate(minScreenHeight, maxScreenHeight, minQrCodeSize, maxQrCodeSize);
  double get qrCodeScale => _interpolate(minScreenHeight, maxScreenHeight, minQrCodeScale, maxQrCodeScale);
  double get butterflySize => _interpolate(minScreenHeight, maxScreenHeight, minButterflySize, maxButterflySize);

  // Spacing - smoothly adapt
  double get verticalSpacing => _interpolate(minScreenHeight, maxScreenHeight, minVerticalSpacing, maxVerticalSpacing);
  double get cardPadding => _interpolate(minScreenHeight, maxScreenHeight, minCardPadding, maxCardPadding);
  double get topPadding => _interpolate(minScreenHeight, maxScreenHeight, minTopPadding, maxTopPadding);
  double get bottomSpacing => _interpolate(minScreenHeight, maxScreenHeight, minBottomSpacing, maxBottomSpacing);

  EdgeInsets get cardInsets {
    final horizontal = _interpolate(minScreenHeight, maxScreenHeight, minCardInsetsHorizontal, maxCardInsetsHorizontal);
    final vertical = _interpolate(minScreenHeight, maxScreenHeight, minCardInsetsVertical, maxCardInsetsVertical);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  // Screen 4 specific - Getters
  double get screen4TitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen4TitleFontSize, maxScreen4TitleFontSize);
  double get cardSpacing => _interpolate(minScreenHeight, maxScreenHeight, minCardSpacing, maxCardSpacing);
  double get cardTextFontSize => _interpolate(minScreenHeight, maxScreenHeight, minCardTextFontSize, maxCardTextFontSize);
  double get cardButterflySize => _interpolate(minScreenHeight, maxScreenHeight, minCardButterflySize, maxCardButterflySize);
  double get boomTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBoomTitleFontSize, maxBoomTitleFontSize);
  double get boomDescFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBoomDescFontSize, maxBoomDescFontSize);
  double get boomPadding => _interpolate(minScreenHeight, maxScreenHeight, minBoomPadding, maxBoomPadding);

  // Screen 5 specific - Getters
  double get screen5TitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minScreen5TitleFontSize, maxScreen5TitleFontSize);
  double get screen5TitleTop => _interpolate(minScreenHeight, maxScreenHeight, minScreen5TitleTop, maxScreen5TitleTop);
  double get phoneHeightRatio => _interpolate(minScreenHeight, maxScreenHeight, minPhoneHeightRatio, maxPhoneHeightRatio);
  double get phoneBottomPadding => _interpolate(minScreenHeight, maxScreenHeight, minPhoneBottomPadding, maxPhoneBottomPadding);
  double get bubbleSpacing => _interpolate(minScreenHeight, maxScreenHeight, minBubbleSpacing, maxBubbleSpacing);
  double get bubbleTitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBubbleTitleFontSize, maxBubbleTitleFontSize);
  double get bubbleSubtitleFontSize => _interpolate(minScreenHeight, maxScreenHeight, minBubbleSubtitleFontSize, maxBubbleSubtitleFontSize);
  double get bubblesBottom => _interpolate(minScreenHeight, maxScreenHeight, minBubblesBottom, maxBubblesBottom);

  EdgeInsets get bubblePadding {
    final h = _interpolate(minScreenHeight, maxScreenHeight, minBubblePaddingH, maxBubblePaddingH);
    final v = _interpolate(minScreenHeight, maxScreenHeight, minBubblePaddingV, maxBubblePaddingV);
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }
}

