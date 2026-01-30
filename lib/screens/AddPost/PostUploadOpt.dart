import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/AddPost/SharePostView.dart';
import 'package:pinkGossip/screens/AddPost/ShareSaloonReview.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/pallete.dart';
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

    print("userid   ${userid}");
    print("userType   ${userType}");
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserPrefs();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar:
          showButtons == false
              ? AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: AppColors.kAppBArBGColor,
                automaticallyImplyLeading: false,
                elevation: 2.0,
                toolbarHeight: 0.1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Languages.of(context)!.PostReviewText,
                      style: Pallete.Quicksand16drkBlackBold,
                    ),
                    InkWell(
                      onTap: () async {},
                      child: Image.asset(
                        "lib/assets/images/wrong.png",
                        width: 22,
                        color: AppColors.kBlackColor,
                      ),
                    ),
                  ],
                ),
              )
              : AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: AppColors.kAppBArBGColor,
                automaticallyImplyLeading: false,
                elevation: 2.0,
                title: Row(
                  children: [
                    Text(
                      Languages.of(context)!.submitnewpostText,
                      style: Pallete.Quicksand16drkBlackBold,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CommonWidget().getSmallButton(Languages.of(context)!.sharepostText, () {
          setState(() {
            showButtons = false;
            openedViewIndex = 1;
          });
        }),
        const SizedBox(height: 50),
        CommonWidget().getSmallButton(
          Languages.of(context)!.sharestoryText,
          () {
            setState(() {
              showButtons = false;
              openedViewIndex = 2;
            });
          },
        ),
        const SizedBox(height: 50),
        userType == "1"
            ? CommonWidget().getSmallButton(
              Languages.of(context)!.sharesalonreviewText,
              () {
                setState(() {
                  showButtons = false;
                  openedViewIndex = 3;
                });
              },
            )
            : SizedBox(),
        userType == "2"
            ? CommonWidget().getSmallButton(
              Languages.of(context)!.postARewardText,
              () {
                setState(() {
                  showButtons = false;
                  openedViewIndex = 4;
                });
              },
            )
            : SizedBox(),
      ],
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
