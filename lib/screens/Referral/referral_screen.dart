// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Referral/referral_share_sheet.dart';
import 'package:pinkGossip/screens/onboarding/components/onboarding_button.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/viewModels/referralviewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String userId = "";
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userid') ?? "";
    if (userId.isNotEmpty) {
      final vm = Provider.of<ReferralViewModel>(context, listen: false);
      await vm.fetchReferralCode(userId);
      await vm.fetchReferralStats(userId);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _showShareSheet() {
    final vm = Provider.of<ReferralViewModel>(context, listen: false);
    final code = vm.referralCodeModel?.referralCode ?? "";
    final link = vm.referralCodeModel?.referralLink ?? "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReferralShareSheet(
        referralCode: code,
        referralLink: link,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ReferralViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section A - Hero Header
                    _buildHeroHeader(context),

                    // Section B - Title + Code
                    _buildTitleAndCode(lang, vm),

                    const SizedBox(height: 24),

                    // Section C - What YOU get
                    _buildRewardCard(
                      title: lang.referralYouGetTitle,
                      value: lang.referralYouGetValue,
                      description: lang.referralYouGetDesc,
                      icon: Icons.card_giftcard,
                      backgroundColor: AppColors.kAppBArBGColor,
                    ),

                    const SizedBox(height: 12),

                    // Section D - What YOUR FRIEND gets
                    _buildRewardCard(
                      title: lang.referralFriendGetsTitle,
                      value: lang.referralFriendGetsValue,
                      description: lang.referralFriendGetsDesc,
                      icon: Icons.star_rounded,
                      backgroundColor: AppColors.knotifiBGColor,
                    ),

                    const SizedBox(height: 32),

                    // Section E - How it works
                    _buildHowItWorks(lang),

                    const SizedBox(height: 24),

                    // Section F - FAQ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Open FAQ
                        },
                        child: Text(
                          lang.referralFAQ,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kPinkColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.kPinkColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Section G - Fixed CTA button at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OnboardingButton(
                          text: lang.referralCTA,
                          onPressed: _showShareSheet,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kPinkColor,
            AppColors.onboardingBubblegumPink,
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Placeholder for hero illustration
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.favorite,
                    size: 40,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndCode(Languages lang, ReferralViewModel vm) {
    final code = vm.referralCodeModel?.referralCode ?? "...";

    return Container(
      color: AppColors.knotifiBGColor,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.referralTitle,
            style: GoogleFonts.archivoBlack(
              fontSize: 26,
              color: AppColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.referralSubtitle,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.drktxtGrey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang.referralIntro,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 20),
          // Referral code pill
          Text(
            lang.referralCodeLabel,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.drktxtGrey,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _copyCode(code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.kPinkColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.archivoBlack(
                      fontSize: 18,
                      color: AppColors.kPinkColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _copied ? Icons.check : Icons.copy_rounded,
                    color: AppColors.kPinkColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _copied ? lang.referralCopiedText : lang.referralCopyText,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kPinkColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.kPinkColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.kPinkColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.drktxtGrey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.archivoBlack(
                      fontSize: 28,
                      color: AppColors.kPinkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.drktxtGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(Languages lang) {
    final steps = [
      lang.referralStep1,
      lang.referralStep2,
      lang.referralStep3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.referralHowItWorks,
            style: GoogleFonts.archivoBlack(
              fontSize: 18,
              color: AppColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.kPinkColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.archivoBlack(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        steps[index],
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kBlackColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
