import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileShareWidget extends StatefulWidget {
  final String qrCodeDataString;
  ProfileShareWidget({required this.qrCodeDataString});

  @override
  State<ProfileShareWidget> createState() => _ProfileShareWidgetState();
}

class _ProfileShareWidgetState extends State<ProfileShareWidget> {
  @override
  Widget build(BuildContext context) {
    // The URL that will be encoded in the QR code
    Size kSize = MediaQuery.of(context).size;
    // final String profileUrl = '${API.baseUrl}/profile/${widget.userId}';

    return RepaintBoundary(
      child: Container(
        alignment: Alignment.topCenter,
        // height: kSize.height / 2,
        width: kSize.width,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12.0)],
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
              child: QrImageView(
                // foregroundColor: AppColors.kPinkColor,
                data: widget.qrCodeDataString,
                version: QrVersions.auto,
              ),
            ),

            // Container(
            //   height: 80,
            //   alignment: Alignment.topCenter,
            //   child: Image.asset("lib/assets/images/logo@3x.png"),
            // ),
            Text(
              Languages.of(context)!.scan_to_view_profile,
              style: Pallete.Quicksand16drkBlackbold,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SelectableText(
                widget.qrCodeDataString,
                style: Pallete.Quicksand15blackwe600,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     QrImageView(
    //       data: profileUrl,
    //       version: QrVersions.auto,
    //       size: 200.0,
    //       backgroundColor: Colors.white,
    //     ),
    //     SizedBox(height: 16),
    //     Text(
    //       Languages.of(context)!.scan_to_view_profile,
    //     ),
    //     SizedBox(height: 8),
    //     SelectableText(profileUrl),
    //   ],
    // );
  }
}
