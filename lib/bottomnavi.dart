// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/main.dart';
import 'package:pinkGossip/models/removestorycronmodel.dart';
import 'package:pinkGossip/screens/AddPost/PostUploadOpt.dart';
import 'package:pinkGossip/screens/AddPost/addpostoptionscreen.dart';
import 'package:pinkGossip/services/tooltip_service.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pinkGossip/services/tooltip_service.dart';
import 'package:pinkGossip/screens/onboarding/onboarding_screen.dart';

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
  String _userId = "";
  final TooltipService _tooltipService = TooltipService();
  final Set<int> _tooltipsShownInSession = {};

  void _onItemTapped(int index) async {
    // Show contextual tooltip if not seen yet (only when not in intro mode)
    if (widget.isIntroScreen != true) {
      await _showContextualTooltip(index);
    }

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
    _loadUserIdSync();
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

  void _loadUserIdSync() {
    // Load userId synchronously to ensure it's available before any user interaction
    SharedPreferences.getInstance().then((prefs) {
      String userId = prefs.getString('userid') ?? "";
      if (mounted) {
        setState(() {
          _userId = userId;
        });
      }
    });
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
      bool isOnboardingCompleted =
          prefs.getBool('onboarding_completed_$userId') ?? false;
      if (!isOnboardingCompleted) {
        // Add a slight delay to ensure the widget is built before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      OnboardingScreen(userId: userId, userType: userType),
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
          enableOverlayTab: true,
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
                                  Languages.of(context)!.gotitText,
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
          enableOverlayTab: true,
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
                                  Languages.of(context)!.gotitText,
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
          enableOverlayTab: true,
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
                                  Languages.of(context)!.gotitText,
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
          enableOverlayTab: true,
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
                                  Languages.of(context)!.gotitText,
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
                                  Languages.of(context)!.gotitText,
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
                                  Languages.of(context)!.gotitText,
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
                                  Languages.of(context)!.gotitText,
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
                                  Languages.of(context)!.gotitText,
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

  TooltipType _mapIndexToTooltipType(int index) {
    switch (index) {
      case 0:
        return TooltipType.home;
      case 1:
        return TooltipType.storeLocator;
      case 2:
        return TooltipType.post;
      case 3:
        return TooltipType.message;
      case 4:
        return TooltipType.profile;
      default:
        return TooltipType.home;
    }
  }

  /// Get GlobalKey for a specific bottom nav index
  GlobalKey _getKeyForIndex(int index) {
    switch (index) {
      case 0:
        return homeKey;
      case 1:
        return makeupKey;
      case 2:
        return postKey;
      case 3:
        return messageKey;
      case 4:
        return profileKey;
      default:
        return homeKey;
    }
  }

  /// Show contextual tooltip for a specific bottom nav item
  Future<void> _showContextualTooltip(int navIndex) async {
    // 0. Don't show tooltip if userId is not loaded yet
    if (_userId.isEmpty) return;

    // 1. Check if already shown in this session
    if (_tooltipsShownInSession.contains(navIndex)) return;

    // 2. Map index to TooltipType
    TooltipType type = _mapIndexToTooltipType(navIndex);

    // 3. Check if user has already seen this tooltip
    bool hasSeenTooltip = await _tooltipService.hasSeenTooltip(_userId, type);
    if (hasSeenTooltip) return;

    // 4. Mark as shown in this session
    _tooltipsShownInSession.add(navIndex);

    // 5. Create and show the single tooltip
    await _createAndShowSingleTooltip(navIndex, type);
  }

  /// Create and show a single tooltip for a specific nav item
  Future<void> _createAndShowSingleTooltip(
    int navIndex,
    TooltipType type,
  ) async {
    if (!mounted) return;

    GlobalKey targetKey = _getKeyForIndex(navIndex);
    TargetFocus targetFocus = _createSingleTargetFocus(
      navIndex,
      targetKey,
      type,
    );

    TutorialCoachMark singleTooltip = TutorialCoachMark(
      targets: [targetFocus],
      colorShadow: Colors.grey,
      hideSkip: true,
      paddingFocus: navIndex == 0 ? 0 : 1,
      opacityShadow: 0.5,
      useSafeArea: true,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () async {
        // Mark as seen when tutorial completes normally
        await _tooltipService.markTooltipAsSeen(_userId, type);
      },
      onSkip: () {
        // Mark as seen when user clicks "Got it" (which calls skip)
        _tooltipService.markTooltipAsSeen(_userId, type);
        return true;
      },
    );

    // Wait a bit for the widget to be fully rendered
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      singleTooltip.show(context: context);
    }
  }

  /// Create a single TargetFocus for contextual tooltip
  TargetFocus _createSingleTargetFocus(
    int navIndex,
    GlobalKey targetKey,
    TooltipType type,
  ) {
    String title = "";
    String message = "";

    // Get the appropriate title and message based on nav index
    switch (navIndex) {
      case 0: // Home
        title = Languages.of(context)!.homeText;
        message = Languages.of(context)!.hometutorialmsgText;
        break;
      case 1: // Store Locator
        title = Languages.of(context)!.storelocatorText;
        message = Languages.of(context)!.storelocatortutorialmsgText;
        break;
      case 2: // Share Posts
        title = Languages.of(context)!.sharePostsText;
        message = Languages.of(context)!.sharePoststutorialmsgText;
        break;
      case 3: // Messages
        title = Languages.of(context)!.messagesText;
        message = Languages.of(context)!.messagestutorialmsgText;
        break;
      case 4: // Profile
        title = Languages.of(context)!.profileText;
        message = Languages.of(context)!.profiletutorialmsgText;
        break;
    }

    return TargetFocus(
      identify: "nav_$navIndex",
      keyTarget: targetKey,
      shape: ShapeLightFocus.Circle,
      radius: navIndex == 0 ? 0 : null,
      paddingFocus: navIndex == 0 ? 0 : null,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Column(
              crossAxisAlignment:
                  navIndex <= 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
              children: [
                Container(
                  width:
                      navIndex == 0 ? MediaQuery.of(context).size.width : null,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: AppColors.kPinkColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        message,
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
                        controller.skip();
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
                              Languages.of(context)!.gotitText,
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
    );
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
