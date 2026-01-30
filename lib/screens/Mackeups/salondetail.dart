// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_function_literals_in_foreach_calls, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/screens/AddPost/ShareSaloonReview.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/Mackeups/tagvideothumbnail.dart';
import 'package:pinkGossip/screens/Message/messagedetail.dart';
import 'package:pinkGossip/screens/Profile/beautybusinessmap.dart';
import 'package:pinkGossip/screens/Profile/editprofile.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/screens/allfollowingorfollowers.dart';
import 'package:pinkGossip/screens/showpostvideo.dart';
import 'package:pinkGossip/screens/tagpostview.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/models/followingmodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/unfollwmodel.dart';
import 'package:pinkGossip/screens/showpostimage.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/viewModels/followingviewmodel.dart';
import 'package:pinkGossip/viewModels/salondetailsviewmodel.dart';
import 'package:pinkGossip/viewModels/unfollwviewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../utils/pallete.dart';
import 'package:intl/intl.dart';

class SalonDetailScreen extends StatefulWidget {
  final String id, userType, pageType;
  const SalonDetailScreen({
    super.key,
    required this.id,
    required this.userType,
    this.pageType = '',
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen>
    with TickerProviderStateMixin {
  List<Post> salonPostArray = [];
  List<Post> tempprofilePostAray = [];

  List<StoryUserDetails>? getDetailsStories;

  List<String> videoList = [];
  List<Stories> myStoryArray = [];

  UserProfile? salonDetails;

  List<SalonOpenDay> salonOpenDays = [];
  bool _showHours = false;

  SharedPreferences? prefs;
  String userid = "";
  String userTyppe = "";
  String firebaseID = "";

  int totalPoints = 0;
  int postCountsReeview = 0;

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    firebaseID = prefs!.getString('FirebaseId')!;
    print("userid   ${userid}");
    print("widget.userType   ${widget.userType}");
  }

  bool isLoading = false;
  int selectindex = 0;
  late final TabController _tabController;

  final ScrollController _scrollController = ScrollController();

  late List<VideoPlayerController> _videoPlayercontroller;
  late ScrollController _videogridviewController;

  late VideoPlayerController _tagVideoController;
  @override
  void initState() {
    super.initState();
    getuserid();

    // _scrollController.addListener(_loadMoreData);
    getStory();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animation!.addListener(_handleTabChange);
    getSalonDetails(widget.id, widget.userType);
    // 🔥 SHOW ALERT ONLY FOR DEEP LINK
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageType == 'deepLink') {
        // if (1 == 1) {
        _showDeepLinkWelcomeDialog();
      }
    });
    for (int i = 0; i < videoList.length; i++) {
      _videoPlayercontroller[i] = VideoPlayerController.networkUrl(
        Uri.parse(videoList[i]),
      );
      _videoPlayercontroller[i].initialize();
    }

