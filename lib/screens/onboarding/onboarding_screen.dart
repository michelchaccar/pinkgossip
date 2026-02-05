import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// Extracted components
import 'package:pinkGossip/screens/onboarding/components/onboarding_button.dart';
import 'package:pinkGossip/screens/onboarding/components/skip_button.dart';
import 'package:pinkGossip/screens/onboarding/components/outlined_text.dart';
import 'package:pinkGossip/screens/onboarding/components/message_bubble.dart';
import 'package:pinkGossip/screens/onboarding/components/step_card.dart';
import 'package:pinkGossip/screens/onboarding/components/butterfly_flight.dart';
import 'package:pinkGossip/screens/onboarding/config/responsive_config.dart';

class OnboardingScreen extends StatefulWidget {
  final String
  userType; // "1" for User, "2" for Salon (Consistent with LoginModel logic)
  final String userId;

  const OnboardingScreen({
    Key? key,
    required this.userType,
    required this.userId,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _butterflyController;
  late AnimationController _cycleController;

  // Consistent Colors
  static const Color _kVibrantPink = Color(0xFFFF1493); // DeepPink

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
    // userType "1" = User (Gossiper), userType "2" = Salon
    if (widget.userType == "2") {
      return _buildSalonOnboarding();
    } else {
      return _buildUserOnboarding();
    }
  }

  Widget _buildSalonOnboarding() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to enforce button navigation
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

  Widget _buildSalonOnboardingStep1() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
          ).animate().moveY(
            begin: 600,
            end: 0,
            duration: 1200.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Title (Top-to-bottom animation)
        Positioned(
          top: config.screen1TitleTop,
          right: 20,
          left: 20,
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.welcomeOnText,
                        ),
                      ),
                      const SizedBox(height: 0),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.pinkGossipText,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .moveY(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Skip Button (Fade-in)
        SkipButton(onPressed: _cancelOnboarding),

        // Description Card (Right-to-left animation)
        Positioned(
          right: 20,
          top: MediaQuery.of(context).size.height * 0.52,
          child:
              Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Card Content
                      Container(
                        width: config.screen1CardWidth,
                        padding: EdgeInsets.all(config.screen1CardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.archivoBlack(
                                  fontSize: config.screen1CardTextSize,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        Languages.of(
                                          context,
                                        )!.salonOnboardingDescPart1,
                                  ),
                                  TextSpan(
                                    text:
                                        Languages.of(
                                          context,
                                        )!.salonOnboardingDescPart2,
                                    style: GoogleFonts.archivoBlack(
                                      color: _kVibrantPink,
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
                        top: -config.screen1ButterflyOffset,
                        left: -config.screen1ButterflyOffset,
                        child: Image.asset(
                              "lib/assets/images/onboarding/salon_butterfly.png",
                              width: config.screen1ButterflySize,
                              height: config.screen1ButterflySize,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .moveY(
                              begin: 0,
                              end: -15,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .moveY(
                              begin: -15,
                              end: 0,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .animate()
                            .moveX(
                              begin: -config.screen1ButterflyOffset,
                              end: 0,
                              duration: 1500.ms,
                              delay: 1200.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 500.ms, delay: 1200.ms),
                      ),
                    ],
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 800.ms,
                    delay: 1000.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Let's Start Button (Bottom-to-top animation)
        Positioned(
              bottom: config.screen1ButtonBottom,
              right: 20,
              child: OnboardingButton(
                text: Languages.of(context)!.letsStartText,
                onPressed: _nextPage,
              ),
            )
            .animate()
            .moveY(
              begin: 100,
              end: 0,
              duration: 300.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(),
      ],
    );
  }

  Widget _buildSalonOnboardingStep2() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
                  padding: EdgeInsets.only(
                    bottom: config.screen2PhoneBottomPadding,
                  ),
                  child: Image.asset(
                    Localizations.localeOf(context).languageCode == 'en'
                        ? "lib/assets/images/onboarding/salon_phone_mockup_en.png"
                        : "lib/assets/images/onboarding/salon_phone_mockup_fr.png",
                    fit: BoxFit.contain,
                    height:
                        MediaQuery.of(context).size.height *
                        config.screen2PhoneHeightRatio,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .moveY(
                begin: 50,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOut,
              ),
        ),

        // Butterfly Flight Animation
        Positioned.fill(
          child: ButterflyFlight(
            butterflyController: _butterflyController,
            cycleController: _cycleController,
          ),
        ),

        // Title (Top)
        Positioned(
          top: config.screen2TitleTop,
          left: 0,
          right: 0,
          child: Center(
            child: OutlinedText(
              Languages.of(context)!.whatIsPinkGossipText,
              textAlign: TextAlign.center,
            ),
          ).animate().moveY(
            begin: -50,
            end: 0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Description Card (Bottom)
        Positioned(
          bottom: config.screen2CardBottom,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(config.screen2CardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
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
                  fontSize: config.screen2CardTextSize,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: Languages.of(context)!.salonOnboarding2Title.trim(),
                  ),
                  _buildBulletPoint(
                    Languages.of(context)!.salonOnboarding2DescPart1,
                  ),
                  _buildBulletPoint(
                    Languages.of(context)!.salonOnboarding2DescPart2,
                  ),
                  _buildBulletPoint(
                    Languages.of(context)!.salonOnboarding2DescPart3,
                  ),
                ],
              ),
            ),
          ).animate().moveY(
            begin: 200,
            end: 0,
            duration: 800.ms,
            delay: 200.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Continue Button (Bottom Right)
        Positioned(
          bottom: config.screen2ButtonBottom,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.continueText.toUpperCase(),
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        // Skip Button
        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildSalonOnboardingStep3() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
            physics:
                config.isVerySmall
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: config.screen3TopPadding),
                _buildStep3Title(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3TopCard(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3QRCode(config),
                SizedBox(height: config.verticalSpacing),
                _buildStep3Description(config),
                SizedBox(
                  height: config.bottomSpacing,
                ), // Adaptive space for button
              ],
            ),
          ),
        ),

        // Layer 3: Fixed UI elements (unchanged)
        Positioned(
          bottom: 30,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.nextStepsText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  // Helper widgets for Screen 3
  Widget _buildStep3Title(OnboardingResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: config.screen3TitlePaddingV),
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
        child: OutlinedText(
          Languages.of(context)!.salonOnboarding3Title,
          textAlign: TextAlign.center,
          fontSize: config.titleFontSize,
          height:
              1.0, // Compact line height to reduce vertical spacing on 2-line wrap
        ),
      ),
    ).animate().moveY(
      begin: -50,
      end: 0,
      duration: 800.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildStep3TopCard(OnboardingResponsiveConfig config) {
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
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .moveX(begin: -50, end: 0);
  }

  Widget _buildStep3QRCode(OnboardingResponsiveConfig config) {
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
              scale: OnboardingResponsiveConfig.screen3QrCodeScale,
              child: Image.asset(
                "lib/assets/images/onboarding/code_QR.png",
                width: config.screen3QrCodeSize,
                height: config.screen3QrCodeSize,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      duration: 600.ms,
      delay: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildStep3Description(OnboardingResponsiveConfig config) {
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
                style: GoogleFonts.archivoBlack(color: const Color(0xFF222222)),
              ),
            ],
          ),
        ),
      ),
    ).animate().moveY(
      begin: 100,
      end: 0,
      duration: 600.ms,
      delay: 600.ms,
      curve: Curves.easeOut,
    );
  }

  // Helper widgets for Screen 4
  Widget _buildStep4Title(OnboardingResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: OutlinedText(
          Languages.of(context)!.salonOnboarding4Title,
          textAlign: TextAlign.center,
          fontSize: config.screen4TitleFontSize,
          height: 1.1,
        ),
      ),
    ).animate().moveY(
      begin: -50,
      end: 0,
      duration: 800.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildStep4Cards(OnboardingResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          StepCard(
            text: Languages.of(context)!.salonOnboarding4Card1,
            delay: 200,
            config: config,
          ),
          SizedBox(height: config.screen4CardSpacing),
          StepCard(
            text: Languages.of(context)!.salonOnboarding4Card2,
            delay: 400,
            config: config,
          ),
          SizedBox(height: config.screen4CardSpacing),
          StepCard(
            text: Languages.of(context)!.salonOnboarding4Card3,
            delay: 600,
            isRightAligned: true,
            config: config,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4BoomSection(OnboardingResponsiveConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.screen4BoomPadding,
          vertical: config.screen4BoomPadding * 0.8,
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
                  fontSize: config.screen4BoomTitleFontSize,
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
                    text: Languages.of(
                      context,
                    )!.salonOnboarding4BottomTitle.replaceAll("Boom — ", ""),
                  ),
                ],
              ),
            ),
            SizedBox(height: config.screen4BoomTitleSpacing),
            Text(
              Languages.of(context)!.salonOnboarding4BottomDesc,
              style: GoogleFonts.archivoBlack(
                fontSize: config.screen4BoomDescFontSize,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ).animate().moveY(
      begin: 100,
      end: 0,
      duration: 600.ms,
      delay: 800.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildSalonOnboardingStep4() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
            physics:
                config.isVerySmall
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
          child: OnboardingButton(
            text: Languages.of(context)!.whyChooseUsText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),

        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildSalonOnboardingStep5() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
                  padding: EdgeInsets.only(
                    bottom: config.screen5PhoneBottomPadding,
                  ),
                  child: Image.asset(
                    "lib/assets/images/onboarding/phone.png",
                    fit: BoxFit.contain,
                    height:
                        MediaQuery.of(context).size.height *
                        config.screen5PhoneHeightRatio,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .moveY(
                begin: 50,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOut,
              ),
        ),

        // Layer 3: Title (Top, responsive)
        Positioned(
          top: config.screen5TitleTop,
          left: 0,
          right: 0,
          child: Center(
            child: OutlinedText(
              Languages.of(context)!.salonOnboarding5Title,
              textAlign: TextAlign.center,
              fontSize: config.screen5TitleFontSize,
              height: 1.2,
            ),
          ).animate().moveY(
            begin: -50,
            end: 0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Layer 4: Message Bubbles (Bottom, responsive)
        Positioned(
          bottom: config.screen5BubblesBottom,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.salonOnboarding5Bubble1.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.salonOnboarding5Bubble1.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.salonOnboarding5Bubble1.split('\n')[1]
                        : "",
                color: const Color(0xFFFFE5F5),
                delay: 200,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.salonOnboarding5Bubble2.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.salonOnboarding5Bubble2.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.salonOnboarding5Bubble2.split('\n')[1]
                        : "",
                color: const Color(0xFFFF69B4),
                textColor: Colors.white,
                delay: 400,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.salonOnboarding5Bubble3.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.salonOnboarding5Bubble3.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.salonOnboarding5Bubble3.split('\n')[1]
                        : "",
                color: const Color(0xFFFFE5F5),
                delay: 600,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.salonOnboarding5Bubble4.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.salonOnboarding5Bubble4.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.salonOnboarding5Bubble4.split('\n')[1]
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
          child: OnboardingButton(
            text: Languages.of(context)!.areYouReadyText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

        SkipButton(onPressed: _cancelOnboarding),
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
          style: TextStyle(color: _kVibrantPink, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: secondPart),
      ],
    );
  }

  Widget _buildUserOnboarding() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildGossiperOnboardingStep1(),
          _buildGossiperOnboardingStep2(),
          _buildGossiperOnboardingStep3(),
          _buildGossiperOnboardingStep4(),
          _buildGossiperOnboardingStep5(),
          _buildGossiperOnboardingStep6(),
          _buildGossiperOnboardingStep7(),
        ],
      ),
    );
  }

  Widget _buildGossiperOnboardingStep1() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
              "lib/assets/images/onboarding/gossiper/gossiper_model.png",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
            ),
          ).animate().moveY(
            begin: 600,
            end: 0,
            duration: 1200.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Title (Top-to-bottom animation)
        Positioned(
          top: config.screen1TitleTop,
          right: 20,
          left: 20,
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.welcomeOnText,
                        ),
                      ),
                      const SizedBox(height: 0),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.pinkGossipText,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .moveY(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Skip Button
        SkipButton(onPressed: _cancelOnboarding),

        // Description Card (Right-to-left animation)
        Positioned(
          right: 20,
          top:
              MediaQuery.of(context).size.height * config.gossiper1CardTopRatio,
          child:
              Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Card Content
                      Container(
                        width: config.screen1CardWidth,
                        padding: EdgeInsets.all(config.screen1CardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.archivoBlack(
                                  fontSize: config.screen1CardTextSize,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        Languages.of(
                                          context,
                                        )!.gossiperOnboardingDescPart1,
                                  ),
                                  TextSpan(
                                    text:
                                        Languages.of(
                                          context,
                                        )!.gossiperOnboardingDescPart2,
                                    style: GoogleFonts.archivoBlack(
                                      color: _kVibrantPink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Butterfly
                      Positioned(
                        top: -config.screen1ButterflyOffset,
                        left: -config.screen1ButterflyOffset,
                        child: Image.asset(
                              "lib/assets/images/onboarding/salon_butterfly.png",
                              width: config.screen1ButterflySize,
                              height: config.screen1ButterflySize,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .moveY(
                              begin: 0,
                              end: -15,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .moveY(
                              begin: -15,
                              end: 0,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .animate()
                            .moveX(
                              begin: -config.screen1ButterflyOffset,
                              end: 0,
                              duration: 1500.ms,
                              delay: 1200.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 500.ms, delay: 1200.ms),
                      ),
                    ],
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 800.ms,
                    delay: 1000.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Let's Start Button (Bottom-to-top animation)
        Positioned(
              bottom: config.screen1ButtonBottom,
              right: 20,
              child: OnboardingButton(
                text: Languages.of(context)!.letsStartText,
                onPressed: _nextPage,
              ),
            )
            .animate()
            .moveY(
              begin: 100,
              end: 0,
              duration: 300.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep2() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Model (positioned on the LEFT side, bottom-to-top animation)
        Positioned(
          left: -20,
          bottom: 0,
          child: Image.asset(
            "lib/assets/images/onboarding/gossiper/gossiper_model_2.png",
            fit: BoxFit.contain,
            height:
                MediaQuery.of(context).size.height *
                config.gossiper2ModelHeightRatio,
          ).animate().moveY(
            begin: 300,
            end: 0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Title (Centered)
        Positioned(
          top: config.screen1TitleTop,
          left: 20,
          right: 20,
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.gossiperOnboarding2Title,
                          textAlign: TextAlign.center,
                          height: 1.0,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .moveY(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Skip Button
        SkipButton(onPressed: _cancelOnboarding),

        // Card (Centered, below title)
        Positioned(
          left: 20,
          right: 20,
          top:
              MediaQuery.of(context).size.height * config.gossiper2CardTopRatio,
          child:
              Center(
                    child: Container(
                      padding: config.gossiper2CardPadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        Languages.of(context)!.gossiperOnboarding2Card,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivoBlack(
                          fontSize: config.screen1CardTextSize,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Message bubbles (RIGHT side)
        Positioned(
          right: 10,
          top:
              MediaQuery.of(context).size.height *
              config.gossiper2BubblesTopRatio,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bubble 1 - White
              Container(
                    width:
                        MediaQuery.of(context).size.width *
                        config.gossiper2BubbleWidthRatio,
                    padding: EdgeInsets.all(config.gossiper2BubblePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      Languages.of(context)!.gossiperOnboarding2Bubble1,
                      style: GoogleFonts.poppins(
                        fontSize: config.gossiper2BubbleFontSize,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),

              SizedBox(height: config.gossiper2BubbleSpacing),

              // Bubble 2 - White (same as bubble 1)
              Container(
                    width:
                        MediaQuery.of(context).size.width *
                        config.gossiper2BubbleWidthRatio,
                    padding: EdgeInsets.all(config.gossiper2BubblePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      Languages.of(context)!.gossiperOnboarding2Bubble2,
                      style: GoogleFonts.poppins(
                        fontSize: config.gossiper2BubbleFontSize,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 800.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
            ],
          ),
        ),

        // Let's Start Button (Bottom RIGHT - same as screen 1)
        Positioned(
              bottom: config.screen1ButtonBottom,
              right: 20,
              child: OnboardingButton(
                text: Languages.of(context)!.letsStartText,
                onPressed: _nextPage,
              ),
            )
            .animate()
            .moveY(
              begin: 100,
              end: 0,
              duration: 300.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep3() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Phone mockup (left side, nearly vertical)
        Positioned(
          left: config.gossiper3PhoneLeft,
          top:
              MediaQuery.of(context).size.height *
              config.gossiper3PhoneTopRatio,
          child:
              Transform.rotate(
                    angle: 0,
                    child: Image.asset(
                      "lib/assets/images/onboarding/gossiper/gossiper_phone_mockup.png",
                      fit: BoxFit.contain,
                      height:
                          MediaQuery.of(context).size.height *
                          config.gossiper3PhoneHeightRatio,
                    ),
                  )
                  .animate()
                  .moveX(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Butterfly flight animation
        Positioned.fill(
          child: ButterflyFlight(
            butterflyController: _butterflyController,
            cycleController: _cycleController,
          ),
        ),

        // Title (top center)
        Positioned(
          top: config.screen1TitleTop,
          left: 20,
          right: 20,
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          Languages.of(context)!.gossiperOnboarding3Title,
                          textAlign: TextAlign.center,
                          height: 1.0,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .moveY(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Skip Button
        SkipButton(onPressed: _cancelOnboarding),

        // Chat bubbles (right side, above model)
        Positioned(
          right: 30,
          top:
              MediaQuery.of(context).size.height *
              config.gossiper3BubblesTopRatio,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bubble 1 - White
              Container(
                    width:
                        MediaQuery.of(context).size.width *
                        config.gossiper3BubbleWidthRatio,
                    padding: EdgeInsets.all(config.gossiper3BubblePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      Languages.of(context)!.gossiperOnboarding3Bubble1,
                      style: GoogleFonts.poppins(
                        fontSize: config.gossiper3BubbleFontSize,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),

              SizedBox(height: config.gossiper3BubbleSpacing),

              // Bubble 2 - White (offset to the left)
              Transform.translate(
                    offset: const Offset(-20, 0),
                    child: Container(
                      width:
                          MediaQuery.of(context).size.width *
                          config.gossiper3BubbleWidthRatio,
                      padding: EdgeInsets.all(config.gossiper3BubblePadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        Languages.of(context)!.gossiperOnboarding3Bubble2,
                        style: GoogleFonts.poppins(
                          fontSize: config.gossiper3BubbleFontSize,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .moveX(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
            ],
          ),
        ),

        // Model (bottom right)
        Positioned(
          right: config.gossiper3ModelRight,
          bottom: config.gossiper3ModelBottom,
          child: Image.asset(
            "lib/assets/images/onboarding/gossiper/gossiper_model_3.png",
            fit: BoxFit.contain,
            height:
                MediaQuery.of(context).size.height *
                config.gossiper3ModelHeightRatio,
          ).animate().moveY(
            begin: 300,
            end: 0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Description card (bottom left)
        Positioned(
          left: 15,
          bottom:
              MediaQuery.of(context).size.height *
              config.gossiper3DescBottomRatio,
          child:
              Container(
                    width:
                        MediaQuery.of(context).size.width *
                        config.gossiper3DescWidthRatio,
                    padding: EdgeInsets.all(config.gossiper3DescPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: GoogleFonts.archivoBlack(
                          fontSize: config.gossiper3DescFontSize,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text:
                                Languages.of(
                                  context,
                                )!.gossiperOnboarding3DescPart1,
                          ),
                          TextSpan(
                            text:
                                Languages.of(
                                  context,
                                )!.gossiperOnboarding3DescPart2,
                            style: GoogleFonts.archivoBlack(
                              color: _kVibrantPink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .moveY(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 800.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Continue button (right aligned)
        Positioned(
              bottom: config.screen1ButtonBottom,
              right: 20,
              child: OnboardingButton(
                text: Languages.of(context)!.continueText.toUpperCase(),
                onPressed: _nextPage,
              ),
            )
            .animate()
            .moveY(
              begin: 100,
              end: 0,
              duration: 300.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep4() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Scrollable content
        SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Model (top)
                RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset(
                        "lib/assets/images/onboarding/gossiper/gossiper_model_4.png",
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.width,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .moveY(begin: -50, end: 0, curve: Curves.easeOut),

                // Title
                Transform.translate(
                  offset: Offset(0, config.gossiper4TitleOffset),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedText(
                      Languages.of(context)!.gossiperOnboarding4Title,
                      textAlign: TextAlign.center,
                      fontSize: config.gossiper4TitleFontSize,
                      height: 1.0,
                    ),
                  ),
                ).animate().moveY(
                  begin: -30,
                  end: 0,
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                ),

                // Cards content with negative offset to compensate for title transform
                Transform.translate(
                  offset: Offset(0, config.gossiper4CardsOffset),
                  child: Column(
                    children: [
                      // Feature Row 1 (butterfly left)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StepCard(
                          text: Languages.of(context)!.gossiperOnboarding4Row1,
                          delay: 300,
                          config: config,
                          isRightAligned: false,
                        ),
                      ),

                      SizedBox(height: config.gossiper4CardSpacing),

                      // Feature Row 2 (butterfly left)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StepCard(
                          text: Languages.of(context)!.gossiperOnboarding4Row2,
                          delay: 400,
                          config: config,
                          isRightAligned: false,
                        ),
                      ),

                      SizedBox(height: config.gossiper4CardSpacing),

                      // Feature Row 3 (butterfly right)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StepCard(
                          text: Languages.of(context)!.gossiperOnboarding4Row3,
                          delay: 500,
                          config: config,
                          isRightAligned: true,
                        ),
                      ),

                      SizedBox(height: config.gossiper4DescSpacingTop),

                      // Bottom description card
                      Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                config.gossiper4DescPadding,
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
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.archivoBlack(
                                    fontSize: config.gossiper4DescFontSize,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          Languages.of(
                                            context,
                                          )!.gossiperOnboarding4DescPart1,
                                      style: GoogleFonts.archivoBlack(
                                        color: _kVibrantPink,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          Languages.of(
                                            context,
                                          )!.gossiperOnboarding4DescPart2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .moveY(
                            begin: 50,
                            end: 0,
                            duration: 600.ms,
                            delay: 600.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for button
              ],
            ),
          ),
        ),

        // Button (aligned right like screen 1)
        Positioned(
          bottom: config.screen1ButtonBottom,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.gossiperOnboarding4Button,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        // Skip button
        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep5() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/onboarding/salon_bg.png",
            fit: BoxFit.cover,
          ),
        ),

        // Model (left side, anchored to bottom)
        Positioned(
          left: config.gossiper5ModelLeft,
          bottom: 0,
          child:
              Image.asset(
                    "lib/assets/images/onboarding/gossiper/gossiper_model_5.png",
                    fit: BoxFit.contain,
                    height:
                        MediaQuery.of(context).size.height *
                        config.gossiper5ModelHeightRatio,
                  )
                  .animate()
                  .moveX(
                    begin: -100,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
        ),

        // Content
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Title "How it works"
              Padding(
                    padding: EdgeInsets.only(
                      top: config.gossiper5TitleTopPadding,
                      right: 20,
                      left: 20,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: OutlinedText(
                        Languages.of(context)!.gossiperOnboarding5Title,
                        textAlign: TextAlign.center,
                        fontSize: config.gossiper5TitleFontSize,
                        height: 1.0,
                      ),
                    ),
                  )
                  .animate()
                  .moveY(
                    begin: -50,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),

              const SizedBox(height: 10),

              // Subtitle "SCAN & GOSSIP"
              Padding(
                padding: EdgeInsets.only(
                  right: 50,
                  top: config.gossiper5SubtitleTopPadding,
                ),
                child: OutlinedText(
                  Languages.of(context)!.gossiperOnboarding5Subtitle,
                  textAlign: TextAlign.right,
                  fontSize: config.gossiper5SubtitleFontSize,
                  height: 1.1,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              // QR Code
              Padding(
                padding: EdgeInsets.only(
                  left: config.gossiper5QrCodeLeftPadding,
                ),
                child: Image.asset(
                  "lib/assets/images/onboarding/gossiper/gossiper_qr_1.png",
                  width: config.gossiper5QrCodeSize,
                  height: config.gossiper5QrCodeSize,
                ),
              ).animate().scale(
                duration: 600.ms,
                delay: 400.ms,
                curve: Curves.easeOutBack,
              ),

              const Spacer(),

              // Description card
              Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: config.gossiper5DescBottomPadding,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(config.gossiper5DescPadding),
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
                            fontSize: config.gossiper5DescFontSize,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  Languages.of(
                                    context,
                                  )!.gossiperOnboarding5DescPart1,
                              style: GoogleFonts.archivoBlack(
                                color: _kVibrantPink,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text:
                                  Languages.of(
                                    context,
                                  )!.gossiperOnboarding5DescPart2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .moveY(
                    begin: 100,
                    end: 0,
                    duration: 600.ms,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
            ],
          ),
        ),

        // Button
        Positioned(
          bottom: config.gossiper5ButtonBottom,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.nextStepsText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        // Skip button
        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep6() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
                  padding: EdgeInsets.only(
                    bottom: config.screen5PhoneBottomPadding,
                  ),
                  child: Image.asset(
                    "lib/assets/images/onboarding/gossiper/gossiper_phone.png",
                    fit: BoxFit.contain,
                    height:
                        MediaQuery.of(context).size.height *
                        config.screen5PhoneHeightRatio,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .moveY(
                begin: 50,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOut,
              ),
        ),

        // Layer 3: Title (Top, responsive)
        Positioned(
          top: config.screen5TitleTop,
          left: 0,
          right: 0,
          child: Center(
            child: OutlinedText(
              Languages.of(context)!.gossiperOnboarding6Title,
              textAlign: TextAlign.center,
              fontSize: config.screen5TitleFontSize,
              height: 1.2,
            ),
          ).animate().moveY(
            begin: -50,
            end: 0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
        ),

        // Layer 4: Message Bubbles (Bottom, responsive)
        Positioned(
          bottom: config.screen5BubblesBottom,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.gossiperOnboarding6Bubble1.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.gossiperOnboarding6Bubble1.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.gossiperOnboarding6Bubble1.split('\n')[1]
                        : "",
                color: const Color(0xFFFFE5F5),
                delay: 200,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.gossiperOnboarding6Bubble2.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.gossiperOnboarding6Bubble2.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.gossiperOnboarding6Bubble2.split('\n')[1]
                        : "",
                color: const Color(0xFFFF69B4),
                textColor: Colors.white,
                delay: 400,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.gossiperOnboarding6Bubble3.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.gossiperOnboarding6Bubble3.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.gossiperOnboarding6Bubble3.split('\n')[1]
                        : "",
                color: const Color(0xFFFFE5F5),
                delay: 600,
                config: config,
              ),
              SizedBox(height: config.screen5BubbleSpacing),
              MessageBubble(
                title:
                    Languages.of(
                      context,
                    )!.gossiperOnboarding6Bubble4.split('\n')[0],
                subtitle:
                    Languages.of(
                              context,
                            )!.gossiperOnboarding6Bubble4.split('\n').length >
                            1
                        ? Languages.of(
                          context,
                        )!.gossiperOnboarding6Bubble4.split('\n')[1]
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
          child: OnboardingButton(
            text: Languages.of(context)!.areYouReadyText,
            onPressed: _nextPage,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildGossiperOnboardingStep7() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
            physics:
                config.isVerySmall
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: config.screen6TitleTop),

                // Title (responsive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: OutlinedText(
                      Languages.of(context)!.gossiperOnboarding7Title,
                      textAlign: TextAlign.center,
                      fontSize: config.screen6TitleFontSize,
                      height: 1.05,
                    ),
                  ),
                ).animate().moveY(
                  begin: -50,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),

                // Spacer dynamique
                SizedBox(height: config.screen6TitleToBoxSpacing),

                // Butterfly & Text Box (responsive height)
                SizedBox(
                  height: config.screen6ButterflyBoxHeight,
                  child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Text Box
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(left: 80),
                              padding: EdgeInsets.all(
                                config.screen6ButterflyBoxPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0),
                                border: Border.all(
                                  color: _kVibrantPink,
                                  width: 2,
                                ),
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
                                    fontSize:
                                        config.screen6ButterflyBoxTextSize,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          Languages.of(context)!
                                              .gossiperOnboarding7Desc
                                              .split("Gossiper")[0],
                                    ),
                                    TextSpan(
                                      text: "Gossiper",
                                      style: GoogleFonts.poppins(
                                        color: _kVibrantPink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          Languages.of(context)!
                                              .gossiperOnboarding7Desc
                                              .split("Gossiper")[1],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Butterfly (responsive size)
                          Positioned(
                            left: -80,
                            top: -60,
                            child: Transform.rotate(
                              angle: -0.15,
                              child: Image.asset(
                                "lib/assets/images/onboarding/salon_butterfly.png",
                                width: config.screen6ButterflyImageSize,
                                height: config.screen6ButterflyImageSize,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .moveX(begin: 50, end: 0, curve: Curves.easeOut),
                ),

                // Spacer dynamique
                SizedBox(height: config.verticalSpacing),

                // Bottom Section: Phone + QR Code (responsive scales)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Phone Mockup (responsive scale)
                      Expanded(
                        flex: 4,
                        child: Transform.translate(
                          offset: const Offset(-40, 50),
                          child: Transform.scale(
                            scale: config.screen6PhoneScale,
                            child: Image.asset(
                              "lib/assets/images/onboarding/phone_2.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate().moveY(
                          begin: 200,
                          end: 0,
                          duration: 800.ms,
                          delay: 400.ms,
                          curve: Curves.easeOut,
                        ),
                      ),

                      // QR Code Section (responsive scale and size)
                      Expanded(
                        flex: 3,
                        child: Transform.translate(
                          offset: const Offset(0, -80),
                          child: Transform.scale(
                            scale: config.screen6QrCodeScale,
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
                                      width: config.screen6QrCodeSize,
                                      height: config.screen6QrCodeSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          delay: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: config.screen6BottomSpacing),
                SizedBox(height: config.bottomSpacing),
              ],
            ),
          ),
        ),

        // Layer 3: Fixed UI elements
        Positioned(
          bottom: 30,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.letsBeginText,
            onPressed: _completeOnboarding,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }

  Widget _buildSalonOnboardingStep6() {
    final config = OnboardingResponsiveConfig(MediaQuery.of(context).size);

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
            physics:
                config.isVerySmall
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: config.screen6TitleTop),

                // Title (responsive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: OutlinedText(
                      Languages.of(context)!.salonOnboarding6Title,
                      textAlign: TextAlign.center,
                      fontSize: config.screen6TitleFontSize,
                      height: 1.05,
                    ),
                  ),
                ).animate().moveY(
                  begin: -50,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),

                // Spacer dynamique (au lieu de Spacer(flex: 4))
                SizedBox(height: config.screen6TitleToBoxSpacing),

                // Butterfly & Text Box (responsive height)
                SizedBox(
                  height: config.screen6ButterflyBoxHeight,
                  child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Text Box
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(left: 80),
                              padding: EdgeInsets.all(
                                config.screen6ButterflyBoxPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0),
                                border: Border.all(
                                  color: _kVibrantPink,
                                  width: 2,
                                ),
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
                                    fontSize:
                                        config.screen6ButterflyBoxTextSize,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          Languages.of(context)!
                                              .salonOnboarding6Desc
                                              .split("Pink Gossip")[0],
                                    ),
                                    TextSpan(
                                      text: "Pink Gossip",
                                      style: GoogleFonts.poppins(
                                        color: _kVibrantPink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          Languages.of(context)!
                                              .salonOnboarding6Desc
                                              .split("Pink Gossip")[1],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Butterfly (responsive size)
                          Positioned(
                            left: -80,
                            top: -60,
                            child: Transform.rotate(
                              angle: -0.15,
                              child: Image.asset(
                                "lib/assets/images/onboarding/salon_butterfly.png",
                                width: config.screen6ButterflyImageSize,
                                height: config.screen6ButterflyImageSize,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .moveX(begin: 50, end: 0, curve: Curves.easeOut),
                ),

                // Spacer dynamique (au lieu de Spacer(flex: 1))
                SizedBox(height: config.verticalSpacing),

                // Bottom Section: Phone + QR Code (responsive scales)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Phone Mockup (responsive scale)
                      Expanded(
                        flex: 4,
                        child: Transform.translate(
                          offset: const Offset(-40, 50),
                          child: Transform.scale(
                            scale: config.screen6PhoneScale,
                            child: Image.asset(
                              "lib/assets/images/onboarding/phone_2.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate().moveY(
                          begin: 200,
                          end: 0,
                          duration: 800.ms,
                          delay: 400.ms,
                          curve: Curves.easeOut,
                        ),
                      ),

                      // QR Code Section (responsive scale and size)
                      Expanded(
                        flex: 3,
                        child: Transform.translate(
                          offset: const Offset(0, -80),
                          child: Transform.scale(
                            scale: config.screen6QrCodeScale,
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
                                      width: config.screen6QrCodeSize,
                                      height: config.screen6QrCodeSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          delay: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: config.screen6BottomSpacing),
                SizedBox(height: config.bottomSpacing),
              ],
            ),
          ),
        ),

        // Layer 3: Fixed UI elements
        Positioned(
          bottom: 30,
          right: 20,
          child: OnboardingButton(
            text: Languages.of(context)!.letsBeginText,
            onPressed: _completeOnboarding,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

        SkipButton(onPressed: _cancelOnboarding),
      ],
    );
  }
}
