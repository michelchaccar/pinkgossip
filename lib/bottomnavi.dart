// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/main.dart';
import 'package:pinkGossip/models/removestorycronmodel.dart';
import 'package:pinkGossip/screens/AddPost/PostUploadOpt.dart';
import 'package:pinkGossip/screens/AddPost/addpostoptionscreen.dart';
import 'package:pinkGossip/utils/DeepLinkHandler.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/viewModels/removestorycroneviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/screens/HomeScreens/homescreen.dart';
import 'package:pinkGossip/screens/Mackeups/salonslist.dart';
import 'package:pinkGossip/screens/Message/message.dart';
import 'package:pinkGossip/screens/Profile/profile.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:provider/provider.dart';
import 'package:pinkGossip/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class BottomNavBar extends StatefulWidget {
  int? index;
  bool? isIntroScreen;
  BottomNavBar({Key? key, this.index, this.isIntroScreen}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late DeepLinkHandler _deepLinkHandler;

  int pageIndex = 0;
  List<TargetFocus> targets = [];
  GlobalKey homeKey = GlobalKey();
  GlobalKey makeupKey = GlobalKey();
  GlobalKey postKey = GlobalKey();
  GlobalKey messageKey = GlobalKey();
  GlobalKey profileKey = GlobalKey();
  GlobalKey searchKey = GlobalKey();
  GlobalKey notificationKey = GlobalKey();
  GlobalKey addstoryKey = GlobalKey();
  late List<Widget> pageList;
  late TutorialCoachMark tutorialCoachMark;

  void _onItemTapped(int index) {
    getRemoveStoryCron();
    setState(() {
      pageIndex = index;
    });
  }

  Future<void> _initializeDeepLinks() async {
    await _deepLinkHandler.initDeepLinks();
  }

  @override
  void initState() {
    super.initState();
    _deepLinkHandler = DeepLinkHandler(navigatorKey: navigatorKey);
    _initializeDeepLinks();
    _createTargets();
    checkOnboarding();
    pageList = <Widget>[
      HomeScreen(
        searchKey: searchKey,
        notificationKey: notificationKey,
        addstoryKey: addstoryKey,
      ),
      const MackeupsScreen(),
      const PostUploadOptPage(),
      // const AddPostOptionScreen(),
      const MessageScreen(),
      const ProfileScreen(),
    ];
    if (widget.index != null) {
      pageIndex = widget.index!;
    }
    if (widget.isIntroScreen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        createTutorial();
        showTutorial();
      });
    }
  }

  void showTutorial() {
    Future.delayed(const Duration(seconds: 2), () {
      tutorialCoachMark.show(context: context);
    });
  }

  void checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid') ?? "";
    String userType = prefs.getString('userType') ?? "";
    
    // If we don't have a user ID, we can't track onboarding per user, so skip or handle gracefully.
    // Assuming logged in user always has ID.
    if (userId.isNotEmpty) {
      bool isOnboardingCompleted = prefs.getBool('onboarding_completed_$userId') ?? false;
      if (!isOnboardingCompleted) {
        // Add a slight delay to ensure the widget is built before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(
                userId: userId,
                userType: userType,
              ),
            ),
          );
        });
      }
    }
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.grey,
      textSkip: Languages.of(context)!.skipText,
      hideSkip: true,
      paddingFocus: 1,
      initialFocus: 0,
      opacityShadow: 0.5,
      useSafeArea: true,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        tutorialCoachMark.skip();
      },
      onSkip: () {
        return true;
      },
    );
  }

  _createTargets() {
    setState(() {
      targets.add(
        TargetFocus(
          keyTarget: searchKey,
          enableOverlayTab: false,
          shape: ShapeLightFocus.Circle,
          paddingFocus: 1,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.searchPostsText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.searchPoststutorialmsgText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
      targets.add(
        TargetFocus(
          keyTarget: notificationKey,
          enableOverlayTab: false,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.notificationsText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.notificationtutorialmsgText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
      targets.add(
        TargetFocus(
          keyTarget: addstoryKey,
          enableOverlayTab: false,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.shareStoryText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.shareStorytutorialmsgText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Home",
          keyTarget: homeKey,
          shape: ShapeLightFocus.Circle,
          radius: 0,
          paddingFocus: 0,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.homeText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.hometutorialmsgText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

      targets.add(
        TargetFocus(
          identify: "Makeup",
          keyTarget: makeupKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.storelocatorText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.storelocatortutorialmsgText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

      targets.add(
        TargetFocus(
          identify: "Add Post",
          keyTarget: postKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.sharePostsText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.sharePoststutorialmsgText,
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

      targets.add(
        TargetFocus(
          identify: "Messages",
          keyTarget: messageKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.messagesText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.messagestutorialmsgText,
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.next();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.nextText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

      targets.add(
        TargetFocus(
          identify: "Profile",
          keyTarget: profileKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: AppColors.kPinkColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Languages.of(context)!.profileText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            Languages.of(context)!.profiletutorialmsgText,
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            tutorialCoachMark.skip();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.kPinkColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.finishText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: pageList[pageIndex]),
      bottomNavigationBar: SizedBox(
        // height: 80,
        child: BottomNavigationBar(
          backgroundColor: AppColors.kWhiteColor,
          items: [
            BottomNavigationBarItem(
              // key: homeKey,
              icon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: homeKey, ImageUtils.homeLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              label: "",
              activeIcon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: homeKey, ImageUtils.homeselectLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: makeupKey, ImageUtils.makeupLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              label: "",
              activeIcon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      key: makeupKey,
                      ImageUtils.makeupselectLogo,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: postKey, ImageUtils.postLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              label: "",
              activeIcon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: postKey, ImageUtils.postselectLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(key: messageKey, ImageUtils.messgaeLogo),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              label: "",
              activeIcon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      key: messageKey,
                      ImageUtils.messgaselectLogo,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      key: profileKey,
                      "lib/assets/images/profile-icon@3x.png",
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              label: "",
              activeIcon: Column(
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      key: profileKey,
                      "lib/assets/images/profile-icon-filled@3x.png",
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: pageIndex,
          onTap: _onItemTapped,
          elevation: 5,
        ),
      ),
    );
  }

  getRemoveStoryCron() async {
    print("get getRemoveStoryCron function call");
    setState(() {});

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<RemoveStoryCroneViewModel>(
          context,
          listen: false,
        ).getRemoveStoryCron();
        if (Provider.of<RemoveStoryCroneViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<RemoveStoryCroneViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("Success");
            RemoveStoryCronModel model =
                Provider.of<RemoveStoryCroneViewModel>(
                      context,
                      listen: false,
                    ).removestorycroneresponse.response
                    as RemoveStoryCronModel;

            print("model.message ${(model.message)}");
          }
        }
      } else {
        setState(() {});
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }
}