    _videogridviewController = ScrollController();
  }

  var totlepostcount = 10;
  int offsett = 0;

  // void _loadMoreData() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     print("totlepostcount =${totlepostcount}");
  //     if (offsett > totlepostcount) {
  //       print("iffff");
  //       return;
  //     } else {
  //       print("elssee");
  //       getSalonDetails(widget.id, widget.userType);
  //     }
  //   }
  // }

  String formatTime(String time) {
    final DateFormat inputFormat = DateFormat("HH:mm:ss");
    final DateTime parsedTime = inputFormat.parse(time);
    final DateFormat outputFormat = DateFormat("hh:mm");
    return outputFormat.format(parsedTime);
  }

  List<TagPost>? tagPostList;

  int currentindex = 0;
  List<Map> showotherimg = [];

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
    for (VideoPlayerController controller in _videoPlayercontroller) {
      controller.dispose();
    }
    _tabController.dispose();
    _scrollController.dispose();
    _videogridviewController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
                Navigator.pop(context); // Later
              },
              child: Text(
                "Later",
                style: Pallete.Quicksand14drktxtGreywe500.copyWith(
                  color: AppColors.kBlackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPinkColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SharesaloonreviewPage(id: widget.id),
                  ),
                );

                // Navigator.pop(context);

                // 👉 Navigate to Start action (example)
                // Navigator.push(context,
                //   MaterialPageRoute(builder: (_) => AddStory(type: "Home")));
              },
              child: Text(
                "Start",
                style: Pallete.Quicksand14drktxtGreywe500.copyWith(
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

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.kWhiteColor,
        appBar:
            salonDetails != null
                ? AppBar(
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: AppColors.kAppBArBGColor,
                  automaticallyImplyLeading: false,
                  elevation: 2.0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            overlayColor: const MaterialStatePropertyAll(
                              AppColors.kWhiteColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.asset(ImageUtils.leftarrow),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            salonDetails!.userType == 1
                                ? salonDetails!.userName!.isNotEmpty
                                    ? salonDetails!.userName!
                                    : "${salonDetails!.firstName!} ${salonDetails!.lastName!}"
                                : salonDetails!.salonName!,
                            style: Pallete.Quicksand16drkBlackbold,
                          ),
                        ],
                      ),
                      const Spacer(),
                      salonDetails!.userType == 2
                          ? (salonDetails!.address == null ||
                                  salonDetails!.address!.isEmpty)
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
                                              lat: salonDetails!.latitude!,
                                              long: salonDetails!.longitude!,
                                              salonname:
                                                  salonDetails!.salonName!,
                                              opendays: salonDetails!.openDays!,
                                              id: salonDetails!.id!.toString(),
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
                      const SizedBox(width: 10),
                      widget.id != userid
                          ? Container()
                          : SizedBox(
                            height: 25,
                            width: 25,
                            child: Image.asset(ImageUtils.listicon),
                          ),
                    ],
                  ),
                )
                : AppBar(automaticallyImplyLeading: false),
        body: Stack(
          children: [
            salonDetails != null
                ? SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                salonDetails!.profileImage != ""
                                    ? GestureDetector(
                                      onLongPress: () {
                                        showProfilVeiew(context);
                                        print(
                                          "getDetailsStories = ${getDetailsStories!.length}",
                                        );
                                      },
                                      onTap: () {
                                        if (getDetailsStories!.isNotEmpty) {
                                          if (firebaseID ==
                                              salonDetails!.firebaseId!) {
                                            print("is matchedd");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => MyStoryView(
                                                      myStorysArray:
                                                          myStoryArray,
                                                      firstname:
                                                          salonDetails!
                                                              .firstName ??
                                                          "",
                                                      lastname:
                                                          salonDetails!
                                                              .lastName ??
                                                          "",
                                                      img:
                                                          salonDetails!
                                                              .profileImage ??
                                                          "",
                                                      salonanme:
                                                          salonDetails!
                                                              .salonName ??
                                                          "",
                                                    ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => SingleUserStoryView(
                                                      storyUserDetailsData:
                                                          getDetailsStories,
                                                      myFireabseiD: firebaseID,
                                                      firstname:
                                                          salonDetails!
                                                              .firstName!,
                                                      lastname:
                                                          salonDetails!
                                                              .lastName!,
                                                      profileimage:
                                                          "${API.baseUrl}/api/${salonDetails!.profileImage!}",
                                                      salonname:
                                                          salonDetails!
                                                              .salonName!,
                                                      type: "Details",
                                                    ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 83,
                                            width: 83,
                                            decoration:
                                                getDetailsStories!.isNotEmpty
                                                    ? const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors.kPinkColor,
                                                          AppColors.kPinkColor,
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
                                            padding: const EdgeInsets.all(3.0),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage: NetworkImage(
                                                "${API.baseUrl}/api/${salonDetails!.profileImage!}",
                                              ),
                                            ),
                                          ),
                                          widget.id == userid
                                              ? Positioned(
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          13,
                                                        ),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
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
                                                            const begin =
                                                                Offset(
                                                                  -1.0,
                                                                  0.0,
                                                                );
                                                            const end = Offset(
                                                              0.0,
                                                              0.0,
                                                            );
                                                            const curve =
                                                                Curves
                                                                    .easeInOut;

                                                            var tween = Tween(
                                                              begin: begin,
                                                              end: end,
                                                            ).chain(
                                                              CurveTween(
                                                                curve: curve,
                                                              ),
                                                            );
                                                            var offsetAnimation =
                                                                animation.drive(
                                                                  tween,
                                                                );
                                                            return SlideTransition(
                                                              position:
                                                                  offsetAnimation,
                                                              child: child,
                                                            );
                                                          },
                                                        ),
                                                      ).then((value) {
                                                        getStory();
                                                      });
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          13,
                                                        ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 16.0,
                                                      color:
                                                          AppColors.kWhiteColor,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                    : InkWell(
                                      onTap: () {
                                        if (getDetailsStories!.isNotEmpty) {
                                          if (firebaseID ==
                                              salonDetails!.firebaseId!) {
                                            // print("is matchedd");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => MyStoryView(
                                                      myStorysArray:
                                                          myStoryArray,
                                                      firstname:
                                                          salonDetails!
                                                              .firstName ??
                                                          "",
                                                      lastname:
                                                          salonDetails!
                                                              .lastName ??
                                                          "",
                                                      img:
                                                          salonDetails!
                                                              .profileImage ??
                                                          "",
                                                      salonanme:
                                                          salonDetails!
                                                              .salonName ??
                                                          "",
                                                    ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => SingleUserStoryView(
                                                      storyUserDetailsData:
                                                          getDetailsStories,
                                                      myFireabseiD: firebaseID,
                                                      firstname:
                                                          salonDetails!
                                                              .firstName!,
                                                      lastname:
                                                          salonDetails!
                                                              .lastName!,
                                                      profileimage:
                                                          "${API.baseUrl}/api/${salonDetails!.profileImage!}",
                                                      salonname:
                                                          salonDetails!
                                                              .salonName!,
                                                      type: "Details",
                                                    ),
                                              ),
                                            );
                                          }
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
                                                      AppColors.kPinkColor,
                                                      AppColors.kPinkColor,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                )
                                                : const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                        padding: const EdgeInsets.all(3.0),
                                        child: CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.grey[300],
                                          child: const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                const SizedBox(width: 20),
                                Expanded(
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
                                                  salonDetails!.userType == 1
                                                      ? totalPoints.toString()
                                                      : postCountsReeview
                                                          .toString(),
                                                  // totalPoints.toString(),
                                                  style:
                                                      Pallete
                                                          .Quicksand16drkBlackBold,
                                                ),
                                                Text(
                                                  salonDetails!.userType == 1
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
                                                              salonDetails!.id!,
                                                          name:
                                                              salonDetails!
                                                                          .userType ==
                                                                      1
                                                                  ? "${salonDetails!.firstName} ${salonDetails!.lastName}"
                                                                  : salonDetails!
                                                                      .salonName!,
                                                          type: "follower",
                                                          totlefollowing:
                                                              salonDetails!
                                                                  .followingCount!,
                                                          totlefollowers:
                                                              salonDetails!
                                                                  .followersCount!,
                                                          usertype:
                                                              salonDetails!
                                                                          .id ==
                                                                      int.parse(
                                                                        userid,
                                                                      )
                                                                  ? "profile"
                                                                  : "salondetail",
                                                          navigationType:
                                                              "salondetail",
                                                        ),
                                                  ),
                                                ).then((value) {
                                                  setState(() {
                                                    salonPostArray.clear();
                                                    showotherimg.clear();
                                                  });
                                                  getSalonDetails(
                                                    widget.id,
                                                    widget.userType,
                                                  );
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    salonDetails!
                                                                .followersCount !=
                                                            null
                                                        ? salonDetails!
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
                                                              salonDetails!.id!,
                                                          name:
                                                              salonDetails!
                                                                          .userType ==
                                                                      1
                                                                  ? "${salonDetails!.firstName} ${salonDetails!.lastName}"
                                                                  : salonDetails!
                                                                      .salonName!,
                                                          type: "following",
                                                          totlefollowing:
                                                              salonDetails!
                                                                  .followingCount!,
                                                          totlefollowers:
                                                              salonDetails!
                                                                  .followersCount!,
                                                          usertype:
                                                              salonDetails!
                                                                          .id ==
                                                                      int.parse(
                                                                        userid,
                                                                      )
                                                                  ? "profile"
                                                                  : "salondetail",
                                                          navigationType:
                                                              "salondetail",
                                                        ),
                                                  ),
                                                ).then((value) {
                                                  setState(() {
                                                    salonPostArray.clear();
                                                    showotherimg.clear();
                                                  });
                                                  print(
                                                    "salonPostArray.length ${salonPostArray.length}",
                                                  );
                                                  getSalonDetails(
                                                    widget.id,
                                                    widget.userType,
                                                  );
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    salonDetails!
                                                                .followingCount !=
                                                            null
                                                        ? salonDetails!
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
                                      salonDetails!.userType == 2
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // const SizedBox(width: 25),
                                              Text(
                                                double.parse(
                                                  salonDetails!.averageRating!,
                                                ).toStringAsFixed(1),
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe400,
                                              ),
                                              const SizedBox(width: 4),
                                              RatingBarIndicator(
                                                rating: double.parse(
                                                  salonDetails!.averageRating
                                                      .toString(),
                                                ),
                                                itemCount: 5,
                                                itemSize: 18.0,
                                                unratedColor:
                                                    AppColors.klightGreyColor,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder:
                                                    (context, _) => const Icon(
                                                      Icons.star,
                                                      color:
                                                          AppColors.kPinkColor,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "(${salonDetails!.ratingCount.toString()})",
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe400,
                                              ),
                                            ],
                                          )
                                          : Container(),
                                    ],
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
                          salonDetails!.userType == 2
                              ? salonDetails!.salonName != ""
                                  ? Container(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      salonDetails!.salonName!,
                                      style: Pallete.Quicksand16drkBlackbold,
                                    ),
                                  )
                                  : Container()
                              : Container(),
                          salonDetails!.userType == 1
                              ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                child: Text(
                                  salonDetails!.userType == 1
                                      ? "${salonDetails!.firstName!} ${salonDetails!.lastName!}"
                                      : salonDetails!.salonName!,
                                  style: Pallete.Quicksand16drkBlackbold,
                                ),
                              )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                salonDetails!.userType == 1
                                    ? Languages.of(context)!.gossiperText
                                    : Languages.of(context)!.beautybusinessText,
                                style: Pallete.Quicksand14Blackw500,
                              ),
                            ),
                          ),

                          salonDetails!.emailVisibility == true
                              ? Container(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  salonDetails!.email!.isNotEmpty
                                      ? salonDetails!.email!
                                      : "",
                                  style: Pallete.Quicksand14drktxtBluewe500,
                                ),
                              )
                              : Container(),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 2),
                          salonDetails!.bio != ""
                              ? Container(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  textAlign: TextAlign.start,
                                  salonDetails!.bio != ""
                                      ? salonDetails!.bio!
                                      : "",
                                  style: Pallete
                                      .Quicksand14drktxtGreywe500.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                              : Container(),
                          salonDetails!.userType == 2
                              ? salonOpenDays.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: _showHoursUI(),
                                    // child: ListView.builder(
                                    //   itemCount: salonOpenDays.length,
                                    //   padding: EdgeInsets.zero,
                                    //   shrinkWrap: true,
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
                                    //             salonOpenDays[index].startTime!,
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
                          const SizedBox(height: 2),
                          salonDetails!.userType == 2
                              ? salonDetails!.contactNo != ""
                                  ? GestureDetector(
                                    onTap: () async {
                                      final phoneNumber =
                                          salonDetails!.contactNo!;
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
                                        salonDetails!.contactNo!,
                                        style: Pallete
                                            .Quicksand14drktxtGreywe500.copyWith(
                                          color: Colors.black,
                                          // decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container()
                              : Container(),
                          const SizedBox(height: 2),
                          salonDetails!.userType == 2
                              ? salonDetails!.siteName != ""
                                  ? GestureDetector(
                                    onTap: () async {
                                      String siteUrl =
                                          salonDetails!.siteName ?? "";
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
                                        salonDetails!.siteName!,
                                        style: Pallete
                                            .Quicksand14drktxtGreywe500.copyWith(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container()
                              : Container(),
                          const SizedBox(height: 2),
                          salonDetails!.userType == 2
                              ? salonDetails!.address != ""
                                  ? Container(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      salonDetails!.address!,
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
                      widget.id == userid
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
                                            salonDetails!.firstName ?? "",
                                        "username":
                                            salonDetails!.userName ?? "",
                                        "lastname":
                                            salonDetails!.lastName ?? "",
                                        "email": salonDetails!.email ?? "",
                                        "usertype":
                                            salonDetails!.userType ?? "",
                                        "contact":
                                            salonDetails!.contactNo ?? "",
                                        "address": salonDetails!.address ?? "",
                                        "salonname":
                                            salonDetails!.salonName ?? "",
                                        "opendays":
                                            salonDetails!.openDays ?? "",
                                        "opentime":
                                            salonDetails!.openTime ?? "",
                                        "bio": salonDetails!.bio ?? "",
                                        "profileImage":
                                            salonDetails!.profileImage ?? "",
                                      };
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditProfileScreen(
                                                userData: userData,
                                                latitude:
                                                    salonDetails!.latitude !=
                                                            null
                                                        ? salonDetails!
                                                            .latitude!
                                                        : "",
                                                longitude:
                                                    salonDetails!.longitude !=
                                                            null
                                                        ? salonDetails!
                                                            .longitude!
                                                        : "",
                                                getsalonOpenDays: [],
                                                // latitude:
                                                //     salonDetails!.latitude!,
                                                // longitude:
                                                //     salonDetails!.longitude!,
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
                                          Languages.of(
                                            context,
                                          )!.editProfileText,
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
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                salonDetails!.isFollowed == 0
                                    ? Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          userFollowing(userid, widget.id, "0");
                                        },
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: AppColors.btnColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              Languages.of(context)!.followText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          userUnfollow(userid, widget.id);
                                        },
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: AppColors.btnColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              Languages.of(
                                                context,
                                              )!.followingText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: AppColors.btnColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        print("firebaseID = ${firebaseID}");

                                        // DatabaseReference userRef =
                                        //     FirebaseDatabase.instance
                                        //         .reference()
                                        //         .child('message');

                                        // var channelKey =
                                        //     'chat-${firebaseID}--${salonDetails!.firebaseId!}';

                                        // var channel2Key =
                                        //     'chat-${salonDetails!.firebaseId!}--${firebaseID}';

                                        // DatabaseEvent channelSnapshot =
                                        //     await userRef
                                        //         .child(channelKey)
                                        //         .once();

                                        // DatabaseEvent channel2Snapshot =
                                        //     await userRef
                                        //         .child(channel2Key)
                                        //         .once();

                                        // if (!channelSnapshot
                                        //         .snapshot.exists &&
                                        //     !channel2Snapshot
                                        //         .snapshot.exists) {
                                        //   var timestamp =
                                        //       DateTime.timestamp();

                                        //   DatabaseReference messagesRef = userRef
                                        //       .child(
                                        //           'chat-${firebaseID}--${salonDetails!.firebaseId!}')
                                        //       .child(timestamp
                                        //           .millisecondsSinceEpoch
                                        //           .toString());

                                        //   await messagesRef.set({
                                        //     'idFrom': firebaseID,
                                        //     'idTo':
                                        //         salonDetails!.firebaseId,
                                        //     'isSeen': false,
                                        //     'content': "hello",
                                        //     'timestamp': timestamp
                                        //         .millisecondsSinceEpoch,
                                        //   });
                                        // } else {
                                        //   print("already channel created");
                                        // }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => MessageDetail(
                                                  oppId:
                                                      salonDetails!.firebaseId!
                                                          .toString(),
                                                  firebaseUId: firebaseID,
                                                  name:
                                                      "${salonDetails!.firstName}${salonDetails!.lastName}",
                                                  userImg:
                                                      salonDetails!
                                                          .profileImage!,
                                                  type: "fromdetail",
                                                ),
                                          ),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          Languages.of(context)!.messageText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        child: TabBar(
                          labelColor: AppColors.kBlackColor,
                          overlayColor: const MaterialStatePropertyAll(
                            AppColors.kAppBArBGColor,
                          ),
                          unselectedLabelColor: AppColors.kBlueColor,
                          indicatorColor: AppColors.kPinkColor,
                          indicatorSize: TabBarIndicatorSize.tab,
                          controller: _tabController,
                          onTap: (value) async {
                            setState(() {
                              currentindex = value;
                            });
                            if (Platform.isIOS) {
                              if (value == 1) {
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

                            if (value == 2) {
                              await _tagVideoController.initialize();
                              setState(() {});
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
                            //   salonPostArray.isNotEmpty
                            // ? salonDetails!.userType == 1
                            //     ?
                            GridView.builder(
                              controller: _scrollController,
                              itemCount: salonPostArray.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                  ),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ShowPostImage(
                                              postData: salonPostArray,
                                              selectedLessonIndex: index,
                                              usertype:
                                                  salonDetails!.userType
                                                      .toString(),
                                              isProfile: widget.id == userid,
                                              type: "Details",
                                              otherstories: getDetailsStories,
                                            ),
                                      ),
                                    );
                                  },
                                  child:
                                      salonPostArray[index].afterImage != ""
                                          ? Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color:
                                                        AppColors
                                                            .kTextFieldBorderColor,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Image.network(
                                                    "${API.baseUrl}/api/${salonPostArray[index].afterImage}",
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      ImageChunkEvent?
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null)
                                                        return child;
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          color:
                                                              AppColors
                                                                  .kBlackColor,
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
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              salonPostArray[index]
                                                      .otherMultiPost!
                                                      .isNotEmpty
                                                  ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                          right: 8,
                                                        ),
                                                    child: Image.asset(
                                                      "lib/assets/images/multipost.png",
                                                      height: 22,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                  : Container(),
                                            ],
                                          )
                                          : Container(
                                            margin: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color:
                                                    AppColors
                                                        .kTextFieldBorderColor,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                                              .endsWith(".MP4")
                                                      ? Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          /// 🎥 VIDEO THUMBNAIL (FULL SIZE, NO STRETCH)
                                                          Positioned.fill(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              child: FittedBox(
                                                                fit:
                                                                    BoxFit
                                                                        .cover, // ✅ full cover, no stretch
                                                                child: SizedBox(
                                                                  width:
                                                                      kSize
                                                                          .width,
                                                                  height:
                                                                      kSize
                                                                          .height,
                                                                  child: Tagvideothumbnail(
                                                                    videoUrl:
                                                                        showotherimg[index]['f_img'],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          /// ▶ PLAY ICON
                                                          const Icon(
                                                            Icons
                                                                .play_arrow_rounded,
                                                            size: 50,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      )
                                                      : Image.network(
                                                        showotherimg[index]['f_img'],
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (
                                                          BuildContext context,
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
                                );
                              },
                            ),

                            //     : GridView.builder(
                            //       controller: _scrollController,
                            //       itemCount: showotherimg.length,
                            //       gridDelegate:
                            //           const SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 3,
                            //             childAspectRatio: 1,
                            //           ),
                            //       shrinkWrap: true,
                            //       itemBuilder: (context, index) {
                            //         return GestureDetector(
                            //           onTap: () {
                            //             Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                 builder:
                            //                     (context) => ShowPostImage(
                            //                       postData: salonPostArray,
                            //                       selectedLessonIndex:
                            //                           index,
                            //                       usertype:
                            //                           salonDetails!.userType
                            //                               .toString(),
                            //                       isProfile:
                            //                           widget.id == userid,
                            //                       type: "Details",
                            //                       otherstories:
                            //                           getDetailsStories,
                            //                     ),
                            //               ),
                            //             );
                            //           },
                            //           child:
                            //               showotherimg[index] != ""
                            //                   ? Stack(
                            //                     alignment:
                            //                         Alignment.topRight,
                            //                     children: [
                            //                       Container(
                            //                         margin:
                            //                             const EdgeInsets.all(
                            //                               3,
                            //                             ),
                            //                         decoration: BoxDecoration(
                            //                           borderRadius:
                            //                               BorderRadius.circular(
                            //                                 5,
                            //                               ),
                            //                           border: Border.all(
                            //                             color:
                            //                                 AppColors
                            //                                     .kTextFieldBorderColor,
                            //                           ),
                            //                           color: Colors.white,
                            //                         ),
                            //                         child: ClipRRect(
                            //                           borderRadius:
                            //                               BorderRadius.circular(
                            //                                 5,
                            //                               ),
                            //                           child:
                            //                               showotherimg[index]['f_img']
                            //                                           .endsWith(
                            //                                             ".mp4",
                            //                                           ) ||
                            //                                       showotherimg[index]['f_img']
                            //                                           .endsWith(
                            //                                             ".mov",
                            //                                           ) ||
                            //                                       showotherimg[index]['f_img']
                            //                                           .endsWith(
                            //                                             ".MP4",
                            //                                           )
                            //                                   ? Stack(
                            //                                     alignment:
                            //                                         Alignment
                            //                                             .center,
                            //                                     children: [
                            //                                       /// 🎥 VIDEO THUMBNAIL (FULL SIZE, NO STRETCH)
                            //                                       Positioned.fill(
                            //                                         child: ClipRRect(
                            //                                           borderRadius:
                            //                                               BorderRadius.circular(
                            //                                                 5,
                            //                                               ),
                            //                                           child: FittedBox(
                            //                                             fit:
                            //                                                 BoxFit.cover, // ✅ full cover, no stretch
                            //                                             child: SizedBox(
                            //                                               width:
                            //                                                   kSize.width,
                            //                                               height:
                            //                                                   kSize.height,
                            //                                               child: Tagvideothumbnail(
                            //                                                 videoUrl:
                            //                                                     showotherimg[index]['f_img'],
                            //                                               ),
                            //                                             ),
                            //                                           ),
                            //                                         ),
                            //                                       ),

                            //                                       /// ▶ PLAY ICON
                            //                                       const Icon(
                            //                                         Icons
                            //                                             .play_arrow_rounded,
                            //                                         size:
                            //                                             50,
                            //                                         color:
                            //                                             Colors.white,
                            //                                       ),
                            //                                     ],
                            //                                   )
                            //                                   : Image.network(
                            //                                     showotherimg[index]['f_img'],
                            //                                     fit:
                            //                                         BoxFit
                            //                                             .cover,
                            //                                     loadingBuilder: (
                            //                                       BuildContext
                            //                                       context,
                            //                                       Widget
                            //                                       child,
                            //                                       ImageChunkEvent?
                            //                                       loadingProgress,
                            //                                     ) {
                            //                                       if (loadingProgress ==
                            //                                           null)
                            //                                         return child;
                            //                                       return SizedBox(
                            //                                         height:
                            //                                             100,
                            //                                         width:
                            //                                             100,
                            //                                         child: Center(
                            //                                           child: CircularProgressIndicator(
                            //                                             color:
                            //                                                 AppColors.kBlackColor,
                            //                                             value:
                            //                                                 loadingProgress.expectedTotalBytes !=
                            //                                                         null
                            //                                                     ? loadingProgress.cumulativeBytesLoaded /
                            //                                                         loadingProgress.expectedTotalBytes!
                            //                                                     : null,
                            //                                           ),
                            //                                         ),
                            //                                       );
                            //                                     },
                            //                                   ),
                            //                         ),
                            //                       ),
                            //                       showotherimg[index]['otherpostlen']! >
                            //                               1
                            //                           ? Padding(
                            //                             padding:
                            //                                 const EdgeInsets.only(
                            //                                   top: 8,
                            //                                   right: 8,
                            //                                 ),
                            //                             child: Image.asset(
                            //                               "lib/assets/images/multipost.png",
                            //                               height: 22,
                            //                               color:
                            //                                   Colors.white,
                            //                             ),
                            //                           )
                            //                           : Container(),
                            //                     ],
                            //                   )
                            //                   : Container(
                            //                     margin:
                            //                         const EdgeInsets.all(3),
                            //                     decoration: BoxDecoration(
                            //                       borderRadius:
                            //                           BorderRadius.circular(
                            //                             5,
                            //                           ),
                            //                       border: Border.all(
                            //                         color: Colors.grey,
                            //                       ),
                            //                       color: Colors.white,
                            //                     ),
                            //                     child: const Icon(
                            //                       Icons.person,
                            //                     ),
                            //                   ),
                            //         );
                            //       },
                            //     )
                            // : Center(
                            //   child: Text(
                            //     Languages.of(context)!.NopostavailableText,
                            //     style: Pallete.Quicksand16drkBlackBold,
                            //   ),
                            // ),
                            videoList.isNotEmpty
                                ? GridView.builder(
                                  controller: _videogridviewController,
                                  itemCount: videoList.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1, // square grid
                                      ),
                                  itemBuilder: (context, index) {
                                    final controller =
                                        _videoPlayercontroller[index];

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(5),
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
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            /// 🎥 FULL SIZE VIDEO THUMBNAIL (NO STRETCH)
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child:
                                                    controller
                                                            .value
                                                            .isInitialized
                                                        ? FittedBox(
                                                          fit:
                                                              BoxFit
                                                                  .cover, // ✅ full cover, no stretch
                                                          child: SizedBox(
                                                            width:
                                                                controller
                                                                    .value
                                                                    .size
                                                                    .width,
                                                            height:
                                                                controller
                                                                    .value
                                                                    .size
                                                                    .height,
                                                            child: VideoPlayer(
                                                              controller,
                                                            ),
                                                          ),
                                                        )
                                                        : Container(
                                                          color: Colors.black,
                                                        ),
                                              ),
                                            ),

                                            /// ▶ PLAY ICON
                                            const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 45,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Center(
                                  child: Text(
                                    Languages.of(context)!.NovideoavailableText,
                                    style: Pallete.Quicksand16drkBlackBold,
                                  ),
                                ),
                            tagPostList!.isEmpty
                                ? widget.id == userid
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)!.postofyouText,
                                          style:
                                              Pallete.Quicksand20drkBlackBold,
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
                                    )
                                    : Center(
                                      child: Text(
                                        Languages.of(context)!.nopostsyetText,
                                        style: Pallete.Quicksand20drkBlackBold,
                                      ),
                                    )
                                : GridView.builder(
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
                                                (context) => TagPostViewScreen(
                                                  postData: tagPostList!,
                                                  selectedLessonIndex: index,
                                                  usertype:
                                                      salonDetails!.userType!
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
                                                          BuildContext context,
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
                                                              .endsWith(".MP4")
                                                      ? Stack(
                                                        children: [
                                                          SizedBox(
                                                            height:
                                                                kSize.height,
                                                            width: kSize.width,
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
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : Image.network(
                                                        "${API.baseUrl}/api/${tagPostList![index].otherMultiPost![0].otherData!}",
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (
                                                          BuildContext context,
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
                                                padding: const EdgeInsets.only(
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
                                ),
                          ],
                        ),
                      ),
                    ],
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
            isLoading
                ? Container(
                  height: kSize.height,
                  width: kSize.width,
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
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

  showProfilVeiew(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: AlertDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.only(left: 0, right: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    print("${API.baseUrl}/api/${salonDetails!.profileImage!}");
                  },
                  child: Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(140),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          "${API.baseUrl}/api/${salonDetails!.profileImage!}",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  getSalonDetails(String id, String user_type) async {
    salonPostArray.clear();
    print("get getSalonDetails function call");
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SalonDetailsViewModel>(
          context,
          listen: false,
        ).getSalonDetails(id, userid, offsett, user_type);
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
            salonPostArray.clear();
            setState(() {
              videoList.clear();
              salonPostArray.clear();
              isLoading = false;
              print("Success");
              SalonDetailModel model =
                  Provider.of<SalonDetailsViewModel>(
                        context,
                        listen: false,
                      ).salondetailsresponse.response
                      as SalonDetailModel;

              salonDetails = model.userProfile!;
              totlepostcount = model.postCount!;
              getDetailsStories = model.story!;
              tagPostList = model.tagPosts!.reversed.toList();

              salonOpenDays = model.salonOpenDays!;

              totalPoints = model.points!;
              postCountsReeview = model.postCountReview!;
              print("model.points ${model.points}");

              // print(salonDetails!.toJson());
              salonPostArray = model.posts!;
              userTyppe = model.userProfile!.userType.toString();

              // salonPostArray.forEach((element) {
              //   String fileExtension =
              //       getFileExtension(element.other.toString());
              //   print("fileExtension ==${fileExtension}");
              //   if (fileExtension == ".mp4") {
              //     videoList
              //         .add("${API.baseUrl}/api/${element.other.toString()}");
              //   }
              //   setState(() {});
              // });

              // salonPostArray.forEach((element) async {
              //   element.otherMultiPost!.forEach((element) {
              //     String fileExtension =
              //         getFileExtension(element.otherData.toString());
              //     print("fileExtension ==${fileExtension}");
              //     if (fileExtension == ".mp4") {
              //       videoList.add(
              //           "${API.baseUrl}/api/${element.otherData.toString()}");
              //       setState(() {});
              //     } else if (fileExtension == ".jpg") {
              //       showotherimg.add(
              //           "${API.baseUrl}/api/${element.otherData.toString()}");
              //     }
              //   });
              // });
              salonPostArray.forEach((element) async {
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
                    }
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

              setState(() {
                _videoPlayercontroller =
                    videoList.map((videoUrl) {
                      return VideoPlayerController.network(videoUrl)
                        ..initialize();
                    }).toList();
              });

              print("video list ===${videoList}");
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

  String getFileExtension(String fileName) {
    return "." + fileName.split('.').last;
  }

  userFollowing(String following_id, String follower_id, String status) async {
    print("get callForgotPass function call");
    setState(() {
      // isLoading = true;
    });
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
              // isLoading = false;
              print("Success");
              FollowingModel model =
                  Provider.of<FollowingViewModel>(
                        context,
                        listen: false,
                      ).followingresponse.response
                      as FollowingModel;

              if (model.success == true) {
                // salonDetails!.isFollowed = 1;
                followCheck(widget.id);
              }

              kToast(model.message!);
            });
          }
        }
      } else {
        setState(() {
          // isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  userUnfollow(String following_id, String follower_id) async {
    print("get userUnfollow function call");
    setState(() {
      // isLoading = true;
    });
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
              // isLoading = false;
              print("Success");
              UnfollowiModel model =
                  Provider.of<UnfollowViewModel>(
                        context,
                        listen: false,
                      ).unfollowresponse.response
                      as UnfollowiModel;
              if (model.success == true) {
                // salonDetails!.isFollowed = 0;
                followCheck(widget.id);
              }
              kToast(model.message!);
            });
          }
        }
      } else {
        setState(() {
          // isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  followCheck(String id) async {
    salonPostArray.clear();
    print("get followCheck function call");
    setState(() {});
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SalonDetailsViewModel>(
          context,
          listen: false,
        ).getSalonDetails(id, userid, 0, userTyppe);
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
              salonPostArray.clear();
              print("Success");
              SalonDetailModel model =
                  Provider.of<SalonDetailsViewModel>(
                        context,
                        listen: false,
                      ).salondetailsresponse.response
                      as SalonDetailModel;

              salonDetails = model.userProfile!;
              print(salonDetails!.toJson());
              salonPostArray = model.posts!;

              salonPostArray.forEach((element) {
                String fileExtension = getFileExtension(
                  element.other.toString(),
                );
                print("fileExtension ==${fileExtension}");
                if (fileExtension == ".mp4") {
                  videoList.add(element.other.toString());
                }
                setState(() {});
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
