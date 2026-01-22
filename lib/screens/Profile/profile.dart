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
import 'package:pinkGossip/screens/Profile/beautybusinessmap.dart';
import 'package:pinkGossip/screens/Profile/blockedusers.dart';
import 'package:pinkGossip/screens/Profile/language.dart';
import 'package:pinkGossip/screens/Profile/qrcode.dart';
import 'package:pinkGossip/screens/allfollowingorfollowers.dart';
import 'package:pinkGossip/screens/tagpostview.dart';
import 'package:pinkGossip/viewModels/blockuserviewmodel.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/services/tooltip_service.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/updateprofilephoto.dart';
import 'package:pinkGossip/screens/Profile/editprofile.dart';
import 'package:pinkGossip/screens/onboarding/onboarding_screen.dart';
import 'package:pinkGossip/screens/showpostimage.dart';
import 'package:pinkGossip/screens/showpostvideo.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/salondetailsviewmodel.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmdoel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid') ?? "";
    userTyppe = prefs!.getString('userType') ?? "apple";

    print("userid   ${userid}");
    print("userid   ${userTyppe}");
  }

  int offsett = 0;
  List<Stories> myStoryArray = [];

  @override
  void initState() {
    super.initState();

    getuserid();
    getProfileDetails();

    getStory();

    _scrollController.addListener(_loadMoreData);
    for (int i = 0; i < videoList.length; i++) {
      _videoPlayercontroller[i] = VideoPlayerController.networkUrl(
        Uri.parse(videoList[i]),
      );
      _videoPlayercontroller[i].initialize();
    }

    _tabController = TabController(length: 3, vsync: this);
    _tabController.animation!.addListener(_handleTabChange);
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
          print("Future.delayed");
          _videogridviewController.animateTo(
            1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceIn,
          );
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

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.kWhiteColor,
        appBar:
            salonProfileDetails != null
                ? AppBar(
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: AppColors.kAppBArBGColor,
                  automaticallyImplyLeading: false,
                  elevation: 2.0,
                  actions: [
                    salonProfileDetails!.userType == 2
                        ? (salonProfileDetails!.address == null ||
                                salonProfileDetails!.address!.isEmpty ||
                                Platform.isAndroid)
                            ? Container()
                            : SizedBox(
                              height: 23,
                              width: 23,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => BeautyBusinessMap(
                                            lat: salonProfileDetails!.latitude!,
                                            long:
                                                salonProfileDetails!.longitude!,
                                            salonname:
                                                salonProfileDetails!.salonName!,
                                            opendays:
                                                salonProfileDetails!.openDays!,
                                            id:
                                                salonProfileDetails!.id!
                                                    .toString(),
                                          ),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  ImageUtils.mapImage,
                                  color: AppColors.kBlackColor,
                                ),
                              ),
                            )
                        : Container(),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                  title: Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        salonProfileDetails!.userName!,
                        style: Pallete.Quicksand16drkBlackBold,
                      ),
                    ],
                  ),
                )
                : AppBar(automaticallyImplyLeading: false),
        endDrawer:
            salonProfileDetails != null
                ? Drawer(
                  elevation: 10.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                  ),
                  child: Container(
                    color: AppColors.kWhiteColor,
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
                                                color: AppColors.kBlackColor,
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
                                      child: const Icon(Icons.person),
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
                                              Pallete.Quicksand16drkBlackbold,
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
                                      style: Pallete.Quicksand16drkBlackbold,
                                    ),
                                  )
                                  : Container(),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.push(context,MaterialPageRoute(builder: (context) => ,));
                              //   },
                              //   child: Container(
                              //     color: Colors.amber,
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.qr_code_scanner_rounded),
                          title: Text(
                            Languages.of(context)!.QRCodeText,
                            style: Pallete.Quicksand15blackwe600,
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
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            Languages.of(context)!.LanguageText,
                            style: Pallete.Quicksand15blackwe600,
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
                          leading: const Icon(Icons.app_shortcut_rounded),
                          title: Text(
                            Languages.of(context)!.tutorialText,
                            style: Pallete.Quicksand15blackwe600,
                          ),
                          onTap: () async {
                            // @TODO remove for release
                            // Reset all tooltips - they will appear contextually when user taps each element
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String userId = prefs.getString('userid') ?? "";
                            if (userId.isNotEmpty) {
                              await TooltipService().resetAllTooltips(userId);
                              kToast("Tutorial reset! Tooltips will appear when you tap each element.");
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            Languages.of(context)!.blockedusersText,
                            style: Pallete.Quicksand15blackwe600,
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
                          leading: const Icon(Icons.delete_outline_outlined),
                          title: Text(
                            Languages.of(context)!.deleteaccountText,
                            style: Pallete.Quicksand15blackwe600,
                          ),
                          onTap: () async {
                            deleteAccAlert(context, kSize);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: Text(
                            Languages.of(context)!.logoutText,
                            style: Pallete.Quicksand15blackwe600,
                          ),
                          onTap: () async {
                            LogoutAlert(context, kSize);
                          },
                        ),
                        // Debug Button - Gossiper Onboarding
                        ListTile(
                          leading: const Icon(Icons.play_arrow, color: Colors.green),
                          title: Text(
                            "Test Gossiper Onboarding",
                            style: Pallete.Quicksand15blackwe600.copyWith(color: Colors.green),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingScreen(
                                  userId: userid,
                                  userType: "1", // Gossiper
                                ),
                              ),
                            );
                          },
                        ),
                        // Debug Button - Salon Onboarding
                        ListTile(
                          leading: const Icon(Icons.play_arrow, color: Colors.orange),
                          title: Text(
                            "Test Salon Onboarding",
                            style: Pallete.Quicksand15blackwe600.copyWith(color: Colors.orange),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingScreen(
                                  userId: userid,
                                  userType: "2", // Salon
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
                : Container(),
        body:
            isLoading == false
                ? RefreshIndicator(
                  color: AppColors.kPinkColor,
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
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      salonProfileDetails!.profileImage != ""
                                          ? GestureDetector(
                                            onTap: () {
                                              if (myStoryArray.isNotEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => MyStoryView(
                                                          myStorysArray:
                                                              myStoryArray,
                                                          firstname:
                                                              salonProfileDetails!
                                                                  .firstName ??
                                                              "",
                                                          lastname:
                                                              salonProfileDetails!
                                                                  .lastName ??
                                                              "",
                                                          img:
                                                              salonProfileDetails!
                                                                  .profileImage ??
                                                              "",
                                                          salonanme:
                                                              salonProfileDetails!
                                                                  .salonName ??
                                                              "",
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration:
                                                  getDetailsStories!.isNotEmpty
                                                      ? const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors
                                                                .kPinkColor,
                                                            AppColors
                                                                .kPinkColor,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end:
                                                              Alignment
                                                                  .bottomRight,
                                                        ),
                                                      )
                                                      : const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                              padding: const EdgeInsets.all(
                                                3.0,
                                              ),
                                              child: CircleAvatar(
                                                radius: 50,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage: NetworkImage(
                                                  "${API.baseUrl}/api/${salonProfileDetails!.profileImage!}",
                                                ),
                                              ),
                                            ),
                                          )
                                          : GestureDetector(
                                            onTap: () {
                                              if (myStoryArray.isNotEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => MyStoryView(
                                                          myStorysArray:
                                                              myStoryArray,
                                                          firstname:
                                                              salonProfileDetails!
                                                                  .firstName ??
                                                              "",
                                                          lastname:
                                                              salonProfileDetails!
                                                                  .lastName ??
                                                              "",
                                                          img:
                                                              salonProfileDetails!
                                                                  .profileImage ??
                                                              "",
                                                          salonanme:
                                                              salonProfileDetails!
                                                                  .salonName ??
                                                              "",
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration:
                                                  getDetailsStories!.isNotEmpty
                                                      ? const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors
                                                                .kPinkColor,
                                                            AppColors
                                                                .kPinkColor,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end:
                                                              Alignment
                                                                  .bottomRight,
                                                        ),
                                                      )
                                                      : const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                              padding: const EdgeInsets.all(
                                                3.0,
                                              ),
                                              child: CircleAvatar(
                                                radius: 50,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: const Icon(Icons.person),
                                              ),
                                            ),
                                          ),
                                      Positioned(
                                        bottom: 4,
                                        right: 5,
                                        child: Container(
                                          height: 20.0,
                                          width: 20.0,
                                          decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black38,
                                                blurRadius: 12.0,
                                              ),
                                            ],
                                            color: AppColors.kblueColor,
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                            onTap: () {
                                              // pickImage();
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) => AddStory(
                                                        type: "Home",
                                                      ),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    const begin = Offset(
                                                      -1.0,
                                                      0.0,
                                                    );
                                                    const end = Offset(
                                                      0.0,
                                                      0.0,
                                                    );
                                                    const curve =
                                                        Curves.easeInOut;

                                                    var tween = Tween(
                                                      begin: begin,
                                                      end: end,
                                                    ).chain(
                                                      CurveTween(curve: curve),
                                                    );
                                                    var offsetAnimation =
                                                        animation.drive(tween);
                                                    return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              ).then((value) {
                                                getStory();
                                              });
                                            },
                                            child: const Icon(
                                              Icons.add,
                                              size: 16.0,
                                              color: AppColors.kWhiteColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Container(
                                      // color: Colors.green,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      salonProfileDetails!
                                                                  .userType ==
                                                              1
                                                          ? totalPoints
                                                              .toString()
                                                          : postCountsReeview
                                                              .toString(),
                                                      style:
                                                          Pallete
                                                              .Quicksand16drkBlackBold,
                                                    ),
                                                    Text(
                                                      salonProfileDetails!
                                                                  .userType ==
                                                              1
                                                          ? Languages.of(
                                                            context,
                                                          )!.pointsText
                                                          : Languages.of(
                                                            context,
                                                          )!.reviewText,

                                                      style:
                                                          Pallete
                                                              .Quicksand16drktxtGreywe500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Expanded(
                                              //   child: Column(
                                              //     children: [
                                              //       const SizedBox(height: 5),
                                              //       Text(
                                              //         // salonProfilePostArray.length
                                              //         //     .toString(),
                                              //         totalPoints.toString(),
                                              //         style:
                                              //             Pallete
                                              //                 .Quicksand16drkBlackBold,
                                              //       ),
                                              //       Text(
                                              //         Languages.of(
                                              //           context,
                                              //         )!.pointsText,
                                              //         // Languages.of(context)!
                                              //         //     .postsText,
                                              //         style:
                                              //             Pallete
                                              //                 .Quicksand16drktxtGreywe500,
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AllFollowingorFollowers(
                                                              userid:
                                                                  salonProfileDetails!
                                                                      .id!,
                                                              name:
                                                                  salonProfileDetails!
                                                                              .userType ==
                                                                          1
                                                                      ? "${salonProfileDetails!.firstName} ${salonProfileDetails!.lastName}"
                                                                      : salonProfileDetails!
                                                                          .salonName!,
                                                              type: "follower",
                                                              totlefollowing:
                                                                  salonProfileDetails!
                                                                      .followingCount!,
                                                              totlefollowers:
                                                                  salonProfileDetails!
                                                                      .followersCount!,
                                                              usertype:
                                                                  "profile",
                                                              navigationType:
                                                                  "profile",
                                                            ),
                                                      ),
                                                    ).then((value) {
                                                      getProfileDetails();
                                                    });
                                                  },
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        salonProfileDetails!
                                                                    .followersCount !=
                                                                null
                                                            ? salonProfileDetails!
                                                                .followersCount
                                                                .toString()
                                                            : "0",
                                                        style:
                                                            Pallete
                                                                .Quicksand16drkBlackBold,
                                                      ),
                                                      Text(
                                                        Languages.of(
                                                          context,
                                                        )!.follwersText,
                                                        style:
                                                            Pallete
                                                                .Quicksand16drktxtGreywe500,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AllFollowingorFollowers(
                                                              userid:
                                                                  salonProfileDetails!
                                                                      .id!,
                                                              name:
                                                                  salonProfileDetails!
                                                                              .userType ==
                                                                          1
                                                                      ? "${salonProfileDetails!.firstName} ${salonProfileDetails!.lastName}"
                                                                      : salonProfileDetails!
                                                                          .salonName!,
                                                              type: "following",
                                                              totlefollowing:
                                                                  salonProfileDetails!
                                                                      .followingCount!,
                                                              totlefollowers:
                                                                  salonProfileDetails!
                                                                      .followersCount!,
                                                              usertype:
                                                                  "profile",
                                                              navigationType:
                                                                  "profile",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        salonProfileDetails!
                                                                    .followingCount !=
                                                                null
                                                            ? salonProfileDetails!
                                                                .followingCount
                                                                .toString()
                                                            : "0",
                                                        style:
                                                            Pallete
                                                                .Quicksand16drkBlackBold,
                                                      ),
                                                      Text(
                                                        Languages.of(
                                                          context,
                                                        )!.followingText,
                                                        style:
                                                            Pallete
                                                                .Quicksand16drktxtGreywe500,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          userTyppe == "2"
                                              ? Container(
                                                // color: Colors.blue,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      double.parse(
                                                        salonProfileDetails!
                                                            .averageRating!,
                                                      ).toStringAsFixed(1),
                                                      style:
                                                          Pallete
                                                              .Quicksand12blackwe400,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    RatingBarIndicator(
                                                      rating: double.parse(
                                                        salonProfileDetails!
                                                            .averageRating
                                                            .toString(),
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 18.0,
                                                      unratedColor:
                                                          AppColors
                                                              .klightGreyColor,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder:
                                                          (
                                                            context,
                                                            _,
                                                          ) => const Icon(
                                                            Icons.star,
                                                            color:
                                                                AppColors
                                                                    .kPinkColor,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "(${salonProfileDetails!.ratingCount.toString()})",
                                                      style:
                                                          Pallete
                                                              .Quicksand12blackwe400,
                                                    ),
                                                  ],
                                                ),
                                              )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  salonProfileDetails!.userType == 1
                                      ? Languages.of(context)!.gossiperText
                                      : Languages.of(
                                        context,
                                      )!.beautybusinessText,
                                  style: Pallete.Quicksand16drkBlackbold,
                                ),
                              ),
                            ),
                            salonProfileDetails!.userType == 1
                                ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Text(
                                    salonProfileDetails!.userType == 1
                                        ? "${salonProfileDetails!.firstName!} ${salonProfileDetails!.lastName!}"
                                        : salonProfileDetails!.salonName!,
                                    style: Pallete.Quicksand14Blackw500,
                                  ),
                                )
                                : Container(),
                            salonProfileDetails!.userType == 1
                                ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    salonProfileDetails!.email!.isNotEmpty
                                        ? salonProfileDetails!.email!
                                        : "",
                                    style: Pallete.Quicksand14drktxtBluewe500,
                                  ),
                                )
                                : Container(),
                          ],
                        ),
                        Column(
                          children: [
                            salonProfileDetails!.userType == 2
                                ? salonProfileDetails!.salonName != ""
                                    ? Container(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        salonProfileDetails!.salonName!,
                                        style: Pallete
                                            .Quicksand14drktxtGreywe500.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                    : Container()
                                : Container(),
                            const SizedBox(height: 2),
                            salonProfileDetails!.bio != ""
                                ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    textAlign: TextAlign.start,
                                    salonProfileDetails!.bio != ""
                                        ? salonProfileDetails!.bio!
                                        : "",
                                    style: Pallete
                                        .Quicksand14drktxtGreywe500.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                                : Container(),
                            // const SizedBox(height: 2),
                            salonProfileDetails!.userType == 2
                                ? salonOpenDays.isNotEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: _showHoursUI(),
                                      // child: ListView.builder(
                                      //   itemCount: salonOpenDays.length,
                                      //   shrinkWrap: true,
                                      //   padding: EdgeInsets.zero,
                                      //   physics:
                                      //       const NeverScrollableScrollPhysics(),
                                      //   itemBuilder: (context, index) {
                                      //     return Row(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.start,
                                      //       children: [
                                      //         Text(
                                      //           salonOpenDays[index].open!,
                                      //           style: Pallete
                                      //               .Quicksand12blackwe400.copyWith(
                                      //             color: Colors.black,
                                      //           ),
                                      //         ),
                                      //         const SizedBox(width: 5),
                                      //         Text(
                                      //           formatTime(
                                      //             salonOpenDays[index]
                                      //                 .startTime!,
                                      //           ),
                                      //           style: Pallete
                                      //               .Quicksand12blackwe400.copyWith(
                                      //             color: Colors.black,
                                      //           ),
                                      //         ),
                                      //         const SizedBox(width: 5),
                                      //         Text(
                                      //           Languages.of(context)!.toText,
                                      //           style: Pallete
                                      //               .Quicksand12blackwe400.copyWith(
                                      //             color: Colors.black,
                                      //           ),
                                      //         ),
                                      //         const SizedBox(width: 5),
                                      //         Text(
                                      //           formatTime(
                                      //             salonOpenDays[index].endTime!,
                                      //           ),
                                      //           style: Pallete
                                      //               .Quicksand12blackwe400.copyWith(
                                      //             color: Colors.black,
                                      //           ),
                                      //         ),
                                      //         const SizedBox(width: 10),
                                      //       ],
                                      //     );
                                      //   },
                                      // ),
                                    )
                                    : Container()
                                : Container(),
                            // const SizedBox(height: 2),
                            salonProfileDetails!.userType == 2
                                ? salonProfileDetails!.contactNo != ""
                                    ? GestureDetector(
                                      onTap: () async {
                                        final phoneNumber =
                                            salonProfileDetails!.contactNo!;
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: phoneNumber,
                                        );
                                        if (await canLaunchUrl(launchUri)) {
                                          await launchUrl(launchUri);
                                        } else {
                                          throw 'Could not launch $phoneNumber';
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                        ),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          salonProfileDetails!.contactNo!,
                                          style: Pallete
                                              .Quicksand14drktxtGreywe500.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container()
                                : Container(),
                            const SizedBox(height: 2),
                            salonProfileDetails!.userType == 2
                                ? salonProfileDetails!.siteName != ""
                                    ? GestureDetector(
                                      onTap: () async {
                                        String siteUrl =
                                            salonProfileDetails!.siteName ?? "";
                                        // Ensure the URL has a scheme
                                        if (!siteUrl.startsWith("http://") &&
                                            !siteUrl.startsWith("https://")) {
                                          siteUrl = "https://$siteUrl";
                                        }

                                        final Uri url = Uri.parse(siteUrl);

                                        print("Launching: $url");

                                        if (!await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        )) {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                        ),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          salonProfileDetails!.siteName!,
                                          style: Pallete
                                              .Quicksand14drktxtGreywe500.copyWith(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container()
                                : Container(),
                            const SizedBox(height: 2),
                            salonProfileDetails!.userType == 2
                                ? salonProfileDetails!.address != ""
                                    ? Container(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        salonProfileDetails!.address!,
                                        style: Pallete
                                            .Quicksand14drktxtGreywe500.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                    : Container()
                                : Container(),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Padding(
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
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 50,
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            labelColor: AppColors.kBlackColor,
                            overlayColor: const MaterialStatePropertyAll(
                              AppColors.kAppBArBGColor,
                            ),
                            unselectedLabelColor: AppColors.kBlueColor,
                            indicatorColor: AppColors.kPinkColor,
                            indicatorSize: TabBarIndicatorSize.tab,
                            onTap: (value) {
                              setState(() {
                                currentindex = value;
                              });
                              if (Platform.isIOS) {
                                if (value == 1) {
                                  Future.delayed(
                                    const Duration(seconds: 5),
                                    () {
                                      print("Future.delayed");
                                      _videogridviewController.animateTo(
                                        1.0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.bounceIn,
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            tabs: [
                              Tab(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Image.asset(
                                    ImageUtils.gridicon,
                                    color:
                                        currentindex == 0
                                            ? AppColors.kPinkColor
                                            : AppColors.kBlackColor,
                                  ),
                                ),
                              ),
                              Tab(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Image.asset(
                                    ImageUtils.videoicon,
                                    color:
                                        currentindex == 1
                                            ? AppColors.kPinkColor
                                            : AppColors.kBlackColor,
                                  ),
                                ),
                              ),
                              Tab(
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset(
                                    "lib/assets/images/tag Background Removed.png",
                                    color:
                                        currentindex == 2
                                            ? AppColors.kPinkColor
                                            : AppColors.kBlackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: kSize.height / 2,
                          width: kSize.width,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              salonProfilePostArray.isNotEmpty
                                  ? salonProfileDetails!.userType == 1
                                      ? GridView.builder(
                                        controller: _scrollController,
                                        itemCount: salonProfilePostArray.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 0.85,
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
                                                            salonProfilePostArray,
                                                        selectedLessonIndex:
                                                            index,
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
                                                salonProfilePostArray[index]
                                                            .beforeImage !=
                                                        ""
                                                    ? Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Container(
                                                          height: kSize.height,
                                                          width: kSize.width,
                                                          margin:
                                                              const EdgeInsets.all(
                                                                3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  AppColors
                                                                      .kTextFieldBorderColor,
                                                            ),
                                                            color: Colors.white,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            child: Image.network(
                                                              fit: BoxFit.cover,
                                                              "${API.baseUrl}/api/${salonProfilePostArray[index].afterImage}",
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Image.asset(
                                                                  ImageUtils
                                                                      .profileLogo,
                                                                );
                                                              },
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
                                                                          AppColors
                                                                              .kBlackColor,
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
                                                        salonProfilePostArray[index]
                                                                .otherMultiPost!
                                                                .isNotEmpty
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
                                                                      color: Colors
                                                                          .black12
                                                                          .withOpacity(
                                                                            0.2,
                                                                          ),
                                                                      blurRadius:
                                                                          4,
                                                                      offset:
                                                                          const Offset(
                                                                            0,
                                                                            0.3,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Image.asset(
                                                                  "lib/assets/images/multipost.png",
                                                                  height: 22,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            )
                                                            : Container(),
                                                      ],
                                                    )
                                                    : Container(
                                                      height: kSize.height,
                                                      width: kSize.width,
                                                      margin:
                                                          const EdgeInsets.all(
                                                            3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color:
                                                              AppColors
                                                                  .kTextFieldBorderColor,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        child:
                                                            showotherimg[index]['f_img']
                                                                        .endsWith(
                                                                          ".mp4",
                                                                        ) ||
                                                                    showotherimg[index]['f_img']
                                                                        .endsWith(
                                                                          ".mov",
                                                                        ) ||
                                                                    showotherimg[index]['f_img']
                                                                        .endsWith(
                                                                          ".MP4",
                                                                        )
                                                                ? Stack(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          kSize
                                                                              .height,
                                                                      width:
                                                                          kSize
                                                                              .width,
                                                                      child: ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              5,
                                                                            ),
                                                                        child: Tagvideothumbnail(
                                                                          videoUrl:
                                                                              showotherimg[index]['f_img'],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .play_arrow_rounded,
                                                                        size:
                                                                            50,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                                : Image.network(
                                                                  showotherimg[index]['f_img'],
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  loadingBuilder: (
                                                                    BuildContext
                                                                    context,
                                                                    Widget
                                                                    child,
                                                                    ImageChunkEvent?
                                                                    loadingProgress,
                                                                  ) {
                                                                    if (loadingProgress ==
                                                                        null)
                                                                      return child;
                                                                    return SizedBox(
                                                                      height:
                                                                          100,
                                                                      width:
                                                                          100,
                                                                      child: Center(
                                                                        child: CircularProgressIndicator(
                                                                          color:
                                                                              AppColors.kBlackColor,
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
                                          );
                                        },
                                      )
                                      : GridView.builder(
                                        controller: _scrollController,
                                        itemCount: showotherimg.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 0.85,
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
                                                            salonProfilePostArray,
                                                        selectedLessonIndex:
                                                            index,
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
                                                    ? Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Container(
                                                          height: kSize.height,
                                                          width: kSize.width,
                                                          margin:
                                                              const EdgeInsets.all(
                                                                3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color:
                                                                  AppColors
                                                                      .kTextFieldBorderColor,
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            child:
                                                                showotherimg[index]['f_img'].endsWith(
                                                                          ".mp4",
                                                                        ) ||
                                                                        showotherimg[index]['f_img'].endsWith(
                                                                          ".mov",
                                                                        ) ||
                                                                        showotherimg[index]['f_img'].endsWith(
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
                                                                            borderRadius: BorderRadius.circular(
                                                                              5,
                                                                            ),
                                                                            child: Tagvideothumbnail(
                                                                              videoUrl:
                                                                                  showotherimg[index]['f_img'],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Center(
                                                                          child: Icon(
                                                                            Icons.play_arrow_rounded,
                                                                            size:
                                                                                50,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                    : Image.network(
                                                                      showotherimg[index]['f_img'],
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                      loadingBuilder: (
                                                                        BuildContext
                                                                        context,
                                                                        Widget
                                                                        child,
                                                                        ImageChunkEvent?
                                                                        loadingProgress,
                                                                      ) {
                                                                        if (loadingProgress ==
                                                                            null)
                                                                          return child;
                                                                        return SizedBox(
                                                                          height:
                                                                              100,
                                                                          width:
                                                                              100,
                                                                          child: Center(
                                                                            child: CircularProgressIndicator(
                                                                              color:
                                                                                  AppColors.kBlackColor,
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
                                                        showotherimg[index]['otherpostlen']! >
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
                                                                      color: Colors
                                                                          .black12
                                                                          .withOpacity(
                                                                            0.2,
                                                                          ),
                                                                      blurRadius:
                                                                          4,
                                                                      offset:
                                                                          const Offset(
                                                                            0,
                                                                            0.3,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Image.asset(
                                                                  "lib/assets/images/multipost.png",
                                                                  height: 22,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            )
                                                            : Container(),
                                                      ],
                                                    )
                                                    : Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                      child: const Icon(
                                                        Icons.person,
                                                      ),
                                                    ),
                                          );
                                        },
                                      )
                                  : Center(
                                    child: Text(
                                      Languages.of(
                                        context,
                                      )!.NopostavailableText,
                                      style: Pallete.Quicksand16drkBlackBold,
                                    ),
                                  ),
                              videoList.isNotEmpty
                                  ? GridView.builder(
                                    controller: _videogridviewController,
                                    itemCount: videoList.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 0.75,
                                        ),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      _videoPlayercontroller[index] =
                                          VideoPlayerController.networkUrl(
                                            Uri.parse(videoList[index]),
                                          );
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(3),
                                        overlayColor: MaterialStatePropertyAll(
                                          Colors.black.withAlpha(10),
                                        ),
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
                                          setState(() {});
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child:
                                              _videoPlayercontroller.isNotEmpty
                                                  ? FutureBuilder(
                                                    future:
                                                        _videoPlayercontroller[index]
                                                            .initialize(),
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return Stack(
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
                                                                child: AspectRatio(
                                                                  aspectRatio:
                                                                      _videoPlayercontroller[index]
                                                                          .value
                                                                          .aspectRatio,
                                                                  child: VideoPlayer(
                                                                    _videoPlayercontroller[index],
                                                                  ),
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
                                                        );
                                                      } else {
                                                        return Shimmer.fromColors(
                                                          baseColor:
                                                              Colors
                                                                  .grey
                                                                  .shade200,
                                                          highlightColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          enabled: true,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            height:
                                                                kSize.height,
                                                            width: kSize.width,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  )
                                                  : Container(
                                                    color: Colors.white,
                                                  ),
                                        ),
                                      );
                                    },
                                  )
                                  : Center(
                                    child: Text(
                                      Languages.of(
                                        context,
                                      )!.NovideoavailableText,
                                      style: Pallete.Quicksand16drkBlackBold,
                                    ),
                                  ),
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
                                                                      AppColors
                                                                          .kBlackColor,
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
                                                                      AppColors
                                                                          .kBlackColor,
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
                                        style: Pallete.Quicksand20drkBlackBold,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        Languages.of(
                                          context,
                                        )!.emptytaglisttitleText,
                                        textAlign: TextAlign.center,
                                        style: Pallete.Quicksand15blackwe300,
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
              backgroundColor: AppColors.kWhiteColor,
              title: Text(Languages.of(context)!.LogoutText),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.logouttiletText,
                style: Pallete.Quicksand15blackwe600,
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
                                style: Pallete.Quicksand15blackwe300,
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
                                style: Pallete.Quicksand15blackwe300,
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
              backgroundColor: AppColors.kWhiteColor,
              title: Text(Languages.of(context)!.deleteaccountText),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.deleteaccountmsgText,
                style: Pallete.Quicksand15blackwe600,
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
                                style: Pallete.Quicksand15blackwe300,
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
                                style: Pallete.Quicksand15blackwe300,
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
        ).getSalonDetails(userid, userid, offsett, userTyppe);
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
                if (element.otherMultiPost!.isNotEmpty) {
                  String fileExtension = getFileExtension(
                    element.otherMultiPost!.first.otherData!,
                  );

                  if (fileExtension == ".jpg" ||
                      fileExtension == ".mp4" ||
                      fileExtension == ".mov" ||
                      fileExtension == ".MP4") {
                    if (element.afterImage == "" && element.beforeImage == "") {
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
                    "otherpostlen": 0,
                  });
                }
                if (model.userProfile!.userType == 2 &&
                    element.afterImage != "" &&
                    element.beforeImage != "") {
                  showotherimg.add({
                    "f_img": "${API.baseUrl}/api/${element.afterImage}",
                    "otherpostlen": 0,
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
      // height: 35,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: MediaQuery.of(context).size.width,
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
                Text(
                  _showHours
                      ? Languages.of(context)!.hideStoreHours
                      : Languages.of(context)!.viewStorehours,
                  style: Pallete.Quicksand16drkBlackBold.copyWith(
                    // color: Colors.blue, // clickable look
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(
                  _showHours
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
          if (_showHours) Divider(),
          if (_showHours)
            ListView.builder(
              itemCount: salonOpenDays.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salonOpenDays[index].open!,
                      style: Pallete.Quicksand12blackwe400.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatTime(salonOpenDays[index].startTime!),
                      style: Pallete.Quicksand12blackwe400.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      Languages.of(context)!.toText,
                      style: Pallete.Quicksand12blackwe400.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatTime(salonOpenDays[index].endTime!),
                      style: Pallete.Quicksand12blackwe400.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
