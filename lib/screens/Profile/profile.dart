// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_brace_in_string_interps, unused_field, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, prefer_interpolation_to_compose_strings, prefer_final_fields, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/deletepostmodel.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/screens/Auth/loginscreen.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/Mackeups/tagvideothumbnail.dart';
import 'package:pinkGossip/screens/Message/messagedetail.dart';
import 'package:pinkGossip/screens/Profile/beautybusinessmap.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/models/followingmodel.dart';
import 'package:pinkGossip/models/unfollwmodel.dart';
import 'package:pinkGossip/viewModels/followingviewmodel.dart';
import 'package:pinkGossip/viewModels/unfollwviewmodel.dart';
import 'package:pinkGossip/screens/Profile/blockedusers.dart';
import 'package:pinkGossip/screens/Profile/language.dart';
import 'package:pinkGossip/screens/Profile/myreward.dart';
import 'package:pinkGossip/screens/Profile/qrcode.dart';
import 'package:pinkGossip/screens/allfollowingorfollowers.dart';
import 'package:pinkGossip/screens/onboarding/onboarding_screen.dart';
import 'package:pinkGossip/screens/tagpostview.dart';
import 'package:pinkGossip/viewModels/blockuserviewmodel.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinkGossip/viewModels/postdeleteviewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/updateprofilephoto.dart';
import 'package:pinkGossip/screens/Profile/editprofile.dart';
import 'package:pinkGossip/screens/showpostimage.dart';
import 'package:pinkGossip/screens/showpostvideo.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:pinkGossip/components/pg_back_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinkGossip/viewModels/salondetailsviewmodel.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmdoel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pinkGossip/services/tooltip_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String? userType;
  final String pageType;
  const ProfileScreen({super.key, this.userId, this.userType, this.pageType = ''});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  ScrollController _scrollController = ScrollController();
  late List<VideoPlayerController> _videoPlayercontroller;
  late ScrollController _videogridviewController;

  List<Post> salonProfilePostArray = [];
  List<Post> salonRewardRedeemPostArray = [];
  List<Post> tempprofilePostAray = [];
  List<TagPost>? tagPostList;

  // List<String> showotherimg = [];
  List<Map> showotherimg = [];
  List<Post> otherpostData = [];
  List<String> videoList = [];

  List<SalonOpenDay> salonOpenDays = [];
  bool _showHours = false;

  UserProfile? salonProfileDetails;

  int totalPoints = 0;
  int postCountsReeview = 0;
  bool isLoading = false;
  File image = File("");
  String fileExtension = "";
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      print("IMAGE PATH = ${image.path}");
      ProfilePhotoUpdate(image.path);
    } on PlatformException catch (error) {
      print('Failed to pick image: $error');
    }
  }

  SharedPreferences? prefs;
  String userid = "";
  String userTyppe = "";
  String userName = "";
  String firebaseID = "";
  bool isOn = true;
  late bool isOwnProfile = widget.userId == null;
  String targetId = "";
  String targetType = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid') ?? "";
    firebaseID = prefs!.getString('FirebaseId') ?? "";
    userTyppe = prefs!.getString('userType') ?? "apple";

    isOwnProfile = (widget.userId == null || widget.userId == userid);
    targetId = widget.userId ?? userid;
    targetType = widget.userType ?? userTyppe;

    print("userid   ${userid}");
    print("userTyppe   ${userTyppe}");
    print("isOwnProfile   ${isOwnProfile}");
    print("targetId   ${targetId}");

    _tabController = TabController(length: 3, vsync: this);

    _tabController.animation!.addListener(_handleTabChange);
  }

  int offsett = 0;
  List<Stories> myStoryArray = [];

  @override
  void initState() {
    super.initState();

    getuserid();
    getProfileDetails();

    getStory();

    // Deep link dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageType == 'deepLink' && userTyppe == "1") {
        _showDeepLinkWelcomeDialog();
      }
    });

    _scrollController.addListener(_loadMoreData);
    for (int i = 0; i < videoList.length; i++) {
      _videoPlayercontroller[i] = VideoPlayerController.networkUrl(
        Uri.parse(videoList[i]),
      );
      _videoPlayercontroller[i].initialize();
    }
    _videogridviewController = ScrollController();
  }

  var totlepostcount = 0;

  void _loadMoreData() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print("totlepostcount =${totlepostcount}");
      if (offsett > totlepostcount) {
        print("iffff");
        return;
      } else {
        print("elssee");
        getProfileDetails();
      }
      setState(() {});
    }
  }

  int currentindex = 0;

  void _handleTabChange() {
    int roundedValue = _tabController.animation!.value.round();

    if (roundedValue != currentindex) {
      setState(() {
        currentindex = roundedValue;
      });
    }

    if (Platform.isIOS) {
      if (roundedValue == 1) {
        Future.delayed(const Duration(seconds: 5), () {
          if (_videogridviewController.hasClients) {
            _videogridviewController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceIn,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoPlayercontroller) {
      controller.dispose();
    }
    _tabController.dispose();
    _scrollController.dispose();
    _videogridviewController.dispose();
    super.dispose();
  }

  String formatTime(String time) {
    final DateFormat inputFormat = DateFormat("HH:mm:ss");
    final DateTime parsedTime = inputFormat.parse(time);
    final DateFormat outputFormat = DateFormat("hh:mm");
    return outputFormat.format(parsedTime);
  }

  List<StoryUserDetails>? getDetailsStories;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildGridItem({
    required String imageUrl,
    required bool isMultiPost,
  }) {
    final isVideo = imageUrl.endsWith(".mp4") ||
        imageUrl.endsWith(".mov") ||
        imageUrl.endsWith(".MP4");

    Widget content;
    if (isVideo) {
      content = Stack(
        children: [
          SizedBox.expand(
            child: Tagvideothumbnail(videoUrl: imageUrl),
          ),
          const Center(
            child: Icon(PhosphorIconsFill.play, size: 40, color: Colors.white),
          ),
        ],
      );
    } else {
      content = SizedBox.expand(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.textPrimary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              Image.asset(ImageUtils.profileLogo),
        ),
      );
    }

    content = ClipRect(child: content);

    if (!isMultiPost) return content;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        content,
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 6),
          child: Icon(
            PhosphorIconsFill.squaresFour,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({required String value, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.bgPrimary,
        appBar:
            salonProfileDetails != null
                ? PgAppBar(
                  showBack: false,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PgBackButton(
                          onBack: () {
                            if (isOwnProfile) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BottomNavBar(index: 0),
                                ),
                                (route) => false,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '@${userName}',
                          style: AppTypography.heading3,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (!isOwnProfile &&
                        salonProfileDetails!.userType == 2 &&
                        salonProfileDetails!.address != null &&
                        salonProfileDetails!.address!.isNotEmpty)
                      PgAppBarAction(
                        icon: PhosphorIconsRegular.mapPin,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BeautyBusinessMap(
                                    lat: salonProfileDetails!.latitude!,
                                    long: salonProfileDetails!.longitude!,
                                    salonname: salonProfileDetails!.salonName!,
                                    opendays: salonProfileDetails!.openDays!,
                                    id: salonProfileDetails!.id!.toString(),
                                  ),
                            ),
                          );
                        },
                      ),
                    if (isOwnProfile)
                      PgAppBarAction(
                        icon: PhosphorIconsRegular.dotsThreeVertical,
                        onTap: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                  ],
                )
                : AppBar(automaticallyImplyLeading: false),
        endDrawer:
            isOwnProfile && salonProfileDetails != null
                ? Drawer(
                  elevation: 10.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: Container(
                    color: AppColors.bgPrimary,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              salonProfileDetails!.profileImage != ""
                                  ? Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        "${API.baseUrl}/api/${salonProfileDetails!.profileImage!}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            ImageUtils.profileLogo,
                                          );
                                        },
                                        loadingBuilder: (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.textPrimary,
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.kAppBArBGColor,
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: const Icon(PhosphorIconsRegular.user),
                                    ),
                                  ),
                              const SizedBox(height: 10),
                              salonProfileDetails!.userType == 2
                                  ? salonProfileDetails!.salonName != ""
                                      ? Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          salonProfileDetails!.salonName!,
                                          style:
                                              AppTypography.heading3.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      )
                                      : Container()
                                  : salonProfileDetails!.userType == 1
                                  ? Container(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "${salonProfileDetails!.firstName!}${salonProfileDetails!.lastName!}",
                                      style: AppTypography.heading3.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                  : Container(),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.qrCode),
                          title: Text(
                            Languages.of(context)!.QRCodeText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QRCodeScreen(
                                      userid: userid,
                                      usertype: userTyppe,
                                      userName: userName,
                                    ),
                              ),
                            );
                          },
                        ),
                        userTyppe == "1"
                            ? ListTile(
                              leading: const Icon(PhosphorIconsRegular.gift),
                              title: Text(
                                "My Rewards",
                                style: AppTypography.bodySemiBold,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyRewardPage(),
                                  ),
                                );
                              },
                            )
                            : Container(),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.globe),
                          title: Text(
                            Languages.of(context)!.LanguageText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        const LanguageScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.graduationCap),
                          title: Text(
                            Languages.of(context)!.tutorialText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () async {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder:
                            //         (BuildContext context) =>
                            //             BottomNavBar(isIntroScreen: true),
                            //   ),
                            // );
                            // @TODO remove for release
                            // Reset all tooltips - they will appear contextually when user taps each element
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String userId = prefs.getString('userid') ?? "";
                            if (userId.isNotEmpty) {
                              await TooltipService().resetAllTooltips(userId);
                              kToast(
                                "Tutorial reset! Tooltips will appear when you tap each element.",
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.userMinus),
                          title: Text(
                            Languages.of(context)!.blockedusersText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        const BlockedusersScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.envelope),
                          title: Text(
                            "Email Visibility",
                            style: AppTypography.bodySemiBold,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isOn,
                                onChanged: (value) {
                                  setState(() {
                                    isOn = value;
                                  });

                                  // 🔥 API call
                                  updateemailvisibility(
                                    userid,
                                    value ? "1" : "0",
                                  );
                                },
                              ),
                              // Text(
                              //   isOn ? "ON" : "OFF",
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     color: isOn ? Colors.green : Colors.red,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.trash),
                          title: Text(
                            Languages.of(context)!.deleteaccountText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () async {
                            deleteAccAlert(context, kSize);
                          },
                        ),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.signOut),
                          title: Text(
                            Languages.of(context)!.logoutText,
                            style: AppTypography.bodySemiBold,
                          ),
                          onTap: () async {
                            LogoutAlert(context, kSize);
                          },
                        ),
                        // ListTile(
                        //   leading: const Icon(
                        //     Icons.play_arrow,
                        //     color: Colors.green,
                        //   ),
                        //   title: Text(
                        //     "Test Gossiper Onboarding",
                        //     style: AppTypography.bodySemiBold.copyWith(
                        //       color: Colors.green,
                        //     ),
                        //   ),
                        //   onTap: () async {
                        //     SharedPreferences prefs =
                        //         await SharedPreferences.getInstance();
                        //     await prefs.remove('onboarding_completed_$userid');
                        //     kToast("Onboarding reset! Restart app to see it.");
                        //     onTap:
                        //     () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder:
                        //               (context) => OnboardingScreen(
                        //                 userId: userid,
                        //                 userType: "1", // Gossiper
                        //               ),
                        //         ),
                        //       );
                        //     };
                        //   },
                        // ),
                        // Debug Button - Salon Onboarding
                        // ListTile(
                        //   leading: const Icon(
                        //     Icons.play_arrow,
                        //     color: Colors.orange,
                        //   ),
                        //   title: Text(
                        //     "Test Salon Onboarding",
                        //     style: AppTypography.bodySemiBold.copyWith(
                        //       color: Colors.orange,
                        //     ),
                        //   ),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder:
                        //             (context) => OnboardingScreen(
                        //               userId: userid,
                        //               userType: "2", // Salon
                        //             ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                )
                : Container(),
        body:
            isLoading == false
                ? RefreshIndicator(
                  color: AppColors.actionPrimaryDark,
                  onRefresh: () async {
                    setState(() {
                      offsett = 0;
                      isLoading = true;
                    });
                    Timer.periodic(const Duration(seconds: 2), (timer) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                    salonProfilePostArray.clear();
                    showotherimg.clear();
                    await getProfileDetails();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar with pink border
                              GestureDetector(
                                onTap: () {
                                  if (isOwnProfile) {
                                    if (myStoryArray.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MyStoryView(
                                            myStorysArray: myStoryArray,
                                            firstname: salonProfileDetails!.firstName ?? "",
                                            lastname: salonProfileDetails!.lastName ?? "",
                                            img: salonProfileDetails!.profileImage ?? "",
                                            salonanme: salonProfileDetails!.salonName ?? "",
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (getDetailsStories != null && getDetailsStories!.isNotEmpty) {
                                      if (firebaseID == salonProfileDetails!.firebaseId!) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MyStoryView(
                                              myStorysArray: myStoryArray,
                                              firstname: salonProfileDetails!.firstName ?? "",
                                              lastname: salonProfileDetails!.lastName ?? "",
                                              img: salonProfileDetails!.profileImage ?? "",
                                              salonanme: salonProfileDetails!.salonName ?? "",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SingleUserStoryView(
                                              storyUserDetailsData: getDetailsStories,
                                              myFireabseiD: firebaseID,
                                              firstname: salonProfileDetails!.firstName!,
                                              lastname: salonProfileDetails!.lastName!,
                                              profileimage: "${API.baseUrl}/api/${salonProfileDetails!.profileImage!}",
                                              salonname: salonProfileDetails!.salonName!,
                                              type: "Details",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  width: 61,
                                  height: 61,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: (isOwnProfile ? myStoryArray.isNotEmpty : (getDetailsStories != null && getDetailsStories!.isNotEmpty))
                                        ? Border.all(
                                            color: AppColors.actionPrimary,
                                            width: 2.5,
                                          )
                                        : null,
                                  ),
                                  padding: const EdgeInsets.all(2.5),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: salonProfileDetails!.profileImage != ""
                                        ? NetworkImage(
                                            "${API.baseUrl}/api/${salonProfileDetails!.profileImage!}",
                                          )
                                        : null,
                                    child: salonProfileDetails!.profileImage == ""
                                        ? const Icon(PhosphorIconsRegular.user, size: 24)
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Stats: Points / Followers / Following
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Points / Reviews
                                      _buildStatColumn(
                                        value: salonProfileDetails!.userType == 1
                                            ? totalPoints.toString()
                                            : postCountsReeview.toString(),
                                        label: salonProfileDetails!.userType == 1
                                            ? Languages.of(context)!.pointsText
                                            : Languages.of(context)!.reviewText,
                                      ),
                                      // Followers
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AllFollowingorFollowers(
                                                userid: salonProfileDetails!.id!,
                                                name: salonProfileDetails!.userType == 1
                                                    ? "${salonProfileDetails!.firstName} ${salonProfileDetails!.lastName}"
                                                    : salonProfileDetails!.salonName!,
                                                type: "follower",
                                                totlefollowing: salonProfileDetails!.followingCount!,
                                                totlefollowers: salonProfileDetails!.followersCount!,
                                                usertype: "profile",
                                                navigationType: "profile",
                                              ),
                                            ),
                                          ).then((_) => getProfileDetails());
                                        },
                                        child: _buildStatColumn(
                                          value: salonProfileDetails!.followersCount?.toString() ?? "0",
                                          label: Languages.of(context)!.follwersText,
                                        ),
                                      ),
                                      // Following
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AllFollowingorFollowers(
                                                userid: salonProfileDetails!.id!,
                                                name: salonProfileDetails!.userType == 1
                                                    ? "${salonProfileDetails!.firstName} ${salonProfileDetails!.lastName}"
                                                    : salonProfileDetails!.salonName!,
                                                type: "following",
                                                totlefollowing: salonProfileDetails!.followingCount!,
                                                totlefollowers: salonProfileDetails!.followersCount!,
                                                usertype: "profile",
                                                navigationType: "profile",
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildStatColumn(
                                          value: salonProfileDetails!.followingCount?.toString() ?? "0",
                                          label: Languages.of(context)!.followingText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bio section
                        Padding(
                          padding: const EdgeInsets.only(left: 14, right: 14, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                salonProfileDetails!.userType == 1
                                    ? "${salonProfileDetails!.firstName!} ${salonProfileDetails!.lastName!}"
                                    : salonProfileDetails!.salonName ?? "",
                                style: AppTypography.heading3.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              // User type label
                              Text(
                                salonProfileDetails!.userType == 1
                                    ? Languages.of(context)!.gossiperText
                                    : Languages.of(context)!.beautybusinessText,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFF6A7282),
                                ),
                              ),
                              // Star rating for salons
                              if (salonProfileDetails!.userType == 2 &&
                                  salonProfileDetails!.averageRating != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        double.parse(salonProfileDetails!.averageRating!).toStringAsFixed(1),
                                        style: AppTypography.captionMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      RatingBarIndicator(
                                        rating: double.parse(salonProfileDetails!.averageRating!),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        unratedColor: AppColors.klightGreyColor,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: AppColors.actionPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "(${salonProfileDetails!.ratingCount.toString()})",
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 3),
                              // Bio
                              if (salonProfileDetails!.bio != null &&
                                  salonProfileDetails!.bio!.isNotEmpty)
                                Text(
                                  salonProfileDetails!.bio!,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF6A7282),
                                    height: 1.43,
                                  ),
                                ),
                              // Salon-specific info
                              if (salonProfileDetails!.userType == 2) ...[
                                if (salonOpenDays.isNotEmpty)
                                  _showHoursUI(),
                                if (salonProfileDetails!.contactNo != null &&
                                    salonProfileDetails!.contactNo!.isNotEmpty)
                                  GestureDetector(
                                    onTap: () async {
                                      final phoneNumber = salonProfileDetails!.contactNo!;
                                      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
                                      if (await canLaunchUrl(launchUri)) {
                                        await launchUrl(launchUri);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        salonProfileDetails!.contactNo!,
                                        style: AppTypography.caption,
                                      ),
                                    ),
                                  ),
                                if (salonProfileDetails!.siteName != null &&
                                    salonProfileDetails!.siteName!.isNotEmpty)
                                  GestureDetector(
                                    onTap: () async {
                                      String siteUrl = salonProfileDetails!.siteName ?? "";
                                      if (!siteUrl.startsWith("http://") &&
                                          !siteUrl.startsWith("https://")) {
                                        siteUrl = "https://$siteUrl";
                                      }
                                      final Uri url = Uri.parse(siteUrl);
                                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                        print('Could not launch $url');
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        salonProfileDetails!.siteName!,
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (salonProfileDetails!.address != null &&
                                    salonProfileDetails!.address!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      salonProfileDetails!.address!,
                                      style: AppTypography.caption,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        isOwnProfile
                            ? Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          Map<String, dynamic> userData = {
                                            "firstname":
                                                salonProfileDetails!.firstName ?? "",
                                            "username":
                                                salonProfileDetails!.userName ?? "",
                                            "lastname":
                                                salonProfileDetails!.lastName ?? "",
                                            "bio": salonProfileDetails!.bio ?? "",
                                            "site_name":
                                                salonProfileDetails!.siteName ?? "",
                                            "email": salonProfileDetails!.email ?? "",
                                            "usertype":
                                                salonProfileDetails!.userType ?? "",
                                            "contact":
                                                salonProfileDetails!.contactNo ?? "",
                                            "address":
                                                salonProfileDetails!.address ?? "",
                                            "salonname":
                                                salonProfileDetails!.salonName ?? "",
                                            "opendays":
                                                salonProfileDetails!.openDays ?? "",
                                            "opentime":
                                                salonProfileDetails!.openTime ?? "",
                                            "profileImage":
                                                salonProfileDetails!.profileImage ??
                                                "",
                                          };

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => EditProfileScreen(
                                                    userData: userData,
                                                    latitude:
                                                        salonProfileDetails!
                                                                    .latitude !=
                                                                null
                                                            ? salonProfileDetails!
                                                                .latitude!
                                                            : "",
                                                    longitude:
                                                        salonProfileDetails!
                                                                    .longitude !=
                                                                null
                                                            ? salonProfileDetails!
                                                                .longitude!
                                                            : "",
                                                    getsalonOpenDays: salonOpenDays,
                                                  ),
                                            ),
                                          ).then((value) {
                                            // getProfileDetails();
                                          });
                                        },
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: AppColors.btnColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              Languages.of(context)!.editProfileText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    // Follow / Following button (pill, full width)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (salonProfileDetails!.isFollowed == 0) {
                                            userFollowing(userid, targetId, "0");
                                          } else {
                                            userUnfollow(userid, targetId);
                                          }
                                        },
                                        child: Container(
                                          height: 37,
                                          decoration: BoxDecoration(
                                            color: salonProfileDetails!.isFollowed == 0
                                                ? AppColors.actionPrimary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(9999),
                                            border: salonProfileDetails!.isFollowed != 0
                                                ? Border.all(color: AppColors.actionPrimary, width: 1.7)
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                salonProfileDetails!.isFollowed == 0
                                                    ? PhosphorIconsBold.userPlus
                                                    : PhosphorIconsBold.userCheck,
                                                size: 14,
                                                color: salonProfileDetails!.isFollowed == 0
                                                    ? Colors.white
                                                    : AppColors.actionPrimary,
                                              ),
                                              const SizedBox(width: 7),
                                              Text(
                                                salonProfileDetails!.isFollowed == 0
                                                    ? Languages.of(context)!.followText
                                                    : Languages.of(context)!.followingText,
                                                style: AppTypography.captionMedium.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: salonProfileDetails!.isFollowed == 0
                                                      ? Colors.white
                                                      : AppColors.actionPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    // Message button (circle with pink border)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessageDetail(
                                              oppId: salonProfileDetails!.firebaseId!.toString(),
                                              firebaseUId: firebaseID,
                                              name: "${salonProfileDetails!.firstName}${salonProfileDetails!.lastName}",
                                              userImg: salonProfileDetails!.profileImage!,
                                              type: "fromdetail",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 37,
                                        height: 37,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.actionPrimary,
                                            width: 1.7,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            PhosphorIconsRegular.chatCircle,
                                            size: AppIconSize.md,
                                            color: AppColors.actionPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFF3F4F6),
                                width: 0.85,
                              ),
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            labelColor: AppColors.actionPrimary,
                            unselectedLabelColor: const Color(0xFF9CA3AF),
                            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                            indicatorColor: AppColors.actionPrimary,
                            indicatorWeight: 1.7,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelPadding: EdgeInsets.zero,
                            onTap: (value) {
                              setState(() {
                                currentindex = value;
                              });
                              if (Platform.isIOS) {
                                if (value == 1) {
                                  Future.delayed(
                                    const Duration(seconds: 5),
                                    () {
                                      if (_videogridviewController.hasClients) {
                                        _videogridviewController.animateTo(
                                          1.0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.bounceIn,
                                        );
                                      }
                                    },
                                  );
                                }
                              }
                            },
                            tabs:
                                userTyppe == "1"
                                    ? [
                                      Tab(
                                        child: Icon(
                                          currentindex == 0
                                              ? PhosphorIconsFill.squaresFour
                                              : PhosphorIconsRegular.squaresFour,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                      Tab(
                                        child: Icon(
                                          currentindex == 1
                                              ? PhosphorIconsFill.playCircle
                                              : PhosphorIconsRegular.playCircle,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                      Tab(
                                        child: Icon(
                                          currentindex == 2
                                              ? PhosphorIconsFill.at
                                              : PhosphorIconsRegular.at,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                    ]
                                    : [
                                      Tab(
                                        child: Icon(
                                          currentindex == 0
                                              ? PhosphorIconsFill.squaresFour
                                              : PhosphorIconsRegular.squaresFour,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                      Tab(
                                        child: Icon(
                                          currentindex == 1
                                              ? PhosphorIconsFill.playCircle
                                              : PhosphorIconsRegular.playCircle,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                      Tab(
                                        child: Icon(
                                          currentindex == 2
                                              ? PhosphorIconsFill.at
                                              : PhosphorIconsRegular.at,
                                          size: AppIconSize.md,
                                        ),
                                      ),
                                    ],
                          ),
                        ),
                        SizedBox(
                          height: kSize.height * 0.6,
                          width: kSize.width,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              //First tab UI
                              salonProfilePostArray.isNotEmpty
                                  ? salonProfileDetails!.userType == 1
                                      ? GridView.builder(
                                        controller: _scrollController,
                                        itemCount: salonProfilePostArray.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 2,
                                              mainAxisSpacing: 2,
                                            ),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          print(
                                            "salonProfilePostArray[index].afterImage = ${salonProfilePostArray.length}",
                                          );

                                          print(
                                            "showotherimg[index]['f_img'] ${showotherimg[index]['f_img']}",
                                          );

                                          print(
                                            "showotherimg = ${showotherimg.length}",
                                          );
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => ShowPostImage(
                                                        postData:
                                                            [salonProfilePostArray[index]],
                                                        selectedLessonIndex:
                                                            0,
                                                        usertype:
                                                            salonProfileDetails!
                                                                .userType!
                                                                .toString(),
                                                        isProfile: true,
                                                        type: "Profile",
                                                        mystories: myStoryArray,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: _buildGridItem(
                                              imageUrl: salonProfilePostArray[index].beforeImage != ""
                                                  ? "${API.baseUrl}/api/${salonProfilePostArray[index].afterImage}"
                                                  : showotherimg[index]['f_img'],
                                              isMultiPost: salonProfilePostArray[index].beforeImage != ""
                                                  ? (salonProfilePostArray[index].otherMultiPost?.isNotEmpty ?? false)
                                                  : (salonProfilePostArray[index].otherMultiPost?.length ?? 0) > 1,
                                            ),
                                          );
                                        },
                                      )
                                      : GridView.builder(
                                        controller: _scrollController,
                                        itemCount: showotherimg.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 2,
                                              mainAxisSpacing: 2,
                                            ),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          print(
                                            "tempprofilePostAray == ${tempprofilePostAray}",
                                          );
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => ShowPostImage(
                                                        postData:
                                                            [salonProfilePostArray[index]],
                                                        selectedLessonIndex:
                                                            0,
                                                        usertype:
                                                            salonProfileDetails!
                                                                .userType!
                                                                .toString(),
                                                        isProfile: true,
                                                        type: "Profile",
                                                        mystories: myStoryArray,
                                                      ),
                                                ),
                                              );
                                            },
                                            child:
                                                showotherimg[index].isNotEmpty
                                                    ? _buildGridItem(
                                                        imageUrl: showotherimg[index]['f_img'],
                                                        isMultiPost: (showotherimg[index]['otherpostlen'] ?? 0) > 1,
                                                      )
                                                    : Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(PhosphorIconsRegular.user),
                                                      ),
                                          );
                                        },
                                      )
                                  : Center(
                                    child: Text(
                                      Languages.of(
                                        context,
                                      )!.NopostavailableText,
                                      style: AppTypography.heading3,
                                    ),
                                  ),
                              //Second tab UI
                              videoList.isNotEmpty
                                  ? GridView.builder(
                                    controller: _videogridviewController,
                                    itemCount: videoList.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 2,
                                          mainAxisSpacing: 2,
                                        ),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ShowPostVideo(
                                                    getvideoList: videoList,
                                                    selectedLessonIndex: index,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: _buildGridItem(
                                          imageUrl: videoList[index],
                                          isMultiPost: false,
                                        ),
                                      );
                                    },
                                  )
                                  : Center(
                                    child: Text(
                                      Languages.of(
                                        context,
                                      )!.NovideoavailableText,
                                      style: AppTypography.heading3,
                                    ),
                                  ),
                              //Third tab UI
                              tagPostList!.isNotEmpty
                                  ? GridView.builder(
                                    itemCount: tagPostList!.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 0.85,
                                        ),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      TagPostViewScreen(
                                                        postData: tagPostList!,
                                                        selectedLessonIndex:
                                                            index,
                                                        usertype:
                                                            salonProfileDetails!
                                                                .userType!
                                                                .toString(),
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                              height: kSize.height,
                                              width: kSize.width,
                                              margin: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color:
                                                      AppColors
                                                          .kTextFieldBorderColor,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child:
                                                    tagPostList![index]
                                                                .beforeImage!
                                                                .isNotEmpty ||
                                                            tagPostList![index]
                                                                .afterImage!
                                                                .isNotEmpty
                                                        ? Image.network(
                                                          "${API.baseUrl}/api/${tagPostList![index].beforeImage}",
                                                          fit: BoxFit.cover,
                                                          loadingBuilder: (
                                                            BuildContext
                                                            context,
                                                            Widget child,
                                                            ImageChunkEvent?
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return SizedBox(
                                                              height: 100,
                                                              width: 100,
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  color:
                                                                      AppColors.textPrimary,
                                                                  value:
                                                                      loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                        : tagPostList![index]
                                                                .otherMultiPost![0]
                                                                .otherData!
                                                                .endsWith(
                                                                  ".mp4",
                                                                ) ||
                                                            tagPostList![index]
                                                                .otherMultiPost![0]
                                                                .otherData!
                                                                .endsWith(
                                                                  ".mov",
                                                                ) ||
                                                            tagPostList![index]
                                                                .otherMultiPost![0]
                                                                .otherData!
                                                                .endsWith(
                                                                  ".MP4",
                                                                )
                                                        ? Stack(
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  kSize.height,
                                                              width:
                                                                  kSize.width,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                                child: Tagvideothumbnail(
                                                                  videoUrl:
                                                                      "${API.baseUrl}/api/${tagPostList![index].otherMultiPost![0].otherData}",
                                                                ),
                                                              ),
                                                            ),
                                                            const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .play_arrow_rounded,
                                                                size: 50,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                        : Image.network(
                                                          "${API.baseUrl}/api/${tagPostList![index].otherMultiPost![0].otherData!}",
                                                          fit: BoxFit.cover,
                                                          loadingBuilder: (
                                                            BuildContext
                                                            context,
                                                            Widget child,
                                                            ImageChunkEvent?
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return SizedBox(
                                                              height: 100,
                                                              width: 100,
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  color:
                                                                      AppColors.textPrimary,
                                                                  value:
                                                                      loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                              ),
                                            ),
                                            tagPostList![index]
                                                        .otherMultiPost!
                                                        .length >
                                                    1
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                        right: 8,
                                                      ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Image.asset(
                                                      "lib/assets/images/multipost.png",
                                                      height: 22,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                                : Container(),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        Languages.of(context)!.postofyouText,
                                        style: AppTypography.heading2,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        Languages.of(
                                          context,
                                        )!.emptytaglisttitleText,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : Container(
                  height: kSize.height,
                  width: kSize.width,
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                ),
      ),
    );
  }

  void scrollToTopOfGridView() {
    _videogridviewController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<dynamic> LogoutAlert(BuildContext context, Size kSize) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: AlertDialog(
              backgroundColor: AppColors.bgPrimary,
              title: Text(Languages.of(context)!.LogoutText),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.logouttiletText,
                style: AppTypography.bodySemiBold,
              ),
              actions: <Widget>[
                SizedBox(
                  width: kSize.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.kAppBArBGColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.noText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove("step");
                            prefs.remove("curruntsalonid");
                            prefs.remove("beforeImage");
                            prefs.remove("afterImage");
                            prefs.remove("otherData");
                            prefs.setBool("isLogin", false);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              ModalRoute.withName('/'),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.kAppBArBGColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.yesText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
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

  Future<dynamic> deleteAccAlert(BuildContext context, Size kSize) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: AlertDialog(
              backgroundColor: AppColors.bgPrimary,
              title: Text(Languages.of(context)!.deleteaccountText),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.deleteaccountmsgText,
                style: AppTypography.bodySemiBold,
              ),
              actions: <Widget>[
                SizedBox(
                  width: kSize.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.kAppBArBGColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.noText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            await deleteAccount(userid);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.kAppBArBGColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.yesText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
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

  getProfileDetails() async {
    print("getProfileDetails function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      prefs!.remove('profileimg');
      if (isConnected) {
        await Provider.of<SalonDetailsViewModel>(
          context,
          listen: false,
        ).getSalonDetails(targetId, userid, offsett, targetType);
        if (Provider.of<SalonDetailsViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<SalonDetailsViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              videoList.clear();
              tempprofilePostAray.clear();
              salonProfilePostArray.clear();
              print("Success");
              SalonDetailModel model =
                  Provider.of<SalonDetailsViewModel>(
                        context,
                        listen: false,
                      ).salondetailsresponse.response
                      as SalonDetailModel;

              salonProfileDetails = model.userProfile!;
              isOn = model.userProfile!.emailVisibility ?? false;
              totalPoints = model.points!;
              postCountsReeview = model.postCountReview!;
              print("model.points ${model.points}");

              tempprofilePostAray = model.posts!;
              // userName = model.userProfile!.userName ?? "";
              userName =
                  model.userProfile!.userName!.isNotEmpty
                      ? model.userProfile!.userName!
                      : "${model.userProfile!.firstName!} ${model.userProfile!.lastName!}";
              totlepostcount = model.postCount!;
              getDetailsStories = model.story!;

              isOn = model.userProfile!.emailVisibility!;
              print("isOn==${isOn}");
              tagPostList = model.tagPosts!.reversed.toList();
              setState(() {});
              salonProfilePostArray.addAll(tempprofilePostAray);

              salonOpenDays = model.salonOpenDays!;

              offsett = offsett + 20;

              print(
                "model.userProfile!.profileImage!  == ${model.userProfile!.profileImage!}",
              );

              if (model.userProfile!.profileImage != null &&
                  model.userProfile!.profileImage!.isNotEmpty) {
                print(
                  "Saving profile image: ${model.userProfile!.profileImage!}",
                );
                prefs!.setString(
                  'profileimg',
                  model.userProfile!.profileImage!,
                );
              }

              salonProfilePostArray.forEach((element) async {
                if (element.postType == "RewardPost") {
                  salonRewardRedeemPostArray.add(element);
                } else {
                  if (element.otherMultiPost!.isNotEmpty) {
                    String fileExtension = getFileExtension(
                      element.otherMultiPost!.first.otherData!,
                    );

                    if (fileExtension == ".jpg" ||
                        fileExtension == ".mp4" ||
                        fileExtension == ".mov" ||
                        fileExtension == ".MP4") {
                      if (element.afterImage == "" &&
                          element.beforeImage == "") {
                        showotherimg.add({
                          "f_img":
                              "${API.baseUrl}/api/${element.otherMultiPost!.first.otherData}",
                          "otherpostlen": element.otherMultiPost!.length,
                        });
                        print(
                          "showotherimg ${showotherimg} ${showotherimg.length}",
                        );
                      }
                    } else {
                      print("elsee");
                    }
                  }

                  if (model.userProfile!.userType == 1 &&
                      element.afterImage != "" &&
                      element.beforeImage != "") {
                    showotherimg.add({
                      "f_img": "${API.baseUrl}/api/${element.afterImage}",
                      "otherpostlen": (element.otherMultiPost?.length ?? 0) + 1,
                    });
                  }
                  if (model.userProfile!.userType == 2 &&
                      element.afterImage != "" &&
                      element.beforeImage != "") {
                    showotherimg.add({
                      "f_img": "${API.baseUrl}/api/${element.afterImage}",
                      "otherpostlen": (element.otherMultiPost?.length ?? 0) + 1,
                    });
                  }

                  element.otherMultiPost!.forEach((element) {
                    String fileExtension = getFileExtension(
                      element.otherData.toString(),
                    );
                    print("fileExtension ==${fileExtension}");
                    if (fileExtension == ".mp4") {
                      videoList.add(
                        "${API.baseUrl}/api/${element.otherData.toString()}",
                      );
                      setState(() {});
                    }
                  });
                }
              });

              print("video list ===${videoList}");

              setState(() {
                _videoPlayercontroller =
                    videoList.map((videoUrl) {
                      return VideoPlayerController.network(videoUrl)
                        ..initialize();
                    }).toList();
              });

              setState(() {});
            });
            setState(() {});
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  String getFileExtension(String fileName) {
    return "." + fileName.split('.').last;
  }

  getStory() async {
    print("get getStory function call");
    setState(() {
      // isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<GetStoryViewModel>(
          context,
          listen: false,
        ).getStory(userid);
        if (Provider.of<GetStoryViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<GetStoryViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            myStoryArray.clear();

            setState(() {
              // isLoading = false;
              print("Success");
              GetStoryResponseModel model =
                  Provider.of<GetStoryViewModel>(
                        context,
                        listen: false,
                      ).getstoryresponse.response
                      as GetStoryResponseModel;

              print("model == ${model.message}");

              for (var story in model.data!) {
                if (story.userId == int.parse(userid)) {
                  myStoryArray.add(story);
                } else {}
              }
            });
          }
        } else {
          setState(() {
            // isLoading = false;
          });
          kToast(Languages.of(context)!.noInternetText);
        }
      }
    });
  }

  String getpostTime(DateTime loadedTime) {
    print("loadedTime === ${loadedTime}");
    final now = DateTime.now();
    final difference = now.difference(loadedTime);
    DateTime postTime = now.subtract(difference);
    String timeAgo = timeago.format(postTime, locale: 'en');
    print("postDateTime === ${timeAgo}");
    return timeAgo;
  }

  ProfilePhotoUpdate(String profile_image) async {
    print("get getProfileDetails function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<UpdatePofilePhotoViewModel>(
          context,
          listen: false,
        ).ProfilePhotoUpdate(profile_image, userid);
        if (Provider.of<UpdatePofilePhotoViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<UpdatePofilePhotoViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;

              print("Success");
              UpdateProfileModel model =
                  Provider.of<UpdatePofilePhotoViewModel>(
                        context,
                        listen: false,
                      ).updateprofilephotoresponse.response
                      as UpdateProfileModel;

              kToast(model.message!);
              if (model.success == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(index: 4),
                  ),
                );
              }
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  deleteAccount(String userId) async {
    print("get deleteAccount function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<BlockUserViewModel>(
          context,
          listen: false,
        ).deleteAccount(userId);
        if (Provider.of<BlockUserViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<BlockUserViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("Success");
            PostDeleteModel model =
                Provider.of<BlockUserViewModel>(
                      context,
                      listen: false,
                    ).deleteaccountresponse.response
                    as PostDeleteModel;
            kToast(model.message!);
            setState(() {
              isLoading = false;
            });
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              ModalRoute.withName('/'),
            );
          } else {
            setState(() {
              isLoading = false;
            });
            kToast(
              Provider.of<BlockUserViewModel>(
                context,
                listen: false,
              ).deleteaccountresponse.msg,
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  _showHoursUI() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showHours = !_showHours;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showHours
                        ? Languages.of(context)!.hideStoreHours
                        : Languages.of(context)!.viewStorehours,
                    style: AppTypography.captionMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _showHours
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_showHours) const Divider(height: 12),
          if (_showHours)
            ListView.builder(
              itemCount: salonOpenDays.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          salonOpenDays[index].open!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatTime(salonOpenDays[index].startTime!),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Languages.of(context)!.toText,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatTime(salonOpenDays[index].endTime!),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  getRewardRedempPostListUI(Size kSize) {
    return ListView.builder(
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: salonRewardRedeemPostArray.length,
      itemBuilder: (context, index) {
        return RewardRedemptionPostWidget(
          kSize,
          postData: salonRewardRedeemPostArray[index],
          profileUserId: userid,
        );
      },
    );
  }

  RewardRedemptionPostWidget(
    Size kSize, {
    required Post postData,
    required String profileUserId,
  }) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                "${API.baseUrl}/api/${postData.otherMultiPost![0].otherData!}",
                fit: BoxFit.fill,
                width: kSize.width,
                height: kSize.height * 0.40,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: kSize.height * 0.40,
                    width: kSize.width,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),

              /// ✅ RIGHT SIDE – CENTER
              Positioned(
                top: 10,
                right: 10,

                child: InkWell(
                  onTap: () {
                    moreOptionBottomsheet(context, kSize, postData.id ?? 0);
                  },
                  child: Image.asset(
                    ImageUtils.moreoptionimg,
                    color: AppColors.bgPrimary,
                    height: 30,
                    width: 15,
                  ),
                ),
              ),
            ],
          ),

          Container(
            width: kSize.width,
            // color: Colors.red,
            color: AppColors.actionPrimaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Text(
                  Languages.of(context)!.redeemNowText,
                  style: AppTypography.heading3.copyWith(fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  updateemailvisibility(String id, String is_email_visibility) async {
    print("get updateemailvisibility function call");

    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SalonDetailsViewModel>(
          context,
          listen: false,
        ).updateemailvisibility(userid, is_email_visibility);
        if (Provider.of<SalonDetailsViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<SalonDetailsViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              SalonDetailModel model =
                  Provider.of<SalonDetailsViewModel>(
                        context,
                        listen: false,
                      ).salondetailsresponse.response
                      as SalonDetailModel;

              if (model.success == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(index: 4),
                  ),
                );
              }
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  void moreOptionBottomsheet(
    BuildContext screenContext, // 🔥 MAIN SCREEN context
    Size kSize,
    int postID,
  ) {
    showModalBottomSheet(
      context: screenContext, // ✅ USE SCREEN CONTEXT
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔽 DELETE
                TextButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    DeleteAlert(screenContext, kSize, postID);
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset("lib/assets/images/delete.png"),
                      ),
                      SizedBox(width: 20),
                      Text("Delete", style: AppTypography.heading2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> DeleteAlert(BuildContext context, Size kSize, postID) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: AlertDialog(
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              title: Text(Languages.of(context)!.deleteText),
              titleTextStyle: AppTypography.heading1,
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.deleteposttitleText,
                style: AppTypography.heading2.copyWith(fontWeight: FontWeight.w500, color: AppColors.textTertiary),
              ),
              actions: <Widget>[
                SizedBox(
                  width: kSize.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.chatSenderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.noText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            print("postID == ${postID}");
                            getPostDelete(postID.toString());
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.chatSenderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                Languages.of(context)!.yesText,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
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

  getPostDelete(String post_id) async {
    print("get getSalonList function call");
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<PostDeleteViewModel>(
          context,
          listen: false,
        ).getPostDelete(post_id);
        if (Provider.of<PostDeleteViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<PostDeleteViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              setState(() {});

              print("Success");
              PostDeleteModel model =
                  Provider.of<PostDeleteViewModel>(
                        context,
                        listen: false,
                      ).postdeleteresponse.response
                      as PostDeleteModel;

              kToast(model.message!);
              if (model.success == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(index: 4),
                  ),
                );
              }
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  userFollowing(String following_id, String follower_id, String status) async {
    print("get userFollowing function call");
    setState(() {});
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<FollowingViewModel>(
          context,
          listen: false,
        ).userFollowing(following_id, follower_id, status);
        if (Provider.of<FollowingViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<FollowingViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              print("Success");
              FollowingModel model =
                  Provider.of<FollowingViewModel>(
                        context,
                        listen: false,
                      ).followingresponse.response
                      as FollowingModel;

              if (model.success == true) {
                followCheck(targetId);
              }

              kToast(model.message!);
            });
          }
        }
      } else {
        setState(() {});
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  userUnfollow(String following_id, String follower_id) async {
    print("get userUnfollow function call");
    setState(() {});
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<UnfollowViewModel>(
          context,
          listen: false,
        ).userUnfollow(following_id, follower_id);
        if (Provider.of<UnfollowViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<UnfollowViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              print("Success");
              UnfollowiModel model =
                  Provider.of<UnfollowViewModel>(
                        context,
                        listen: false,
                      ).unfollowresponse.response
                      as UnfollowiModel;
              if (model.success == true) {
                followCheck(targetId);
              }
              kToast(model.message!);
            });
          }
        }
      } else {
        setState(() {});
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  followCheck(String id) async {
    salonProfilePostArray.clear();
    print("get followCheck function call");
    setState(() {});
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SalonDetailsViewModel>(
          context,
          listen: false,
        ).getSalonDetails(id, userid, 0, targetType);
        if (Provider.of<SalonDetailsViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<SalonDetailsViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              videoList.clear();
              salonProfilePostArray.clear();
              showotherimg.clear();
              print("Success");
              SalonDetailModel model =
                  Provider.of<SalonDetailsViewModel>(
                        context,
                        listen: false,
                      ).salondetailsresponse.response
                      as SalonDetailModel;

              salonProfileDetails = model.userProfile!;
              print(salonProfileDetails!.toJson());
              salonProfilePostArray = model.posts!;

              salonProfilePostArray.forEach((element) {
                if (element.otherMultiPost!.isNotEmpty) {
                  String ext = getFileExtension(
                    element.otherMultiPost!.first.otherData!,
                  );
                  if (ext == ".jpg" || ext == ".mp4" || ext == ".mov" || ext == ".MP4") {
                    if (element.afterImage == "" && element.beforeImage == "") {
                      showotherimg.add({
                        "f_img": "${API.baseUrl}/api/${element.otherMultiPost!.first.otherData}",
                        "otherpostlen": element.otherMultiPost!.length,
                      });
                    }
                  }
                }
                if (element.afterImage != "" && element.beforeImage != "") {
                  showotherimg.add({
                    "f_img": "${API.baseUrl}/api/${element.afterImage}",
                    "otherpostlen": (element.otherMultiPost?.length ?? 0) + 1,
                  });
                }
                element.otherMultiPost!.forEach((mp) {
                  String ext = getFileExtension(mp.otherData.toString());
                  if (ext == ".mp4") {
                    videoList.add("${API.baseUrl}/api/${mp.otherData.toString()}");
                  }
                });
              });

              print("video list ===${videoList}");
            });
          }
        }
      } else {
        setState(() {});
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  void _showDeepLinkWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Hey 💕 welcome on Pink Gossip",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Where your in-salon content is actually rewarding.\n\n"
            "Start your beauty journey by winning 50 points by taking a before picture 📸✨",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Later",
                style: AppTypography.bodyMedium.copyWith(color: AppColors.drktxtGrey).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                prefs!.remove("beforeImage");
                prefs!.remove("afterImage");
                prefs!.remove("otherData");
                prefs!.setInt("step", 2);
                prefs!.setString("curruntsalonid", targetId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(index: 2),
                  ),
                );
              },
              child: Text(
                "Start Now",
                style: AppTypography.bodyMedium.copyWith(color: AppColors.drktxtGrey).copyWith(
                  color: AppColors.btnColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
