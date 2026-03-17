// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinkGossip/models/commentpostmodel.dart';
import 'package:pinkGossip/models/deletepostmodel.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/models/homepagepostmodel.dart';
import 'package:pinkGossip/models/postlike.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/screens/map.dart';
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:pinkGossip/viewModels/blockuserviewmodel.dart';
import 'package:pinkGossip/viewModels/commentpostviewmodel.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:pinkGossip/viewModels/homepagepostviewmodel.dart';
import 'package:pinkGossip/viewModels/postlikeviewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/screens/HomeScreens/searchforhomescreen.dart';
import 'package:pinkGossip/screens/Profile/profile.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/viewModels/salonlistviewmodel.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/salonlistmodel.dart';
import '../../utils/imagesutils.dart';
import 'package:pinkGossip/components/pg_app_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../HomeScreens/notifications.dart';

class MackeupsScreen extends StatefulWidget {
  const MackeupsScreen({super.key});

  @override
  State<MackeupsScreen> createState() => _MackeupsScreenState();
}

class _MackeupsScreenState extends State<MackeupsScreen>
    {
  bool isLoading = false;
  List<Stories> myStoryArray = [];
  List<Map<String, dynamic>> otherArray = [];
  List<Map> getSelectedUsers() {
    return usersList.where((user) => user['isSelected'] ?? false).toList();
  }

  List<int> likeCount = [];
  TextEditingController commentcontroller = TextEditingController();
  List<OtherUserPost> postArray = [];
  SharedPreferences? prefs;
  String userid = "";
  int tmppageKey = 1;
  String userTyppe = "";
  String profileimg = "";

  String myFireabseiD = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid') ?? "";
    userTyppe = prefs!.getString('userType') ?? "";
    profileimg = prefs!.getString('profileimg') ?? "";
    myFireabseiD = prefs!.getString('FirebaseId') ?? "";
    // await getRemoveStoryCron();

    print("userid   ${userid}");
    print("myFireabseiD   ${myFireabseiD}");
    print("profileimg   ${profileimg}");
  }

  bool iscontainer = false;

  String firebaseId = "";
  int selectedCount = 0;
  List<Map> usersList = [];
  Post? shareData;

  List<SalonList> salonlistArray = [];

  int selectindex = 0;

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  int mxline = 2;

  int currentpageIndex = 1;
  bool more = true;
  bool less = false;
  bool unlike = true;
  bool like = false;

  int page = 1;
  List<int> allcount = [];

  int offsett = 0;
  void deletePost(int postIndex) {
    final currentPosts = _pagingController.value.itemList;

    if (currentPosts != null && postIndex < currentPosts.length) {
      currentPosts.removeAt(postIndex); // Remove the post at the specific index
      _pagingController.refresh(); // Refresh the controller to update the UI
    }
  }

  Future<void> otherUserReward(int pageKey) async {
    try {
      bool isConnected = await isInternetAvailable();

      if (isConnected) {
        await Provider.of<HomePagePostViewModel>(
          context,
          listen: false,
        ).otherUserRewardPost(userid, offsett);

        if (!Provider.of<HomePagePostViewModel>(
              context,
              listen: false,
            ).isLoading &&
            Provider.of<HomePagePostViewModel>(
              context,
              listen: false,
            ).isSuccess) {
          allcount.clear();
          HomePostResponseModel model =
              Provider.of<HomePagePostViewModel>(
                    context,
                    listen: false,
                  ).homepagepostresponse.response
                  as HomePostResponseModel;

          final otherUserPosts = model.otherUserPost ?? [];
          for (var i = 0; i < model.postCount!; i++) {
            allcount.add(1);
          }

          print(
            "model.otherUserPost!.length   = ${model.otherUserPost!.length}",
          );
          print("model.otherUserPost!   = ${model.otherUserPost![0].toJson()}");
          print("tmppageKey  === ${tmppageKey}");

          final nextPageKey = pageKey + 1;

          print("offset =${offsett}");
          offsett = offsett + 10;

          print("offset == ${offsett}");
          print("offset =${offsett}");

          setState(() {
            isLoading = false;
          });

          if (offsett > model.postCount!) {
            _pagingController.appendLastPage(model.otherUserPost!);
          } else {
            _pagingController.appendPage(model.otherUserPost!, nextPageKey);
          }

          print("else");
          print(
            "model.otherUserPost!.length   = ${model.otherUserPost!.length}",
          );
        } else {
          _pagingController.error;
        }
      } else {
        setState(() {});
        kToast(Languages.of(context)!.noInternetText);
      }
    } catch (error) {
      print("Error fetching page: $error");
      setState(() {
        _pagingController.error;
      });
    }
  }

  Future<void> redeemStorePost(
    String user_id,
    String reward_id,
    String redeem_point,
  ) async {
    setState(() => isLoading = true);
    getuserid();
    try {
      // 🔹 Internet check
      final isConnected = await isInternetAvailable();
      if (!isConnected) {
        kToast(Languages.of(context)!.noInternetText);
        return;
      }
      getuserid();
      // 🔹 ViewModel
      final viewModel = Provider.of<HomePagePostViewModel>(
        context,
        listen: false,
      );

      // 🔹 API Call
      await viewModel.redeemStorePost(user_id, reward_id, redeem_point);

      // 🔹 Success handling
      if (!mounted) return;

      if (viewModel.isSuccess &&
          viewModel.homepagepostresponse.response != null) {
        final HomePostResponseModel model =
            viewModel.homepagepostresponse.response as HomePostResponseModel;

        setState(() {
          postArray = model.otherUserPost ?? [];
        });
      } else {
        // 🔹 API error msg
        kToast(viewModel.homepagepostresponse.msg ?? "Something went wrong");
      }
    } catch (e) {
      print("redeemStorePost ERROR: $e");
      kToast("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  final PageController _pageController = PageController(initialPage: 0);

  final PagingController<int, OtherUserPost> _pagingController =
      PagingController(firstPageKey: 1);

  String getpostTime(DateTime loadedTime) {
    // print("loadedTime === ${loadedTime}");
    final now = DateTime.now();
    final difference = now.difference(loadedTime);
    DateTime postTime = now.subtract(difference);
    String timeAgo = timeago.format(postTime, locale: 'en');
    // print("postDateTime === ${timeAgo}");
    return timeAgo;
  }

  OtherUserPost? selectingpost;

  // MAP CODE

  GoogleMapController? mapController;
  List<Marker> markers = [];

  void addMarker(
    LatLng position,
    String salonname,
    String opendays,
    String salonid,
  ) async {
    final markerId = MarkerId(position.toString());

    final BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      'lib/assets/images/marker@2x.png',
    );
    print("position.toString() = ${position.toString()}");

    markers.add(
      Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: salonname,
          snippet: opendays,
          onTap: () {
            print("SalonDetailScreen");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProfileScreen(userId: salonid, userType: "2"),
              ),
            );
          },
        ),
        icon: customMarker,
      ),
    );
    setState(() {});
  }

  getchannellist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firebaseId = prefs.getString('FirebaseId') ?? "";
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

                setState(() {});
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

                setState(() {});
              });
            }
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getSalonList('');
    getuserid();
    getchannellist();

    getStory();

    _pagingController.addPageRequestListener((pageKey) {
      print("pageKey ===== $pageKey");
      tmppageKey = pageKey;
      otherUserReward(pageKey);
    });

    getuserid();
  }

  String? categorydropdownvalue;

  @override
  Widget build(BuildContext context) {
    var categorydroparray = [
      Languages.of(context)!.hairsalonText,
      Languages.of(context)!.estheticsText,
      Languages.of(context)!.medicoestheticText,
      Languages.of(context)!.nailsspaText,
      Languages.of(context)!.tatooText,
      Languages.of(context)!.barbershopText,
      Languages.of(context)!.spafacilityText,
      Languages.of(context)!.messagesText,
      Languages.of(context)!.plasticsurgeryText,
      Languages.of(context)!.lashesandbrowsText,
      Languages.of(context)!.othersText,
    ];
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: PgAppBar.logo(
          actions: [
            PgAppBarAction(
              icon: PhosphorIconsRegular.magnifyingGlass,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchForHomeScreen(),
                  ),
                );
              },
            ),
            PgAppBarAction(
              icon: PhosphorIconsRegular.mapPin,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GooglemapPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: salonlistArray.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            overlayColor: const WidgetStatePropertyAll(
                              AppColors.kAppBArBGColor,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfileScreen(
                                        userId: salonlistArray[index].id.toString(),
                                        userType:
                                            salonlistArray[index].userType
                                                .toString(),
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: AppColors.kBorderColor,
                                  ),
                                  top: BorderSide(
                                    width: 2,
                                    color: AppColors.kBorderColor,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    salonlistArray[index].profileImage != ""
                                        ? Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                            // color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              "${API.baseUrl}/api/${salonlistArray[index].profileImage!}",
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
                                                          AppColors.textPrimary,
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
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                        : Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            // color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: const Icon(Icons.person),
                                          ),
                                        ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${salonlistArray[index].salonName!}",
                                            // salonlistArray[index].salonName !=
                                            //         null
                                            //     ? salonlistArray[index]
                                            //         .salonName!
                                            //     : "-",
                                            style:
                                                AppTypography.heading3,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                salonlistArray[index]
                                                    .averageRating!
                                                    .toStringAsFixed(1),
                                                style:
                                                    AppTypography.caption.copyWith(color: AppColors.klightGreyColor),
                                              ),
                                              const SizedBox(width: 4),
                                              RatingBarIndicator(
                                                rating: double.parse(
                                                  salonlistArray[index]
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
                                                      color:
                                                          AppColors.actionPrimary,
                                                    ),
                                              ),
                                              Text(
                                                " (${salonlistArray[index].ratingCount.toString()})",
                                                style:
                                                    AppTypography.caption.copyWith(color: AppColors.klightGreyColor),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(ImageUtils.daysImage),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  salonlistArray[index]
                                                              .openDays !=
                                                          null
                                                      ? salonlistArray[index]
                                                          .openDays!
                                                      : "-",
                                                  style:
                                                      AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.drktxtGrey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(ImageUtils.timeImage),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  salonlistArray[index]
                                                              .openTime !=
                                                          null
                                                      ? salonlistArray[index]
                                                          .openTime!
                                                      : "-",
                                                  style:
                                                      AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.drktxtGrey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(
                                                ImageUtils.phoneImage,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  salonlistArray[index]
                                                              .contactNo !=
                                                          null
                                                      ? salonlistArray[index]
                                                          .contactNo!
                                                      : "-",
                                                  style:
                                                      AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.drktxtGrey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(
                                                ImageUtils.websiteImage,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  salonlistArray[index]
                                                              .siteName !=
                                                          null
                                                      ? salonlistArray[index]
                                                          .siteName!
                                                      : "-",
                                                  style:
                                                      AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.drktxtGrey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          (salonlistArray[index].address ==
                                                      null ||
                                                  salonlistArray[index]
                                                      .address!
                                                      .isEmpty)
                                              ? Container()
                                              : Row(
                                                children: [
                                                  Image.asset(
                                                    ImageUtils.mapsmallImage,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      salonlistArray[index]
                                                                  .address !=
                                                              null
                                                          ? salonlistArray[index]
                                                              .address!
                                                          : "-",
                                                      style:
                                                          AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.drktxtGrey),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
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
    );
  }

  Future<void> CommentBottomSheet(
    BuildContext context,
    Size kSize,
    int index,
    items,
  ) {
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
                color: AppColors.bgPrimary,
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
                                        style: AppTypography.heading2.copyWith(fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                items.comments!.isNotEmpty
                                    ? SizedBox(
                                      height: kSize.height / 1.55,
                                      width: kSize.width,
                                      child: ListView.builder(
                                        itemCount: items.comments!.length,
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
                                                items
                                                            .comments![cindex]
                                                            .profileImage !=
                                                        ""
                                                    ? Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                            "${API.baseUrl}/api/${items.comments![cindex].profileImage!}",
                                                          ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.5,
                                                            ),
                                                      ),
                                                    )
                                                    : Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.5,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.person,
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
                                                        InkWell(
                                                          onTap: () {
                                                            print(
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => ProfileScreen(
                                                                        userId:
                                                                            items.comments![cindex].appUserId.toString(),
                                                                        userType:
                                                                            items.comments![cindex].userType.toString(),
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            "${items.comments![cindex].firstName.toString()} ${items.comments![cindex].lastName.toString()}",
                                                            style:
                                                                AppTypography.bodySemiBold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          getpostTime(
                                                            items
                                                                .comments![cindex]
                                                                .createdAt!,
                                                          ),
                                                          style:
                                                              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      items
                                                          .comments![cindex]
                                                          .comment
                                                          .toString(),
                                                      style:
                                                          AppTypography.body,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : SizedBox(
                                      height: ((kSize.height * 85) / 100) / 2,
                                      child: Center(
                                        child: Text(
                                          Languages.of(
                                            context,
                                          )!.NoCommentsavailableText,
                                          style:
                                              AppTypography.heading2.copyWith(fontSize: 20),
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
                          style: AppTypography.input,
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
                                    items.id.toString(),
                                    commentcontroller.text,
                                  );
                                  commentcontroller.text = "";
                                }
                              },
                              child: const Icon(Icons.send),
                            ),
                            fillColor: AppColors.bgPrimary,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            hintText: Languages.of(context)!.sendcommentText,
                            hintStyle: AppTypography.input,
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
                                color: AppColors.actionPrimary,
                              ),
                            ),
                            focusColor: AppColors.actionPrimary,
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

  void _openSalonDetails(BuildContext context, String tag) {
    // Check if the tag exists in the tagToIdMap
    if (tagToIdMap.containsKey(tag)) {
      int id = tagToIdMap[tag]!;
      print('Tapped on tag: $tag with ID: $id');

      // Navigate to the salon details screen using Navigator.push
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProfileScreen(userId: id.toString(), userType: "1"),
        ),
      );
    } else {
      print('Tag not found in map');
    }
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
            style: AppTypography.bodySemiBold.copyWith(
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
          TextSpan(text: '$word ', style: AppTypography.body.copyWith(color: AppColors.drktxtGrey)),
        );
      }
    }

    return TextSpan(children: textSpans);
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
            return SizedBox(
              height: kSize.height / 1.5,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
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
                                          style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : SizedBox(
                              width: kSize.width,
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.NouserfoundText,
                                  style: AppTypography.heading3.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                  ),
                  if (usersList.any((user) => user['isSelected'] ?? false))
                    Container(
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
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
                            style: AppTypography.bodySemiBold.copyWith(color: AppColors.bgPrimary),
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

  Future<void> moreOptionBottomsheet(BuildContext context, Size kSize) {
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
            return SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle_outlined,
                            color: Colors.black,
                            size: 35,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            Languages.of(context)!.ViewProfileText,
                            style: AppTypography.heading2.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  getSalonList(String selectValue) async {
    print("getSalonList function called with selectValue: $selectValue");
    print("get getSalonList function call");
    setState(() {
      isLoading = true;
    });
    //ask for location permission
    await Permission.location.request();
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SalonListViewModel>(
          context,
          listen: false,
        ).getSalonList(userid);
        if (Provider.of<SalonListViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<SalonListViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            markers.clear();
            setState(() {
              isLoading = false;
              setState(() {});

              print("Success");
              GetSalonListModel model =
                  Provider.of<SalonListViewModel>(
                        context,
                        listen: false,
                      ).salonlistresponse.response
                      as GetSalonListModel;

              salonlistArray = model.salonList!;
              salonlistArray!.removeWhere(
                (element) => element.salonName!.isEmpty,
              );
              print("Total salons received: ${salonlistArray.length}");

              // List filteredSalons =
              //     salonlistArray.where((element) {
              //       return element.category?.toLowerCase() ==
              //           selectValue.toLowerCase();
              //     }).toList();

              List<SalonList> filteredSalons =
                  selectValue.isEmpty
                      ? salonlistArray
                      : salonlistArray.where((element) {
                        return element.category?.toLowerCase() ==
                            selectValue.toLowerCase();
                      }).toList();

              filteredSalons.removeWhere(
                (element) =>
                    (element.latitude!.isEmpty && element.longitude!.isEmpty),
              );

              print("Filtered salons count: ${filteredSalons.length}");
              if (filteredSalons.isEmpty) {
                kToast(
                  "Your selected category salon no found. \nPlease try different category.",
                );
              } else {
                filteredSalons.forEach((element) {
                  if (element.latitude != "" && element.longitude != "") {
                    if (element.latitude == "0.0" &&
                        element.longitude == "0.0") {
                    } else {
                      print("in else");
                      double latitude = double.parse(
                        element.latitude.toString(),
                      );
                      double longitude = double.parse(
                        element.longitude.toString(),
                      );
                      addMarker(
                        LatLng(
                          double.parse(latitude.toString()),
                          double.parse(longitude.toString()),
                        ),
                        element.salonName!,
                        element.openDays!,
                        element.id.toString(),
                      );
                    }
                  }
                });
              }

              if (markers.isNotEmpty) {
                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    markers.first.position,
                    18.0,
                  ), // Zoom level 14
                );
              }

              setState(() {});
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

  doCommentPost(
    String app_user_id,
    String salon_post_id,
    String comment,
  ) async {
    print("get doCommentPost function call");
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
                    builder: (context) => BottomNavBar(index: 0),
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
            // setState(() {
            // isLoading = false;
            print("Success");
            PostLikeModel model =
                Provider.of<PostLikeViewModel>(
                      context,
                      listen: false,
                    ).postlikeresponse.response
                    as PostLikeModel;

            if (model.success == true) {
              // _pagingController.addPageRequestListener((pageKey) async {
              //   await _fetchPageActivity(pageKey);
              // });
              // likeCount.removeAt(index);
              // likeCount.insert(index, model.likeCount!);
              // print("likecount == ${likeCount}");
            }

            kToast(model.message!);
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

  getStory() async {
    print("get getStory function call");
    setState(() {
      isLoading = true;
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
            otherArray.clear();

            // setState(() {
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
              } else {
                // Check if the user already exists
                final existingUserIndex = otherArray.indexWhere(
                  (user) => user['user_id'] == story.userId,
                );

                if (existingUserIndex == -1) {
                  // If user doesn't exist, add them
                  otherArray.add({
                    'user_id': story.userId,
                    'first_name': story.firstName,
                    'last_name': story.lastName,
                    'salonName': story.salonName,
                    'profile_image': story.profileImage,
                    'firebaseid': story.firebaseId,
                    'stories': [
                      {'image': story.storyData},
                    ],
                  });
                } else {
                  // If user exists, update their stories
                  otherArray[existingUserIndex]['stories'].add({
                    'image': story.storyData,
                  });
                }
              }
              print("My Stories: ${myStoryArray.length}");
              print("My Stories: ${myStoryArray.toList().toString()}");
              print("Other Stories: ${otherArray.length}");
              print("Other Stories: ${otherArray.toList()}");
              setState(() {});
            }
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

  void _showReportUserAlertDialog(String frdId, String type, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: StatefulBuilder(
            builder: (context, setAState) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.start,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Colors.white,
                alignment: Alignment.center,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.only(left: 10, right: 10),
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            type == "report"
                                ? Languages.of(context)!.reportalertmsgText
                                : Languages.of(context)!.blockalertmsgText,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(fontSize: 17),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (type == "report") {
                                    await reportPost(userid, frdId);
                                    Navigator.pop(context);
                                  } else {
                                    await blockPost(userid, frdId, index);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.actionPrimary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      type == "report"
                                          ? Languages.of(context)!.reportText
                                          : Languages.of(context)!.blockText,
                                      style: AppTypography.bodySemiBold.copyWith(color: AppColors.bgPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.actionPrimary,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.cancelText,
                                      style: AppTypography.bodySemiBold.copyWith(color: AppColors.actionPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  reportPost(String userId, String postId) async {
    print("get doPostLike function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<BlockUserViewModel>(
          context,
          listen: false,
        ).reportPost(userId, postId);
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
                    ).reportresponse.response
                    as PostDeleteModel;

            kToast(model.message!);
            setState(() {
              isLoading = false;
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

  blockPost(String userId, String blockUserId, int index) async {
    print("get blockPost function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<BlockUserViewModel>(
          context,
          listen: false,
        ).blockPost(userId, blockUserId);
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
                    ).blockuserresponse.response
                    as PostDeleteModel;
            kToast(model.message!);
            final currentPosts = _pagingController.value.itemList;
            print(
              "_pagingController.value.itemList == ${_pagingController.value.itemList}",
            );
            print("currentPosts == $currentPosts");
            print("currentPosts length == ${currentPosts!.length}");
            print("index == ${index}");
            if (currentPosts != null && index < currentPosts.length) {
              currentPosts.removeAt(index);
            }
            setState(() {
              isLoading = false;
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

  //   userReportAPI(String frdId, String reason) async {
  //     print("userReportAPI function call");
  //     setState(() {
  //       isReqLoading = true;
  //     });
  //     getuserid();
  //     isInternetAvailable().then((isConnected) async {
  //       if (isConnected) {
  //         await Provider.of<UserReportViewModel>(context, listen: false)
  //             .userReportAPI(userid, frdId, reason);
  //         if (Provider.of<UserReportViewModel>(context, listen: false)
  //                 .isLoading ==
  //             false) {
  //           if (Provider.of<UserReportViewModel>(context, listen: false)
  //                   .isSuccess ==
  //               true) {
  //             setState(() {
  //               isReqLoading = false;
  //               print("Success");
  //               ForgotPasswordResponseModel model =
  //                   Provider.of<UserReportViewModel>(context, listen: false)
  //                       .userreportresponse
  //                       .response as ForgotPasswordResponseModel;
  //               showToast(model.message!);
  //             });
  //           } else {
  //             setState(() {
  //               isReqLoading = false;
  //             });
  //             showToast(Provider.of<UserReportViewModel>(context, listen: false)
  //                 .userreportresponse
  //                 .msg
  //                 .toString());
  //           }
  //         }
  //       } else {
  //         setState(() {
  //           isReqLoading = false;
  //         });
  //         showToast(Languages.of(context)!.nointernettxt);
  //       }
  //     });
  //   }

  //   userBlockAPI(String frdId, String isBlock, int index) async {
  //     print("userBlockAPI function call");
  //     setState(() {
  //       isReqLoading = true;
  //     });
  //     getuserid();
  //     isInternetAvailable().then((isConnected) async {
  //       if (isConnected) {
  //         await Provider.of<UserReportViewModel>(context, listen: false)
  //             .userBlockAPI(userid, frdId, isBlock);
  //         if (Provider.of<UserReportViewModel>(context, listen: false)
  //                 .isLoading ==
  //             false) {
  //           if (Provider.of<UserReportViewModel>(context, listen: false)
  //                   .isSuccess ==
  //               true) {
  //             setState(() {
  //               isReqLoading = false;
  //               print("Success");
  //               ForgotPasswordResponseModel model =
  //                   Provider.of<UserReportViewModel>(context, listen: false)
  //                       .userblockresponse
  //                       .response as ForgotPasswordResponseModel;
  //               showToast(model.message!);
  //               likedFeedData.removeAt(index);
  //             });
  //           } else {
  //             setState(() {
  //               isReqLoading = false;
  //             });
  //             kToast(Provider.of<UserReportViewModel>(context, listen: false)
  //                 .userblockresponse
  //                 .msg
  //                 .toString());
  //           }
  //         }
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //         });
  // kToast(Languages.of(context)!.noInternetText);      }
  //     });
  //   }
}
