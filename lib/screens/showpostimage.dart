// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, use_build_context_synchronously, non_constant_identifier_names, sized_box_for_whitespace, must_be_immutable, use_key_in_widget_constructors, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/deletepostmodel.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:pinkGossip/viewModels/postdeleteviewmodel.dart';
import 'package:chewie/chewie.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/models/commentpostmodel.dart';
import 'package:pinkGossip/models/postlike.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/commentpostviewmodel.dart';
import 'package:pinkGossip/viewModels/postlikeviewmodel.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class ShowPostImage extends StatefulWidget {
  bool isProfile;
  final List<Post> postData;
  List<StoryUserDetails>? otherstories;
  List<Stories>? mystories;

  String usertype, type;

  int selectedLessonIndex = 1;

  ShowPostImage({
    Key? key,
    required this.postData,
    required this.selectedLessonIndex,
    required this.usertype,
    required this.isProfile,
    this.mystories,
    required this.type,
    this.otherstories,
  });

  @override
  State<ShowPostImage> createState() => _ShowPostImageState();
}

class _ShowPostImageState extends State<ShowPostImage> {
  final PageController _pageController = PageController(initialPage: 0);
  ScrollController? _controller;
  // late FlickManager flickManager;
  // List<FlickManager> videoListManager = [];
  int curentPagecount = 1;
  List<int> allcount = [];
  int mxline = 2;
  int selectindex = -1;
  bool more = true;
  bool less = false;
  SharedPreferences? prefs;
  String userid = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    // print("userid   ${userid}")
  }

  List<int> likeCount = [];
  TextEditingController commentcontroller = TextEditingController();

  bool unlike = true;
  bool like = false;

  bool isLoading = false;
  _scrollListener() {}

  @override
  void initState() {
    super.initState();
    getchannellist();
    getuserid();
    print("widget.postData.length = ${widget.postData.length}");
    // print("widget postdata == ${widget.postData.length}");
    // widget.postData.forEach((element) {
    //   allcount.add(1);
    //   videoListManager.add(FlickManager(
    //       videoPlayerController: VideoPlayerController.networkUrl(
    //     Uri.parse("${API.baseUrl}/api/${element.other!}"),

    //   )));
    //   // print("element.other! = ${element.other!}");
    // });
    // print("videoListManager =${videoListManager.length}");

    _controller = ScrollController();

    _controller!.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller!.hasClients) {
        _controller!.animateTo(
          (widget.selectedLessonIndex * 520),
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
      }
    });
    // print("widget.postData.length == ${widget.postData.length}");
  }

  int page = 1;
  @override
  void dispose() {
    // flickManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Post? selectingpostData;

  bool _showIcon = false;
  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
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
                    print("");
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
                  Languages.of(context)!.allpostText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: widget.postData.length,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final Post item = widget.postData[index];
          return Container(
            // decoration: const BoxDecoration(
            //     border: Border(
            //         bottom:
            //             BorderSide(width: 2, color: AppColors.kBorderColor))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              print("InkWell");

                              if (widget.type == "Profile") {
                                if (widget.mystories!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MyStoryView(
                                            myStorysArray: widget.mystories,
                                            firstname:
                                                widget
                                                    .mystories![index]
                                                    .firstName ??
                                                "",
                                            lastname:
                                                widget
                                                    .mystories![index]
                                                    .lastName ??
                                                "",
                                            img:
                                                widget
                                                    .mystories![index]
                                                    .profileImage ??
                                                "",
                                            salonanme:
                                                widget
                                                    .mystories![index]
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
                                          (context) => SalonDetailScreen(
                                            id:
                                                widget.postData[index].userId
                                                    .toString(),
                                            userType:
                                                widget.usertype.toString(),
                                          ),
                                    ),
                                  );
                                }
                              } else {
                                if (widget.otherstories!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SingleUserStoryView(
                                            storyUserDetailsData:
                                                widget.otherstories,
                                            myFireabseiD: firebaseId,
                                            firstname:
                                                widget
                                                    .otherstories![index]
                                                    .firstName!,
                                            lastname:
                                                widget
                                                    .otherstories![index]
                                                    .lastName!,
                                            profileimage:
                                                "${API.baseUrl}/api/${widget.otherstories![index].profileImage!}",
                                            salonname:
                                                widget
                                                    .otherstories![index]
                                                    .salonName!,
                                            type: "Details",
                                          ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SalonDetailScreen(
                                            id:
                                                widget.postData[index].userId
                                                    .toString(),
                                            userType:
                                                widget.usertype.toString(),
                                          ),
                                    ),
                                  );
                                }
                              }
                            },
                            child:
                                widget.postData[index].profileImage != ""
                                    ? Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(2.0),
                                      decoration:
                                          widget.type == "Profile"
                                              ? widget.mystories!.isNotEmpty
                                                  ? const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors.kPinkColor,
                                                        AppColors.kPinkColor,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  )
                                                  : const BoxDecoration()
                                              : widget.otherstories!.isNotEmpty
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
                                              : const BoxDecoration(),
                                      child: CircleAvatar(
                                        radius: 33.0,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: NetworkImage(
                                          "${API.baseUrl}/api/${widget.postData[index].profileImage!}",
                                        ),
                                      ),
                                    )
                                    : Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(2.0),
                                      decoration:
                                          widget.type == "Profile"
                                              ? widget.mystories!.isNotEmpty
                                                  ? const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors.kPinkColor,
                                                        AppColors.kPinkColor,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  )
                                                  : const BoxDecoration()
                                              : widget.otherstories!.isNotEmpty
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
                                              : const BoxDecoration(),
                                      child: CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor: Colors.grey[300],
                                        child: const Icon(Icons.person),
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 10),
                          widget.usertype == "1"
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print("InkWell");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => SalonDetailScreen(
                                                id:
                                                    widget
                                                        .postData[index]
                                                        .userId
                                                        .toString(),
                                                userType:
                                                    widget.usertype.toString(),
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      widget
                                              .postData[index]
                                              .userName!
                                              .isNotEmpty
                                          ? widget.postData[index].userName!
                                          : "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                      style: Pallete.Quicksand12blackwe600,
                                    ),
                                  ),
                                  widget.postData[index].beforeImage != ""
                                      ? InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      SalonDetailScreen(
                                                        id:
                                                            widget
                                                                .postData[index]
                                                                .userSalonId
                                                                .toString(),
                                                        userType: "2",
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          widget.postData[index].salonName!,
                                          style:
                                              Pallete.Quicksand12Black54we600,
                                        ),
                                      )
                                      : Container(),
                                  widget.postData[index].beforeImage != ""
                                      ? Row(
                                        children: [
                                          Text(
                                            widget
                                                .postData[index]
                                                .averageRating!
                                                .toStringAsFixed(1),
                                            style:
                                                Pallete.Quicksand12blackwe400,
                                          ),
                                          const SizedBox(width: 4),
                                          RatingBarIndicator(
                                            rating: double.parse(
                                              widget
                                                  .postData[index]
                                                  .averageRating!
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
                                                  color: AppColors.kPinkColor,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "(${widget.postData[index].ratingCount.toString()})",
                                            style: Pallete.Quicksand12Greywe400,
                                          ),
                                        ],
                                      )
                                      : Container(),
                                ],
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print("InkWell");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => SalonDetailScreen(
                                                id:
                                                    widget
                                                        .postData[index]
                                                        .userId
                                                        .toString(),
                                                userType:
                                                    widget.usertype.toString(),
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      widget
                                              .postData[index]
                                              .userName!
                                              .isNotEmpty
                                          ? widget.postData[index].userName!
                                          : "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                      style: Pallete.Quicksand12blackwe600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => SalonDetailScreen(
                                                id:
                                                    widget
                                                        .postData[index]
                                                        .userSalonId
                                                        .toString(),
                                                userType: "2",
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      widget.postData[index].salonName!,
                                      style: Pallete.Quicksand12Black54we600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.postData[index].averageRating!
                                            .toStringAsFixed(1),
                                        style: Pallete.Quicksand12blackwe400,
                                      ),
                                      const SizedBox(width: 4),
                                      RatingBarIndicator(
                                        rating: double.parse(
                                          widget.postData[index].averageRating!
                                              .toString(),
                                        ),
                                        itemCount: 5,
                                        itemSize: 18.0,
                                        unratedColor: AppColors.klightGreyColor,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder:
                                            (context, _) => const Icon(
                                              Icons.star,
                                              color: AppColors.kPinkColor,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "(${widget.postData[index].ratingCount.toString()})",
                                        style: Pallete.Quicksand12Greywe400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          moreOptionBottomsheet(
                            context, // ✅ ONLY ONE context
                            kSize,
                            item.id ?? 0,
                            item,
                            page,
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 15,
                          child: Image.asset(ImageUtils.moreoptionimg),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.usertype == "1"
                    ? widget.postData[index].beforeImage != ""
                        ? ExpandablePageView.builder(
                          // controller: _pageController,
                          itemCount:
                              (widget.postData[index].otherMultiPost!.length) +
                              1,
                          onPageChanged: (int pageIndex) {
                            print("Current Page Index: $pageIndex");
                          },
                          itemBuilder: (context, pageviewindex) {
                            page = pageviewindex + 1;
                            return Stack(
                              children: [
                                pageviewindex == 0
                                    ? Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: kSize.height / 3,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                2.0,
                                              ),
                                              child: Image.network(
                                                loadingBuilder: (
                                                  BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
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
                                                "${API.baseUrl}/api/${widget.postData[index].beforeImage!}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: kSize.height / 3,
                                            color: Colors.black12,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                2.0,
                                              ),
                                              child: Image.network(
                                                loadingBuilder: (
                                                  BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
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
                                                "${API.baseUrl}/api/${widget.postData[index].afterImage!}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(
                                      child:
                                          widget
                                                      .postData[index]
                                                      .otherMultiPost![pageviewindex -
                                                          1]
                                                      .otherData!
                                                      .endsWith('.mp4') ||
                                                  widget
                                                      .postData[index]
                                                      .otherMultiPost![pageviewindex -
                                                          1]
                                                      .otherData!
                                                      .endsWith('.mov')
                                              ? MyVideoPlayer(
                                                videoUrl:
                                                    "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                              )
                                              : Container(
                                                height:
                                                    widget
                                                                .postData[index]
                                                                .postType ==
                                                            "NormalPost"
                                                        ? kSize.height / 2
                                                        : kSize.height / 3,
                                                width: kSize.width,
                                                child: Image.network(
                                                  fit: BoxFit.cover,
                                                  "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                                  loadingBuilder: (
                                                    BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: SizedBox(
                                                        height: 100,
                                                        width: 100,
                                                        child: Center(
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
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                    ),
                                widget.postData[index].otherMultiPost!.isEmpty
                                    ? Container()
                                    : Positioned(
                                      top: 10.0,
                                      right: 10,
                                      child: Container(
                                        height: 20,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            12.5,
                                          ),
                                        ),
                                        alignment: Alignment.topRight,
                                        child: Center(
                                          child: Text(
                                            "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length + 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          },
                        )
                        : ExpandablePageView.builder(
                          // controller: _pageController,
                          itemCount:
                              (widget.postData[index].otherMultiPost!.length),
                          onPageChanged: (int pageIndex) {
                            print("Current Page Index: $pageIndex");
                          },
                          itemBuilder: (context, pageviewindex) {
                            print(
                              "lenght ${widget.postData[index].otherMultiPost!.length}",
                            );
                            return Stack(
                              children: [
                                Container(
                                  child:
                                      widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex]
                                                  .otherData!
                                                  .endsWith('.mp4') ||
                                              widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex]
                                                  .otherData!
                                                  .endsWith('.mov')
                                          ? SizedBox(
                                            child: MyVideoPlayer(
                                              videoUrl:
                                                  "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                            ),
                                          )
                                          : Container(
                                            height:
                                                widget
                                                            .postData[index]
                                                            .postType ==
                                                        "NormalPost"
                                                    ? kSize.height / 2
                                                    : kSize.height / 3,
                                            width: kSize.width,
                                            child: Image.network(
                                              fit: BoxFit.cover,
                                              "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                              loadingBuilder: (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: Center(
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
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                ),
                                widget.postData[index].otherMultiPost!.length >
                                        1
                                    ? Positioned(
                                      top: 10.0,
                                      right: 10,
                                      child: Container(
                                        height: 20,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            12.5,
                                          ),
                                        ),
                                        alignment: Alignment.topRight,
                                        child: Center(
                                          child: Text(
                                            "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container(),
                              ],
                            );
                          },
                        )
                    : widget.postData[index].afterImage!.isNotEmpty
                    ? ExpandablePageView.builder(
                      // controller: _pageController,
                      itemCount:
                          (widget.postData[index].otherMultiPost!.length) + 1,
                      onPageChanged: (int pageIndex) {
                        print("Current Page Index: $pageIndex");
                      },
                      itemBuilder: (context, pageviewindex) {
                        page = pageviewindex + 1;
                        return Stack(
                          children: [
                            pageviewindex == 0
                                ? Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.black12,
                                        height: kSize.height / 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Image.network(
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent? loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
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
                                            "${API.baseUrl}/api/${widget.postData[index].beforeImage!}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: kSize.height / 3,
                                        color: Colors.black12,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Image.network(
                                            loadingBuilder: (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent? loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
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
                                            "${API.baseUrl}/api/${widget.postData[index].afterImage!}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Container(
                                  child:
                                      widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex -
                                                      1]
                                                  .otherData!
                                                  .endsWith('.mp4') ||
                                              widget
                                                  .postData[index]
                                                  .otherMultiPost![pageviewindex -
                                                      1]
                                                  .otherData!
                                                  .endsWith('.mov')
                                          ? SizedBox(
                                            child: MyVideoPlayer(
                                              videoUrl:
                                                  "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                            ),
                                          )
                                          : Container(
                                            height:
                                                widget
                                                            .postData[index]
                                                            .postType ==
                                                        "NormalPost"
                                                    ? kSize.height / 2
                                                    : kSize.height / 3,
                                            width: kSize.width,
                                            child: Image.network(
                                              fit: BoxFit.cover,
                                              "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex - 1].otherData}",
                                              loadingBuilder: (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: Center(
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
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                ),
                            widget.postData[index].otherMultiPost!.isEmpty
                                ? Container()
                                : Positioned(
                                  top: 10.0,
                                  right: 10,
                                  child: Container(
                                    height: 20,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    alignment: Alignment.topRight,
                                    child: Center(
                                      child: Text(
                                        "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    )
                    : ExpandablePageView.builder(
                      // controller: _pageController,
                      itemCount: widget.postData[index].otherMultiPost!.length,
                      onPageChanged: (int pageIndex) {
                        print("Current Page Index: $pageIndex");
                      },
                      itemBuilder: (context, pageviewindex) {
                        print(
                          "widget.postData[index].otherMultiPost!.length = ${widget.postData[index].otherMultiPost!.length}",
                        );
                        page = pageviewindex + 1;
                        return Stack(
                          children: [
                            Container(
                              child:
                                  widget
                                              .postData[index]
                                              .otherMultiPost![pageviewindex]
                                              .otherData!
                                              .endsWith('.mp4') ||
                                          widget
                                              .postData[index]
                                              .otherMultiPost![pageviewindex]
                                              .otherData!
                                              .endsWith('.mov')
                                      ? SizedBox(
                                        child: MyVideoPlayer(
                                          videoUrl:
                                              "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                        ),
                                      )
                                      : Container(
                                        height:
                                            widget.postData[index].postType ==
                                                    "NormalPost"
                                                ? kSize.height / 2
                                                : kSize.height / 3,
                                        width: kSize.width,
                                        child: Image.network(
                                          fit: BoxFit.cover,
                                          "${API.baseUrl}/api/${widget.postData[index].otherMultiPost![pageviewindex].otherData}",
                                          loadingBuilder: (
                                            BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        AppColors.kBlackColor,
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
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                            ),
                            widget.postData[index].otherMultiPost!.length == 1
                                ? Container()
                                : Positioned(
                                  top: 10.0,
                                  right: 10,
                                  child: Container(
                                    height: 20,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    alignment: Alignment.topRight,
                                    child: Center(
                                      child: Text(
                                        "${pageviewindex + 1}/${widget.postData[index].otherMultiPost!.length}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.postData[index].like == 1) {
                            widget.postData[index].like = 0;
                            widget.postData[index].likeCount =
                                widget.postData[index].likeCount! - 1;
                            setState(() {
                              widget.postData[index].like = 0;
                            });
                            doPostLike(
                              userid,
                              widget.postData[index].id!.toString(),
                              "0",
                              index,
                            );
                          } else {
                            widget.postData[index].like = 1;
                            widget.postData[index].likeCount =
                                widget.postData[index].likeCount! + 1;
                            setState(() {
                              widget.postData[index].like = 1;
                            });
                            doPostLike(
                              userid,
                              widget.postData[index].id!.toString(),
                              "1",
                              index,
                            );
                          }
                        },
                        child:
                            widget.postData[index].like == 1
                                ? Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.topLeft,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: AppColors.kPinkColor,
                                  ),
                                )
                                : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.favorite_outline,
                                    color: AppColors.kBlackColor,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 30,
                        width: 40,
                        child: InkWell(
                          onTap: () {
                            CommentBottomSheet(context, kSize, index);
                          },
                          child: Image.asset(ImageUtils.lipimage),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: InkWell(
                          onTap: () {
                            print(
                              "widget.postData[index]; = ${widget.postData[index].toJson()}",
                            );
                            shareData = widget.postData[index];

                            print("sendimage");

                            if (widget
                                .postData[index]
                                .beforeImage!
                                .isNotEmpty) {
                              SharepostwithFriends(context, kSize, 1);
                            } else {
                              SharepostwithFriends(context, kSize, 2);
                            }
                          },
                          child: Image.asset(ImageUtils.sendimage),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${widget.postData[index].likeCount} ${Languages.of(context)!.likesText}",
                    style: Pallete.Quicksand12blackwe600,
                  ),
                ),
                // const SizedBox(height: 8),
                widget.postData[index].review!.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.topLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: selectindex == index ? mxline : 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${widget.postData[index].firstName!} ${widget.postData[index].lastName!}",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),
                                  TextSpan(
                                    text: " ",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),

                                  _buildReviewText(
                                    widget.postData[index].review!,
                                    widget.postData[index].userTags!,
                                  ),

                                  // TextSpan(
                                  //   text: widget.postData[index].review,
                                  //   style: Pallete.Quicksand12darkGreykwe400,
                                  // ),
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () {
                                        print(
                                          "length === ${widget.postData[index].review!.length}",
                                        );
                                        setState(() {
                                          mxline = 2;
                                          more = true;
                                          less = false;
                                          selectindex = -1;
                                        });
                                      },
                                      child: Visibility(
                                        visible: less,
                                        child: Text(
                                          " ${Languages.of(context)!.lessText}",
                                          style: Pallete.Quicksand12blackwe600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          widget.postData[index].review!.length > 100
                              ? InkWell(
                                onTap: () {
                                  setState(() {
                                    print(
                                      "lenght === ${widget.postData[index].review!.length}",
                                    );
                                    mxline = 15;
                                    more = false;
                                    less = true;
                                    selectindex = index;
                                  });
                                },
                                child: Visibility(
                                  visible: selectindex == index ? more : true,
                                  child: Text(
                                    "..${Languages.of(context)!.moreText}",
                                    style: Pallete.Quicksand12blackwe600,
                                  ),
                                ),
                              )
                              : Container(),
                        ],
                      ),
                    )
                    : Container(),

                widget.usertype == "2"
                    ? Container(
                      // height: 10,
                      color: Colors.blueAccent,
                    )
                    : widget.usertype == "1" &&
                        widget.postData[index].beforeImage != ""
                    ? Column(
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Text(
                                widget.postData[index].rating!.toString(),
                                style: Pallete.Quicksand12blackwe400,
                              ),
                              const SizedBox(width: 4),
                              RatingBarIndicator(
                                rating: double.parse(
                                  widget.postData[index].rating!.toString(),
                                ),
                                itemCount: 5,
                                itemSize: 18.0,
                                unratedColor: AppColors.klightGreyColor,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder:
                                    (context, _) => const Icon(
                                      Icons.star,
                                      color: AppColors.kPinkColor,
                                    ),
                              ),
                              // const SizedBox(width: 4),
                              // Text(
                              //     "(${widget.postData[index].ratingCount.toString()})",
                              //     style: Pallete.Quicksand12blackwe400),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Container(),
                const SizedBox(height: 2),
                widget.postData[index].commentCount != 0
                    ? Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          CommentBottomSheet(context, kSize, index);
                        },
                        child: Text(
                          "${Languages.of(context)!.viewallText} ${widget.postData[index].commentCount.toString()} ${Languages.of(context)!.commentsText}",
                          style: Pallete.Quicksand12drktxtGreywe500,
                        ),
                      ),
                    )
                    : Container(),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    getpostTime(widget.postData[index].createdAt!),
                    style: Pallete.Quicksand12drktxtGreywe500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  // moreOptionBottomsheet(BuildContext context, Size kSize, postID) {
  //   return showModalBottomSheet<void>(
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     elevation: 0,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
  //     ),
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: StatefulBuilder(
  //           builder: (context, BottomsetState) {
  //             return Container(
  //               height: 60,
  //               child: Padding(
  //                 padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     TextButton(
  //                       child: Row(
  //                         children: [
  //                           Container(
  //                             height: 30,
  //                             width: 30,
  //                             child: Image.asset(
  //                               "lib/assets/images/delete.png",
  //                             ),
  //                           ),
  //                           const SizedBox(width: 20),
  //                           Text(
  //                             Languages.of(context)!.deleteText,
  //                             style: Pallete.Quicksand18drkBlackbold,
  //                           ),
  //                         ],
  //                       ),
  //                       onPressed: () {
  //                         DeleteAlert(context, kSize, postID);
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
  void moreOptionBottomsheet(
    BuildContext screenContext, // 🔥 MAIN SCREEN context
    Size kSize,
    int postID,
    Post item,
    int page,
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
                /// 🔽 DOWNLOAD
                TextButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);

                    handleDownload(
                      screenContext, // ✅ VERY IMPORTANT
                      item,
                      page,
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        size: 30,
                        Icons.download,
                        color: AppColors.onboardingVibrantPink,
                      ),
                      SizedBox(width: 20),
                      Text("Download", style: Pallete.Quicksand18drkBlackbold),
                    ],
                  ),
                ),

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
                      Text("Delete", style: Pallete.Quicksand18drkBlackbold),
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

  void handleDownload(BuildContext parentContext, Post item, int page) {
    if (item.postType == "SalonReview" && page == 1) {
      showDialog(
        context: parentContext, // ✅ SAFE
        builder:
            (ctx) => AlertDialog(
              title: const Text("Download"),
              content: Row(
                children: [
                  Expanded(
                    child: CommonWidget().getSmallButton("Before Image", () {
                      Navigator.pop(ctx);
                      if (item.beforeImage?.isNotEmpty ?? false) {
                        CommonFunctions().downloadPhoto(
                          parentContext,
                          "${API.baseUrl}/api/${item.beforeImage}",
                          item.beforeImage!,
                        );
                      }
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CommonWidget().getSmallButton("After Image", () {
                      Navigator.pop(ctx);
                      if (item.afterImage?.isNotEmpty ?? false) {
                        CommonFunctions().downloadPhoto(
                          parentContext,
                          "${API.baseUrl}/api/${item.afterImage}",
                          item.afterImage!,
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
      );
      return;
    }

    /// NORMAL POST
    if (item.otherMultiPost?.isNotEmpty ?? false) {
      CommonFunctions().downloadPhoto(
        parentContext,
        "${API.baseUrl}/api/${item.otherMultiPost![0].otherData}",
        item.otherMultiPost![0].otherData!,
      );
    }
  }

  Future<void> SharepostwithFriends(
    BuildContext context,
    Size kSize,
    int userType,
  ) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, BottomsetState) {
            return Container(
              height: kSize.height / 1.5,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: kSize.height / 1.90,
                    child:
                        usersList.isNotEmpty
                            ? GridView.builder(
                              itemCount: usersList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.85,
                                  ),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                void toggleSelection() {
                                  BottomsetState(() {
                                    usersList[index]['isSelected'] =
                                        !(usersList[index]['isSelected'] ??
                                            false);
                                    selectedCount =
                                        usersList
                                            .where(
                                              (user) =>
                                                  user['isSelected'] == true,
                                            )
                                            .length;
                                    BottomsetState(() {});
                                  });
                                }

                                return GestureDetector(
                                  onTap: () {
                                    toggleSelection();
                                  },
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Stack(
                                        alignment:
                                            AlignmentDirectional.bottomEnd,
                                        children: [
                                          usersList[index]['photoUrl'] != ""
                                              ? Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                      "${API.baseUrl}/api/${usersList[index]['photoUrl']}",
                                                    ),
                                                  ),
                                                  color:
                                                      AppColors.chatSenderColor,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              )
                                              : Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.chatSenderColor,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: const Icon(Icons.person),
                                              ),
                                          if (usersList[index]['isSelected'] ??
                                              false)
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors
                                                        .blue, // Customize the selection icon background color
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color:
                                                    Colors
                                                        .white, // Customize the selection icon color
                                                size: 20,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Expanded(
                                        child: Text(
                                          usersList[index]['nickname'],
                                          style: Pallete.Quicksand12Blackkwe400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Container(
                              width: kSize.width,
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.NouserfoundText,
                                  style: Pallete.Quicksand16drkBlackbold,
                                ),
                              ),
                            ),
                  ),
                  if (usersList.any((user) => user['isSelected'] ?? false))
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      height: 40,
                      width: kSize.width,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          List<Map> selectedUsers = getSelectedUsers();
                          List<String> selectedUserIds =
                              selectedUsers
                                  .map((user) => user['id'] as String)
                                  .toList();

                          selectedUserIds.forEach((element) {
                            shareMessage(
                              element,
                              shareData!.toJson(),
                              userType,
                            );
                          });

                          print('Selected Users: $selectedUsers');
                          print('selectedUserIds: $selectedUserIds');
                          print("shareData == ${shareData!.toJson()}");

                          // if (channelId != "") {
                          //   Map<String, dynamic> shareDataMap =
                          //       shareData!.toJson();

                          //   String jsonString = jsonEncode(shareDataMap);

                          //   print("jsonString == ${jsonString}");
                          //   DatabaseReference chatRef = FirebaseDatabase
                          //       .instance
                          //       .reference()
                          //       .child('message')
                          //       .child(channelId);

                          //   int timestamp =
                          //       DateTime.now().millisecondsSinceEpoch;

                          //   Map<String, dynamic> message = {
                          //     'content': jsonString,
                          //     'idFrom': firebaseId,
                          //     'idTo': selectedUserIds,
                          //     'timestamp': timestamp,
                          //     'type': 0,
                          //     'isSeen': false,
                          //   };

                          //   chatRef.child(timestamp.toString()).set(message);
                          // }
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Text(
                            Languages.of(context)!.sendText,
                            style: Pallete.Quicksand14Whiitewe600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String firebaseId = "";
  int selectedCount = 0;
  List<Map> usersList = [];
  Post? shareData;

  List<Map> getSelectedUsers() {
    return usersList.where((user) => user['isSelected'] ?? false).toList();
  }

  getchannellist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firebaseId = prefs.getString('FirebaseId') ?? "";
      isLoading = true;
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref('message');

    ref.once().then((event) {
      var temp = event.snapshot.value;

      Map<dynamic, dynamic> allChanels = temp as Map<dynamic, dynamic>;
      print("allChanels = ${allChanels}");
      allChanels.forEach((key, value) async {
        List<String> parts = key.split('--');
        if (parts.contains(firebaseId.replaceFirst('-', ''))) {
          int idpossition = parts.indexOf(firebaseId.replaceFirst('-', ''));

          if (idpossition == 1) {
            String extractedString = parts.length > 2 ? parts[1] : '';
            int unreadCount = 0;
            if (extractedString == firebaseId.replaceFirst('-', '')) {
              DatabaseReference userListRef = FirebaseDatabase.instance
                  .ref()
                  .child('users')
                  .child('-${key.split('--')[2]}');

              await userListRef.once().then((snapshot) {
                Map<dynamic, dynamic> userData =
                    snapshot.snapshot.value as Map<dynamic, dynamic>;

                Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;

                if (messages != null) {
                  unreadCount =
                      messages.values
                          .where(
                            (message) =>
                                firebaseId.contains(message['idTo']) &&
                                !(message['isSeen'] ?? false),
                          )
                          .length;
                }

                userData['unreadCount'] = unreadCount;

                usersList.add(userData);

                setState(() {
                  isLoading = false;
                });
              });
            }
          } else {
            String extractedString = parts.length > 2 ? parts[2] : '';
            int unreadCount = 0;
            if (extractedString == firebaseId.replaceFirst('-', '')) {
              DatabaseReference userListRef = FirebaseDatabase.instance
                  .ref()
                  .child('users')
                  .child('-${key.split('--')[1]}');

              await userListRef.once().then((snapshot) {
                Map<dynamic, dynamic> userData =
                    snapshot.snapshot.value as Map<dynamic, dynamic>;

                Map<dynamic, dynamic> messages = value as Map<dynamic, dynamic>;

                if (messages != null) {
                  unreadCount =
                      messages.values
                          .where(
                            (message) =>
                                firebaseId.contains(message['idTo']) &&
                                !(message['isSeen'] ?? false),
                          )
                          .length;
                }
                userData['unreadCount'] = unreadCount;
                usersList.add(userData);

                setState(() {
                  isLoading = false;
                });
              });
            }
          }
        }
      });
    });
  }

  Future<dynamic> DeleteAlert(BuildContext context, Size kSize, postID) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: AlertDialog(
              backgroundColor: AppColors.kWhiteColor,
              elevation: 0,
              title: Text(Languages.of(context)!.deleteText),
              titleTextStyle: Pallete.Quicksand22drkBlackbold,
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.deleteposttitleText,
                style: Pallete.Quicksand18drktxtGreyrwe500,
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

  Map<String, int> tagToIdMap = {};

  void _createTagToIdMap(String review, String userTags) {
    List<String> tags = review.split(' ');
    List<String> ids = userTags.split(',');

    int tagIndex = 0;
    for (String tag in tags) {
      if (tag.startsWith('@') && tagIndex < ids.length) {
        tagToIdMap[tag] = int.parse(ids[tagIndex]);
        tagIndex++;
      }
    }
  }

  void _openSalonDetails(BuildContext context, String tag) {
    if (tagToIdMap.containsKey(tag)) {
      int id = tagToIdMap[tag]!;
      print('Tapped on tag: $tag with ID: $id');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SalonDetailScreen(id: id.toString(), userType: "1"),
        ),
      );
    } else {
      print('Tag not found in map');
    }
  }

  TextSpan _buildReviewText(String review, String userTags) {
    if (userTags.isNotEmpty) {
      _createTagToIdMap(review, userTags);
    }

    List<TextSpan> textSpans = [];

    List<String> words = review.split(' ');

    for (String word in words) {
      if (word.startsWith('@')) {
        textSpans.add(
          TextSpan(
            text: '$word ',
            style: Pallete.Quicksand12blackwe600.copyWith(
              color: AppColors.kblueColor,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    print('Tapped on: $word');
                    _openSalonDetails(context, word);
                  },
          ),
        );
      } else {
        textSpans.add(
          TextSpan(text: '$word ', style: Pallete.Quicksand12darkGreykwe400),
        );
      }
    }

    return TextSpan(children: textSpans);
  }

  String formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final minutesAgo = difference.inMinutes;

    if (minutesAgo < 1) {
      return Languages.of(context)!.justnowText;
    } else if (minutesAgo == 1) {
      return '1 ${Languages.of(context)!.minuteagoText}';
    } else {
      return '$minutesAgo ${Languages.of(context)!.minuteagoText}';
    }
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

  Future<void> CommentBottomSheet(BuildContext context, Size kSize, int index) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, BottomsetState) {
            return Container(
              height: (kSize.height * 85) / 100,
              width: kSize.width,
              decoration: const BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(border: Border()),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        child: const Icon(
                                          Icons.close,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        Languages.of(context)!.CommentsText,
                                        style: Pallete.Quicksand20drkBlackBold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                widget.postData[index].comments!.isNotEmpty
                                    ? SizedBox(
                                      height: kSize.height / 1.55,
                                      width: kSize.width,
                                      child: ListView.builder(
                                        itemCount:
                                            widget
                                                .postData[index]
                                                .comments!
                                                .length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, cindex) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                        "${API.baseUrl}/api/${widget.postData[index].comments![cindex].profileImage}",
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.5,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${widget.postData[index].comments![cindex].firstName.toString()} ${widget.postData[index].comments![cindex].lastName.toString()}",
                                                          style:
                                                              Pallete
                                                                  .Quicksand12blackwe600,
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          getpostTime(
                                                            widget
                                                                .postData[index]
                                                                .comments![cindex]
                                                                .createdAt!,
                                                          ),
                                                          style:
                                                              Pallete
                                                                  .Quicksand12drktxtGreywe500,
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      widget
                                                          .postData[index]
                                                          .comments![cindex]
                                                          .comment
                                                          .toString(),
                                                      style:
                                                          Pallete
                                                              .Quicksand12Blackkwe400,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : Container(
                                      height: ((kSize.height * 85) / 100) / 2,
                                      child: Center(
                                        child: Text(
                                          Languages.of(
                                            context,
                                          )!.NoCommentsavailableText,
                                          style:
                                              Pallete.Quicksand20drkBlackBold,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 50,
                          left: 15,
                          right: 15,
                        ),
                        child: TextField(
                          style: Pallete.textFieldTextStyle,
                          controller: commentcontroller,
                          maxLines: 1,
                          autocorrect: true,
                          keyboardType: TextInputType.text,
                          scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          textInputAction: TextInputAction.done,
                          cursorColor: AppColors.kTextColor,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: () {
                                if (commentcontroller.text.isEmpty) {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseentercommentText,
                                  );
                                } else {
                                  doCommentPost(
                                    userid,
                                    widget.postData[index].id.toString(),
                                    commentcontroller.text,
                                  );
                                  commentcontroller.text = "";
                                }
                              },
                              child: const Icon(Icons.send),
                            ),
                            fillColor: AppColors.kWhiteColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            hintText: Languages.of(context)!.sendcommentText,
                            hintStyle: Pallete.textFieldTextStyle,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                width: 2,
                                color: AppColors.kBorderColor,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                width: 1,
                                color: AppColors.kPinkColor,
                              ),
                            ),
                            focusColor: AppColors.kPinkColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  doCommentPost(
    String app_user_id,
    String salon_post_id,
    String comment,
  ) async {
    print("get callForgotPass function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CommentPostViewModel>(
          context,
          listen: false,
        ).doCommentPost(app_user_id, salon_post_id, comment);
        if (Provider.of<CommentPostViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CommentPostViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              CommentPostModel model =
                  Provider.of<CommentPostViewModel>(
                        context,
                        listen: false,
                      ).commentpostresponse.response
                      as CommentPostModel;

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

  doPostLike(String user_id, String post_id, String like, int index) async {
    print("get doPostLike function call");
    setState(() {
      // isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<PostLikeViewModel>(
          context,
          listen: false,
        ).doPostLike(user_id, post_id, like);
        if (Provider.of<PostLikeViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<PostLikeViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              // isLoading = false;
              print("Success");
              PostLikeModel model =
                  Provider.of<PostLikeViewModel>(
                        context,
                        listen: false,
                      ).postlikeresponse.response
                      as PostLikeModel;

              if (model.success == true) {
                likeCount.removeAt(index);
                likeCount.insert(index, model.likeCount!);
                print("likecount == ${likeCount}");
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

  void shareMessage(
    String oppId,
    Map<String, dynamic> content,
    int userType,
  ) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
      'message',
    );

    DatabaseReference userRef1 = FirebaseDatabase.instance.ref().child(
      'message',
    );

    var channelKey = 'chat--${firebaseId.replaceFirst("-", "")}-${oppId}';
    var channel2Key = 'chat-${oppId}--${firebaseId.replaceFirst("-", "")}';

    DatabaseEvent channelSnapshot = await userRef.child(channelKey).once();

    DatabaseEvent channel2Snapshot = await userRef.child(channel2Key).once();

    if (channelSnapshot.snapshot.exists) {
      print("ifff channelKey existst === ${channelKey.toString()}");

      DatabaseReference chatRef = FirebaseDatabase.instance
          .ref()
          .child('message')
          .child(channelKey);

      print("chatRef == ${chatRef.root}");
      print("chatRef path == ${chatRef.ref}");

      if (content.isNotEmpty) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        Map<String, dynamic> message = {
          'content': jsonEncode(content),
          'idFrom': firebaseId,
          'idTo': oppId,
          'timestamp': timestamp,
          'type': userType,
          'isSeen': false,
        };

        chatRef.child(timestamp.toString()).set(message);
      }
    } else if (channel2Snapshot.snapshot.exists) {
      print("elseiifff channel2Key existst === ${channel2Key.toString()}");

      DatabaseReference chatRef = FirebaseDatabase.instance
          .ref()
          .child('message')
          .child(channel2Key);

      print("chatRef == ${chatRef.root}");
      print("chatRef path == ${chatRef.ref}");

      if (content.isNotEmpty) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;

        Map<String, dynamic> message = {
          'content': jsonEncode(content),
          'idFrom': firebaseId,
          'idTo': oppId,
          'timestamp': timestamp,
          'type': userType,
          'isSeen': false,
        };

        chatRef.child(timestamp.toString()).set(message);
      }
    } else {
      print("no channel exists");
      print("channelKey  ${channelKey.toString()}");
      print("channel2Key ${channel2Key.toString()}");
    }
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
}
