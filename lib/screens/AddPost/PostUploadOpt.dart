import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/AddPost/SharePostView.dart';
import 'package:pinkGossip/screens/AddPost/ShareSaloonReview.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostUploadOptPage extends StatefulWidget {
  const PostUploadOptPage({super.key});

  @override
  State<PostUploadOptPage> createState() => _PostUploadOptPageState();
}

class _PostUploadOptPageState extends State<PostUploadOptPage> {
  bool showButtons = true;
  int openedViewIndex = -1;

  SharedPreferences? prefs;
  String userid = "";
  String userType = "";

  getuserPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid') ?? "";
    userType = prefs!.getString('userType') ?? "apple";
    int? step = prefs!.getInt("step");
   // print("ALL PREF KEYS => ${prefs!.getKeys()}");
    if (step != null) {
      //print("step   ${step}");
      // 🔥 OPEN SALON REVIEW INSIDE SAME PAGE
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showButtons = false;
          openedViewIndex = 3; // SharesaloonreviewPage
        });
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("hii");
    getuserPrefs();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar:
          showButtons == false
              ? AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: AppColors.bgPrimary,
                automaticallyImplyLeading: false,
                elevation: 0,
                toolbarHeight: 0.1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Languages.of(context)!.PostReviewText,
                      style: AppTypography.heading3,
                    ),
                    InkWell(
                      onTap: () async {},
                      child: const Icon(
                        PhosphorIconsRegular.x,
                        size: 22,
                        color: AppColors.actionPrimary,
                      ),
                    ),
                  ],
                ),
              )
              : AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: AppColors.bgPrimary,
                automaticallyImplyLeading: false,
                elevation: 0,
                title: Row(
                  children: [
                    Text(
                      Languages.of(context)!.submitnewpostText,
                      style: AppTypography.heading3,
                    ),
                  ],
                ),
              ),
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: showButtons ? getButtons() : getOtherViews(),
      ),
    );
  }

  getButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildOptionCard(
            icon: PhosphorIconsRegular.image,
            title: Languages.of(context)!.sharepostText,
            subtitle: Languages.of(context)!.sharepostdescText,
            onTap: () {
              setState(() {
                showButtons = false;
                openedViewIndex = 1;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: PhosphorIconsRegular.clockCounterClockwise,
            title: Languages.of(context)!.sharestoryText,
            subtitle: Languages.of(context)!.sharestorydescText,
            onTap: () {
              setState(() {
                showButtons = false;
                openedViewIndex = 2;
              });
            },
          ),
          if (userType == "1") ...[
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: PhosphorIconsRegular.star,
              title: Languages.of(context)!.sharesalonreviewText,
              subtitle: Languages.of(context)!.sharesalonreviewdescText,
              onTap: () {
                setState(() {
                  showButtons = false;
                  openedViewIndex = 3;
                });
              },
            ),
          ],
          if (userType == "2") ...[
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: PhosphorIconsRegular.gift,
              title: Languages.of(context)!.postARewardText,
              subtitle: Languages.of(context)!.postARewarddescText,
              onTap: () {
                setState(() {
                  showButtons = false;
                  openedViewIndex = 4;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.actionPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  getOtherViews() {
    switch (openedViewIndex) {
      case 1:
        return SharepostviewPage(type: "NormalPost");

      case 2:
        return AddStory(type: "Post");

      case 3:
        return const SharesaloonreviewPage();
      case 4:
        return SharepostviewPage(type: "RewardPost");
      default:
    }
  }
}
