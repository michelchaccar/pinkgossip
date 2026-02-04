import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:share_plus/share_plus.dart';

class ReferralShareSheet extends StatefulWidget {
  final String referralCode;
  final String referralLink;

  const ReferralShareSheet({
    Key? key,
    required this.referralCode,
    required this.referralLink,
  }) : super(key: key);

  @override
  State<ReferralShareSheet> createState() => _ReferralShareSheetState();
}

class _ReferralShareSheetState extends State<ReferralShareSheet> {
  bool _copied = false;

  String _buildShareMessage(Languages lang) {
    return lang.referralShareMessage
        .replaceAll('[CODE]', widget.referralCode)
        .replaceAll('[LINK]', widget.referralLink);
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.referralLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareVia(Languages lang) {
    final message = _buildShareMessage(lang);
    SharePlus.instance.share(ShareParams(text: message));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    final shareMessage = _buildShareMessage(lang);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.klightGreyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              lang.referralShareTitle,
              style: GoogleFonts.archivoBlack(
                fontSize: 22,
                color: AppColors.kBlackColor,
              ),
            ),
            const SizedBox(height: 20),

            // Referral link field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kBorderColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.referralLink,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.drktxtGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _copyLink,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kPinkColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.copy_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _copied
                                ? lang.referralCopiedText
                                : lang.referralCopyText,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share message preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.knotifiBGColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.kPinkColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                shareMessage,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.drktxtGrey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Share button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _shareVia(lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPinkColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      lang.referralCTA,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
