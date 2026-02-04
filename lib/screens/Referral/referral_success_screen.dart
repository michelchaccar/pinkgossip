import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Referral/referral_screen.dart';
import 'package:pinkGossip/screens/onboarding/components/onboarding_button.dart';
import 'package:pinkGossip/utils/color_utils.dart';

class ReferralSuccessScreen extends StatelessWidget {
  final String friendName;

  const ReferralSuccessScreen({
    Key? key,
    required this.friendName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    final subtitle = lang.referralSuccessSubtitle.replaceAll('[NAME]', friendName);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Celebration icon with animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.kPinkColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: AppColors.kPinkColor,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(duration: 1000.ms, color: AppColors.onboardingBubblegumPink),

              const SizedBox(height: 32),

              // BOOM! title
              Text(
                lang.referralSuccessTitle,
                style: GoogleFonts.archivoBlack(
                  fontSize: 40,
                  color: AppColors.kPinkColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kBlackColor,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 12),

              // Points earned
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.kAppBArBGColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lang.referralSuccessPoints,
                  style: GoogleFonts.archivoBlack(
                    fontSize: 18,
                    color: AppColors.kPinkColor,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

              const SizedBox(height: 20),

              // Encouragement
              Text(
                lang.referralSuccessEncouragement,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.drktxtGrey,
                ),
              ).animate().fadeIn(delay: 900.ms),

              const Spacer(flex: 2),

              // CTA 1 - Invite More
              OnboardingButton(
                text: lang.referralInviteMore,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferralScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // CTA 2 - See My Points
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  lang.referralSeePoints,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kPinkColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
