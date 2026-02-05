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
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/salonlistviewmodel.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/salonlistmodel.dart';
import '../../utils/imagesutils.dart';
import '../HomeScreens/notifications.dart';

class MackeupsScreen extends StatefulWidget {
  const MackeupsScreen({super.key});

  @override
  State<MackeupsScreen> createState() => _MackeupsScreenState();
}

class _MackeupsScreenState extends State<MackeupsScreen>
    with TickerProviderStateMixin {
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
  late final TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
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
                    (context) => SalonDetailScreen(id: salonid, userType: "2"),
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
    _tabController = TabController(length: 3, vsync: this);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.kWhiteColor,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.kAppBArBGColor,
          automaticallyImplyLeading: false,
          elevation: 2.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 50, child: Image.asset(ImageUtils.appbarlogo)),
              Row(
                children: [
                  InkWell(
                    overlayColor: const WidgetStatePropertyAll(
                      AppColors.kWhiteColor,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchForHomeScreen(),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: Image.asset(ImageUtils.searchimg),
                    ),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    overlayColor: const WidgetStatePropertyAll(
                      AppColors.kWhiteColor,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GooglemapPage(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(
                            ImageUtils.mapImage,
                            color: AppColors.kBlackColor,
                          ),
                        ),
                        // Positioned(
                        //   left: 13,
                        //   top: 0,
                        //   child: Container(
                        //     height: 10,
                        //     width: 10,
                        //     decoration: BoxDecoration(
                        //       color: AppColors.kPinkColor,
                        //       borderRadius: BorderRadius.circular(5),
                        //     ),
                        //     // child: const Center(
                        //     //   child: Text(
                        //     //     "1",
                        //     //     style: TextStyle(color: Colors.white),
                        //     //   ),
                        //     // ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Platform.isIOS
                //     ?
                SizedBox(
                  height: 50,
                  child: Center(
                    child: TabBar(
                      overlayColor: const WidgetStatePropertyAll(
                        AppColors.kAppBArBGColor,
                      ),
                      controller: _tabController,
                      indicatorColor: AppColors.kPinkColor,
                      labelColor: AppColors.kBlackColor,
                      unselectedLabelStyle: Pallete.Quicksand16drkBlackBold,
                      labelStyle: Pallete.Quicksand16drkBlackBold,
                      physics: AlwaysScrollableScrollPhysics(),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.asset(ImageUtils.listicon),
                          ),
                        ),
                        // Tab(
                        //   child: SizedBox(
                        //     height: 30,
                        //     width: 30,
                        //     child: Image.asset(ImageUtils.mapImage),
                        //   ),
                        // ),
                        Tab(
                          child: SizedBox(
                            height: 130,
                            width: 130,
                            child: Image.asset(
                              ImageUtils.rewardImage,
                              color: AppColors.kTextColor,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // : Container(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      ListView.builder(
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
                                      (context) => SalonDetailScreen(
                                        id: salonlistArray[index].id.toString(),
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
                                                Pallete.Quicksand16drkBlackBold,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                salonlistArray[index]
                                                    .averageRating!
                                                    .toStringAsFixed(1),
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe400,
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
                                                          AppColors.kPinkColor,
                                                    ),
                                              ),
                                              Text(
                                                " (${salonlistArray[index].ratingCount.toString()})",
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe400,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(ImageUtils.daysImage),
                                              const SizedBox(width: 8),
                                              Text(
                                                salonlistArray[index]
                                                            .openDays !=
                                                        null
                                                    ? salonlistArray[index]
                                                        .openDays!
                                                    : "-",
                                                style:
                                                    Pallete
                                                        .Quicksand10darkGreykwe500,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Image.asset(ImageUtils.timeImage),
                                              const SizedBox(width: 8),
                                              Text(
                                                salonlistArray[index]
                                                            .openTime !=
                                                        null
                                                    ? salonlistArray[index]
                                                        .openTime!
                                                    : "-",
                                                style:
                                                    Pallete
                                                        .Quicksand10darkGreykwe500,
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
                                              Text(
                                                salonlistArray[index]
                                                            .contactNo !=
                                                        null
                                                    ? salonlistArray[index]
                                                        .contactNo!
                                                    : "-",
                                                style:
                                                    Pallete
                                                        .Quicksand10darkGreykwe500,
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
                                              Text(
                                                salonlistArray[index]
                                                            .siteName !=
                                                        null
                                                    ? salonlistArray[index]
                                                        .siteName!
                                                    : "-",
                                                style:
                                                    Pallete
                                                        .Quicksand10darkGreykwe500,
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
                                                          Pallete
                                                              .Quicksand10darkGreykwe500,
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
                      // Platform.isIOS
                      //     ?
                      // SizedBox(
                      //   height: 300,
                      //   width: 200,
                      //   child: Stack(
                      //     children: [
                      //       GoogleMap(
                      //         key: ValueKey(markers.length),
                      //         // gestureRecognizers: Set()
                      //         //   ..add(Factory<PanGestureRecognizer>(
                      //         //       () => PanGestureRecognizer()))
                      //         //   ..add(Factory<ScaleGestureRecognizer>(
                      //         //       () => ScaleGestureRecognizer()))
                      //         //   ..add(Factory<TapGestureRecognizer>(
                      //         //       () => TapGestureRecognizer())),
                      //         gestureRecognizers:
                      //             <
                      //               Factory<OneSequenceGestureRecognizer>
                      //             >{}, // optional
                      //         markers: Set.from(markers),
                      //         myLocationButtonEnabled: false,
                      //         myLocationEnabled: true,
                      //         initialCameraPosition: CameraPosition(
                      //           target:
                      //               markers.isEmpty
                      //                   ? const LatLng(0, 0)
                      //                   : LatLng(
                      //                     markers.first.position.latitude,
                      //                     markers.first.position.longitude,
                      //                   ),
                      //           zoom: 18.0,
                      //         ),
                      //         mapType: MapType.normal,
                      //         onMapCreated: (controller) {
                      //           setState(() {
                      //             mapController = controller;
                      //           });
                      //         },
                      //       ),
                      //       Container(
                      //         height: 40,
                      //         width: 200,
                      //         margin: const EdgeInsets.only(top: 10, left: 10),
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(12),
                      //           border: Border.all(
                      //             width: 2,
                      //             color: AppColors.kBlackColor,
                      //           ),
                      //         ),
                      //         child: DropdownButtonHideUnderline(
                      //           child: DropdownButton2<String>(
                      //             isExpanded: true,
                      //             hint: Row(
                      //               children: [
                      //                 Expanded(
                      //                   child: Text(
                      //                     Languages.of(context)!.categoriesText,
                      //                     style: Pallete.Quicksand12blackwe500,
                      //                     overflow: TextOverflow.ellipsis,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             items:
                      //                 categorydroparray
                      //                     .map(
                      //                       (
                      //                         String item,
                      //                       ) => DropdownMenuItem<String>(
                      //                         value: item,
                      //                         child: Text(
                      //                           item,
                      //                           style:
                      //                               Pallete
                      //                                   .Quicksand12blackwe500,
                      //                           overflow: TextOverflow.ellipsis,
                      //                         ),
                      //                       ),
                      //                     )
                      //                     .toList(),
                      //             value: categorydropdownvalue,
                      //             onChanged: (String? value) {
                      //               setState(() {
                      //                 getSalonList(value!);
                      //                 categorydropdownvalue = value;
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      //third tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            PagedListView<int, OtherUserPost>(
                              shrinkWrap: true,
                              pagingController: _pagingController,
                              physics: NeverScrollableScrollPhysics(),
                              builderDelegate: PagedChildBuilderDelegate<
                                OtherUserPost
                              >(
                                itemBuilder: (context, item, index) {
                                  return Container(
                                    // decoration: const BoxDecoration(
                                    //     border: Border(
                                    //         bottom: BorderSide(
                                    //             width: 2, color: AppColors.kBorderColor))
                                    //             ),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (item
                                                          .story!
                                                          .isNotEmpty) {
                                                        if (firebaseId ==
                                                            item
                                                                .story![index]
                                                                .firebaseId) {
                                                          print("ifff ");
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
                                                                        item.firstName ??
                                                                        "",
                                                                    lastname:
                                                                        item.lastName ??
                                                                        "",
                                                                    img:
                                                                        item.profileImage ??
                                                                        "",
                                                                    salonanme:
                                                                        item.salonName ??
                                                                        "",
                                                                  ),
                                                            ),
                                                          ).then((value) {
                                                            getStory();
                                                          });
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => SingleUserStoryView(
                                                                    storyOtherHomeData:
                                                                        item.story!,
                                                                    myFireabseiD:
                                                                        firebaseId,
                                                                    firstname:
                                                                        item.firstName!,
                                                                    lastname:
                                                                        item.lastName!,
                                                                    profileimage:
                                                                        "${API.baseUrl}/api/${item.profileImage!}",
                                                                    salonname:
                                                                        item.salonName!,
                                                                    type:
                                                                        "Home",
                                                                  ),
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => SalonDetailScreen(
                                                                  id:
                                                                      item.userId
                                                                          .toString(),
                                                                  userType:
                                                                      item.userType
                                                                          .toString(),
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child:
                                                        item.profileImage != ""
                                                            ? Container(
                                                              height: 45,
                                                              width: 45,
                                                              decoration:
                                                                  item
                                                                          .story!
                                                                          .isNotEmpty
                                                                      ? const BoxDecoration(
                                                                        shape:
                                                                            BoxShape.circle,
                                                                        gradient: LinearGradient(
                                                                          colors: [
                                                                            AppColors.kPinkColor,
                                                                            AppColors.kPinkColor,
                                                                          ],
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end:
                                                                              Alignment.bottomRight,
                                                                        ),
                                                                      )
                                                                      : const BoxDecoration(
                                                                        shape:
                                                                            BoxShape.circle,
                                                                      ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2.0,
                                                                  ),
                                                              child: CircleAvatar(
                                                                radius: 50,
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey[300],
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                      "${API.baseUrl}/api/${item.profileImage}",
                                                                    ),
                                                              ),
                                                            )
                                                            : Container(
                                                              height: 45,
                                                              width: 45,
                                                              decoration:
                                                                  item
                                                                          .story!
                                                                          .isNotEmpty
                                                                      ? const BoxDecoration(
                                                                        shape:
                                                                            BoxShape.circle,
                                                                        gradient: LinearGradient(
                                                                          colors: [
                                                                            AppColors.kPinkColor,
                                                                            AppColors.kPinkColor,
                                                                          ],
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end:
                                                                              Alignment.bottomRight,
                                                                        ),
                                                                      )
                                                                      : const BoxDecoration(
                                                                        shape:
                                                                            BoxShape.circle,
                                                                      ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2.0,
                                                                  ),
                                                              child: CircleAvatar(
                                                                radius: 50,
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey[300],
                                                                child: const Icon(
                                                                  Icons.person,
                                                                ),
                                                              ),
                                                            ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  item.userType == 1
                                                      //  && item.beforeImage != ""
                                                      ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => SalonDetailScreen(
                                                                        id:
                                                                            item.userId.toString(),
                                                                        userType:
                                                                            item.userType.toString(),
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              item
                                                                      .userName!
                                                                      .isNotEmpty
                                                                  ? item
                                                                      .userName!
                                                                  : "${item.firstName!} ${item.lastName!}",
                                                              style:
                                                                  Pallete
                                                                      .Quicksand14blackwe600,
                                                            ),
                                                          ),
                                                          item.beforeImage != ""
                                                              ? InkWell(
                                                                onTap: () {
                                                                  print(
                                                                    "id  = ${item.userSalonId}",
                                                                  );
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => SalonDetailScreen(
                                                                            id:
                                                                                item.userSalonId.toString(),
                                                                            userType:
                                                                                "2",
                                                                          ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  item.salonName!,
                                                                  style:
                                                                      Pallete
                                                                          .Quicksand12Black54we600,
                                                                ),
                                                              )
                                                              : Container(),
                                                          item.beforeImage != ""
                                                              ? InkWell(
                                                                onTap: () {
                                                                  print(
                                                                    "id  = ${item.userSalonId}",
                                                                  );
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => SalonDetailScreen(
                                                                            id:
                                                                                item.userSalonId.toString(),
                                                                            userType:
                                                                                "2",
                                                                          ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      item.averageRating!
                                                                          .toStringAsFixed(
                                                                            1,
                                                                          ),
                                                                      style:
                                                                          Pallete
                                                                              .Quicksand12Greywe400,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    RatingBarIndicator(
                                                                      rating: double.parse(
                                                                        item.averageRating!
                                                                            .toString(),
                                                                      ),
                                                                      itemCount:
                                                                          5,
                                                                      itemSize:
                                                                          18.0,
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
                                                                                AppColors.kPinkColor,
                                                                          ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      "(${item.ratingCount.toString()})",
                                                                      style:
                                                                          Pallete
                                                                              .Quicksand12Greywe400,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                              : Container(),
                                                        ],
                                                      )
                                                      : InkWell(
                                                        onTap: () {
                                                          print("InkWell 123");
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => SalonDetailScreen(
                                                                    id:
                                                                        item.userId
                                                                            .toString(),
                                                                    userType:
                                                                        item.userType
                                                                            .toString(),
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item
                                                                      .userName!
                                                                      .isNotEmpty
                                                                  ? item
                                                                      .userName!
                                                                  : "${item.firstName!} ${item.lastName!}",
                                                              style:
                                                                  Pallete
                                                                      .Quicksand14blackwe600,
                                                            ),
                                                            Text(
                                                              item.salonName!,
                                                              style:
                                                                  Pallete
                                                                      .Quicksand12Black54we600,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  item.averageRating!
                                                                      .toStringAsFixed(
                                                                        1,
                                                                      ),
                                                                  style:
                                                                      Pallete
                                                                          .Quicksand12blackwe400,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                RatingBarIndicator(
                                                                  rating: double.parse(
                                                                    item.averageRating!
                                                                        .toString(),
                                                                  ),
                                                                  itemCount: 5,
                                                                  itemSize:
                                                                      18.0,
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
                                                                        Icons
                                                                            .star,
                                                                        color:
                                                                            AppColors.kPinkColor,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  "(${item.ratingCount.toString()})",
                                                                  style:
                                                                      Pallete
                                                                          .Quicksand12Greywe400,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                ],
                                              ),
                                              PopupMenuButton(
                                                color: AppColors.kWhiteColor,
                                                menuPadding: EdgeInsets.zero,
                                                onSelected: (value) {
                                                  if (value != null) {
                                                    if (value == "share") {
                                                      // final username = Uri.encodeComponent(
                                                      //     item.userName ?? "");
                                                      String name =
                                                          item
                                                                  .userName!
                                                                  .isNotEmpty
                                                              ? item.userName!
                                                              : "${item.firstName!} ${item.lastName!}";
                                                      showShareOptions(
                                                        context,
                                                        name,
                                                        item.userId.toString(),
                                                      );
                                                      // final String profileUrl =
                                                      //     'https://pinkmapdemo.com/profile/$username';
                                                      // Share.share(
                                                      //   'Check out $username\'s profile on PinkGossip: $profileUrl',
                                                      // );
                                                    } else if (value ==
                                                        "download") {
                                                      String fileUrl = "";
                                                      String fileName = "";
                                                      if (item.postType ==
                                                          "SalonReview") {
                                                        if (page == 1) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  ctx,
                                                                ) => AlertDialog(
                                                                  title: const Text(
                                                                    "Download",
                                                                  ),
                                                                  content: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: CommonWidget().getSmallButton(
                                                                              "Before Image",
                                                                              () {
                                                                                Navigator.of(
                                                                                  ctx,
                                                                                ).pop();
                                                                                String
                                                                                beforeImg =
                                                                                    "${API.baseUrl}/api/${item.beforeImage!}";
                                                                                String
                                                                                beforeImgName =
                                                                                    item.beforeImage!;
                                                                                CommonFunctions().downloadPhoto(
                                                                                  context,
                                                                                  beforeImg,
                                                                                  beforeImgName,
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Expanded(
                                                                            child: CommonWidget().getSmallButton(
                                                                              "After Image",
                                                                              () {
                                                                                Navigator.of(
                                                                                  ctx,
                                                                                ).pop();
                                                                                String
                                                                                afterImg =
                                                                                    "${API.baseUrl}/api/${item.afterImage!}";
                                                                                String
                                                                                beforeImgName =
                                                                                    item.beforeImage!;
                                                                                CommonFunctions().downloadPhoto(
                                                                                  context,
                                                                                  afterImg,
                                                                                  beforeImgName,
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          );
                                                        } else {
                                                          fileUrl =
                                                              "${API.baseUrl}/api/${item.otherMultiPost![0].otherData}" ??
                                                              "";
                                                          fileName =
                                                              item
                                                                  .otherMultiPost![0]
                                                                  .otherData
                                                                  .toString();
                                                          CommonFunctions()
                                                              .downloadPhoto(
                                                                context,
                                                                fileUrl,
                                                                fileName,
                                                              );
                                                        }
                                                      } else {
                                                        //
                                                        fileUrl =
                                                            "${API.baseUrl}/api/${item.otherMultiPost![0].otherData}" ??
                                                            "";
                                                        fileName =
                                                            item
                                                                .otherMultiPost![0]
                                                                .otherData
                                                                .toString();
                                                        CommonFunctions()
                                                            .downloadPhoto(
                                                              context,
                                                              fileUrl,
                                                              fileName,
                                                            );
                                                      }
                                                    } else {
                                                      _showReportUserAlertDialog(
                                                        value == "report"
                                                            ? item.id.toString()
                                                            : item.userId
                                                                .toString(),
                                                        value,
                                                        index,
                                                      );
                                                    }
                                                  }
                                                },
                                                onOpened: () {
                                                  print(
                                                    "userType ${item.userType} page $page postType ${item.postType}",
                                                  );
                                                  print(
                                                    "userType ${item.toJson()}",
                                                  );
                                                },
                                                icon: SizedBox(
                                                  height: 30,
                                                  width: 15,
                                                  child: Image.asset(
                                                    ImageUtils.moreoptionimg,
                                                  ),
                                                ),
                                                itemBuilder: (
                                                  BuildContext context,
                                                ) {
                                                  return [
                                                    PopupMenuItem<String>(
                                                      // padding: EdgeInsets.zero,
                                                      value: 'download',
                                                      child: Text(
                                                        Languages.of(
                                                          context,
                                                        )!.downlaodText,
                                                        style:
                                                            Pallete
                                                                .Quicksand14Blackw500,
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      // padding: EdgeInsets.zero,
                                                      value: 'share',
                                                      child: Text(
                                                        Languages.of(
                                                          context,
                                                        )!.shareText,
                                                        style:
                                                            Pallete
                                                                .Quicksand14Blackw500,
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      // padding: EdgeInsets.zero,
                                                      value: 'report',
                                                      child: Text(
                                                        Languages.of(
                                                          context,
                                                        )!.reportText,
                                                        style:
                                                            Pallete
                                                                .Quicksand14Blackw500,
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      // padding: EdgeInsets.zero,
                                                      value: 'block-user',
                                                      child: Text(
                                                        Languages.of(
                                                          context,
                                                        )!.blockText,
                                                        style:
                                                            Pallete
                                                                .Quicksand14Blackw500,
                                                      ),
                                                    ),
                                                  ];
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        item.userType == 1
                                            ? ExpandablePageView.builder(
                                              itemCount:
                                                  (item
                                                      .otherMultiPost!
                                                      .length) +
                                                  1,
                                              onPageChanged: (int pageIndex) {
                                                print(
                                                  "Current Page Index: $pageIndex",
                                                );
                                              },
                                              itemBuilder: (
                                                context,
                                                pageviewindex,
                                              ) {
                                                page = pageviewindex + 1;
                                                return Stack(
                                                  children: [
                                                    item.beforeImage != ""
                                                        ? ExpandablePageView.builder(
                                                          // controller: _pageController,
                                                          itemCount:
                                                              (item
                                                                  .otherMultiPost!
                                                                  .length) +
                                                              1,
                                                          onPageChanged: (
                                                            int pageIndex,
                                                          ) {
                                                            print(
                                                              "Current Page Index: $pageIndex",
                                                            );
                                                          },
                                                          itemBuilder: (
                                                            context,
                                                            pageviewindex,
                                                          ) {
                                                            page =
                                                                pageviewindex +
                                                                1;
                                                            return Stack(
                                                              children: [
                                                                pageviewindex ==
                                                                        0
                                                                    ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child: Container(
                                                                            color:
                                                                                Colors.black12,
                                                                            height:
                                                                                kSize.height /
                                                                                3,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(
                                                                                2.0,
                                                                              ),
                                                                              child: Image.network(
                                                                                loadingBuilder: (
                                                                                  BuildContext context,
                                                                                  Widget child,
                                                                                  ImageChunkEvent? loadingProgress,
                                                                                ) {
                                                                                  if (loadingProgress ==
                                                                                      null) {
                                                                                    return child;
                                                                                  }
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
                                                                                "${API.baseUrl}/api/${item.beforeImage!}",
                                                                                fit:
                                                                                    BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child: Container(
                                                                            height:
                                                                                kSize.height /
                                                                                3,
                                                                            color:
                                                                                Colors.black12,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(
                                                                                2.0,
                                                                              ),
                                                                              child: Image.network(
                                                                                loadingBuilder: (
                                                                                  BuildContext context,
                                                                                  Widget child,
                                                                                  ImageChunkEvent? loadingProgress,
                                                                                ) {
                                                                                  if (loadingProgress ==
                                                                                      null) {
                                                                                    return child;
                                                                                  }
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
                                                                                "${API.baseUrl}/api/${item.afterImage!}",
                                                                                fit:
                                                                                    BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                    : Container(
                                                                      child:
                                                                          item
                                                                                      .otherMultiPost![pageviewindex -
                                                                                          1]
                                                                                      .otherData!
                                                                                      .endsWith(
                                                                                        '.mp4',
                                                                                      ) ||
                                                                                  item
                                                                                      .otherMultiPost![pageviewindex -
                                                                                          1]
                                                                                      .otherData!
                                                                                      .endsWith('.mov')
                                                                              ? MyVideoPlayer(
                                                                                videoUrl:
                                                                                    "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex - 1].otherData}",
                                                                              )
                                                                              : SizedBox(
                                                                                height:
                                                                                    item.postType ==
                                                                                            "NormalPost"
                                                                                        ? kSize.height /
                                                                                            2
                                                                                        : kSize.height /
                                                                                            3,
                                                                                width:
                                                                                    kSize.width,
                                                                                child: Image.network(
                                                                                  fit:
                                                                                      BoxFit.cover,
                                                                                  "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex - 1].otherData}",
                                                                                  loadingBuilder: (
                                                                                    BuildContext context,
                                                                                    Widget child,
                                                                                    ImageChunkEvent? loadingProgress,
                                                                                  ) {
                                                                                    if (loadingProgress ==
                                                                                        null) {
                                                                                      return child;
                                                                                    }
                                                                                    return Center(
                                                                                      child: SizedBox(
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
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                    ),
                                                                item
                                                                        .otherMultiPost!
                                                                        .isEmpty
                                                                    ? Container()
                                                                    : Positioned(
                                                                      top: 10.0,
                                                                      right: 10,
                                                                      child: Container(
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            35,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.black54,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12.5,
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        child: Center(
                                                                          child: Text(
                                                                            "${pageviewindex + 1}/${item.otherMultiPost!.length + 1}",
                                                                            style: const TextStyle(
                                                                              color:
                                                                                  Colors.white,
                                                                              fontSize:
                                                                                  12.0,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
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
                                                              (item
                                                                  .otherMultiPost!
                                                                  .length),
                                                          onPageChanged: (
                                                            int pageIndex,
                                                          ) {
                                                            print(
                                                              "Current Page Index: $pageIndex",
                                                            );
                                                          },
                                                          itemBuilder: (
                                                            context,
                                                            pageviewindex,
                                                          ) {
                                                            return Stack(
                                                              children: [
                                                                Container(
                                                                  child:
                                                                      item.otherMultiPost![pageviewindex].otherData!.endsWith(
                                                                                '.mp4',
                                                                              ) ||
                                                                              item.otherMultiPost![pageviewindex].otherData!.endsWith('.mov')
                                                                          ? MyVideoPlayer(
                                                                            videoUrl:
                                                                                "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex].otherData}",
                                                                          )
                                                                          : SizedBox(
                                                                            height:
                                                                                item.postType ==
                                                                                        "NormalPost"
                                                                                    ? kSize.height /
                                                                                        2
                                                                                    : kSize.height /
                                                                                        3,
                                                                            width:
                                                                                kSize.width,
                                                                            child: Image.network(
                                                                              "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex].otherData}",
                                                                              fit:
                                                                                  BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                ),

                                                                /// 🔹 IMAGE / VIDEO UPAR TEXT

                                                                /// 🔹 PAGE INDICATOR
                                                                item.otherMultiPost!.length >
                                                                        1
                                                                    ? Positioned(
                                                                      top: 10,
                                                                      right: 10,
                                                                      child: Container(
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            35,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.black54,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12.5,
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child: Text(
                                                                          "${pageviewindex + 1}/${item.otherMultiPost!.length}",
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                    : const SizedBox(),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                  ],
                                                );
                                              },
                                            )
                                            : item.otherMultiPost!.isEmpty
                                            ? Container(
                                              height: kSize.height / 3,
                                              width: kSize.width,
                                              color: Colors.black12,
                                              child: Center(
                                                child: Text(
                                                  "No media found",
                                                  style:
                                                      Pallete
                                                          .Quicksand16drktxtGreywe500,
                                                ),
                                              ),
                                            )
                                            : ExpandablePageView.builder(
                                              itemCount:
                                                  item.otherMultiPost!.length,
                                              onPageChanged: (int pageIndex) {
                                                print(
                                                  "Current Page Index: $pageIndex",
                                                );
                                              },
                                              itemBuilder: (
                                                context,
                                                pageviewindex,
                                              ) {
                                                page = pageviewindex + 1;
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      child:
                                                          item
                                                                      .otherMultiPost![pageviewindex]
                                                                      .otherData!
                                                                      .endsWith(
                                                                        '.mp4',
                                                                      ) ||
                                                                  item
                                                                      .otherMultiPost![pageviewindex]
                                                                      .otherData!
                                                                      .endsWith(
                                                                        '.mov',
                                                                      )
                                                              ? MyVideoPlayer(
                                                                videoUrl:
                                                                    "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex].otherData}",
                                                              )
                                                              : SizedBox(
                                                                height:
                                                                    item.postType ==
                                                                            "NormalPost"
                                                                        ? kSize.height /
                                                                            2
                                                                        : kSize.height /
                                                                            3,
                                                                width:
                                                                    kSize.width,
                                                                child: Image.network(
                                                                  "${API.baseUrl}/api/${item.otherMultiPost![pageviewindex].otherData}",
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
                                                                        null) {
                                                                      return child;
                                                                    }
                                                                    return Center(
                                                                      child: SizedBox(
                                                                        height:
                                                                            100,
                                                                        width:
                                                                            100,
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

                                                    /// 🔹 TEXT OVER IMAGE / VIDEO
                                                    Positioned(
                                                      top:
                                                          20, // top: 20 karso to upar aavse
                                                      // left: 15,
                                                      // right: 15,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 25,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                AppColors
                                                                    .kPinkColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            item.reward_tag
                                                                .toString(),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    item
                                                                .otherMultiPost!
                                                                .length ==
                                                            1
                                                        ? Container()
                                                        : Positioned(
                                                          top: 10.0,
                                                          right: 10,
                                                          child: Container(
                                                            height: 20,
                                                            width: 35,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .black54,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12.5,
                                                                  ),
                                                            ),
                                                            alignment:
                                                                Alignment
                                                                    .topRight,
                                                            child: Center(
                                                              child: Text(
                                                                "${pageviewindex + 1}/${item.otherMultiPost!.length}",
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  ],
                                                );
                                              },
                                            ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  // title: const Text("Confirm"),
                                                  content: Text(
                                                    "Are you sure you want to redeem this offer,${item.revardPoint} points will be deducted from your account",
                                                    style:
                                                        Pallete
                                                            .Quicksand15blackwe600,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                        ); // dialog close
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style:
                                                            Pallete
                                                                .Quicksand15blackwe600,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // dialog close

                                                        print(
                                                          "userTyppe===$userTyppe",
                                                        );

                                                        if (userTyppe == "1") {
                                                          // API call
                                                          redeemStorePost(
                                                            userid,
                                                            item.id.toString(),
                                                            item.revardPoint
                                                                .toString(),
                                                          );

                                                          // Toast
                                                          Fluttertoast.showToast(
                                                            msg:
                                                                "Points redeemed successfully",
                                                            toastLength:
                                                                Toast
                                                                    .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        } else {
                                                          // Not Gossiper alert
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title:
                                                                    const Text(
                                                                      "Alert",
                                                                    ),
                                                                content: const Text(
                                                                  "Only Gossiper accounts can redeem rewards",
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                      "OK",
                                                                      style:
                                                                          Pallete
                                                                              .Quicksand15blackwe600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Text(
                                                        "OK",
                                                        style:
                                                            Pallete
                                                                .Quicksand15blackwe600,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: AppColors.kPinkColor,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Redeem Now",
                                                    style: Pallete
                                                        .Quicksand15blackwe600.copyWith(
                                                      color:
                                                          AppColors.kWhiteColor,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${item.revardPoint} Points",
                                                        style: Pallete
                                                            .Quicksand14blackwe600.copyWith(
                                                          color:
                                                              AppColors
                                                                  .kWhiteColor,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 30),
                                                      const Icon(
                                                        Icons
                                                            .arrow_forward_ios_outlined,
                                                        color:
                                                            AppColors
                                                                .kWhiteColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                // key: index == 0
                                                //     ? widget.likepostKey
                                                //     : UniqueKey(),
                                                onTap: () async {
                                                  if (item.like == 1) {
                                                    item.like = 0;
                                                    item.likeCount =
                                                        item.likeCount! - 1;
                                                    await doPostLike(
                                                      userid,
                                                      item.id!.toString(),
                                                      "0",
                                                      index,
                                                    );
                                                  } else {
                                                    item.like = 1;
                                                    item.likeCount =
                                                        item.likeCount! + 1;
                                                    await doPostLike(
                                                      userid,
                                                      item.id!.toString(),
                                                      "1",
                                                      index,
                                                    );
                                                  }

                                                  print(
                                                    "item.likeCount after ===  ${item.likeCount}",
                                                  );
                                                  setState(() {});
                                                },
                                                child:
                                                    item.like == 1
                                                        ? Container(
                                                          height: 20,
                                                          width: 20,
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: const Icon(
                                                            Icons.favorite,
                                                            color:
                                                                AppColors
                                                                    .kPinkColor,
                                                          ),
                                                        )
                                                        : const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: Icon(
                                                            Icons
                                                                .favorite_outline,
                                                            color:
                                                                AppColors
                                                                    .kBlackColor,
                                                          ),
                                                        ),
                                              ),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                // key: widget.commentKey,
                                                height: 30,
                                                width: 40,
                                                child: InkWell(
                                                  onTap: () {
                                                    CommentBottomSheet(
                                                      context,
                                                      kSize,
                                                      index,
                                                      item,
                                                    );
                                                  },
                                                  child: Image.asset(
                                                    ImageUtils.lipimage,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                // key: widget.sendpostKey,
                                                height: 20,
                                                width: 20,
                                                child: InkWell(
                                                  onTap: () {
                                                    Post usersendpost =
                                                        Post.fromJson(
                                                          item.toJson(),
                                                        );
                                                    print(
                                                      "useertype == ${item.userType}",
                                                    );
                                                    shareData = usersendpost;
                                                    SharepostwithFriends(
                                                      context,
                                                      kSize,
                                                      item.userType!,
                                                    );
                                                  },
                                                  child: Image.asset(
                                                    ImageUtils.sendimage,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                          ),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            '${item.likeCount.toString()} ${Languages.of(context)!.likesText}',
                                            style:
                                                Pallete.Quicksand14blackwe600,
                                          ),
                                        ),
                                        item.review!.isNotEmpty
                                            ? Container(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                              ),
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: RichText(
                                                      maxLines:
                                                          selectindex == index
                                                              ? mxline
                                                              : 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "${item.firstName!} ${item.lastName!}",
                                                            style:
                                                                Pallete
                                                                    .Quicksand14blackwe600,
                                                          ),
                                                          TextSpan(
                                                            text: " ",
                                                            style:
                                                                Pallete
                                                                    .Quicksand14blackwe600,
                                                          ),

                                                          _buildReviewText(
                                                            item.review!,
                                                            item.userTags!,
                                                          ),
                                                          // TextSpan(
                                                          //   text: item.review,
                                                          //   style: Pallete
                                                          //       .Quicksand12darkGreykwe400,
                                                          // ),
                                                          WidgetSpan(
                                                            child: InkWell(
                                                              onTap: () {
                                                                print(
                                                                  "length === ${item.review!.length}",
                                                                );
                                                                setState(() {
                                                                  mxline = 2;
                                                                  more = true;
                                                                  less = false;
                                                                  selectindex =
                                                                      -1;
                                                                });
                                                              },
                                                              child: Visibility(
                                                                visible: less,
                                                                child: Text(
                                                                  " ${Languages.of(context)!.lessText}",
                                                                  style:
                                                                      Pallete
                                                                          .Quicksand14blackwe600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  item.review!.length > 100
                                                      ? InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            print(
                                                              "lenght === ${item.review!.length}",
                                                            );
                                                            mxline = 15;
                                                            more = false;
                                                            less = true;
                                                            selectindex = index;
                                                          });
                                                        },
                                                        child: Visibility(
                                                          visible:
                                                              selectindex ==
                                                                      index
                                                                  ? more
                                                                  : true,
                                                          child: Text(
                                                            "..${Languages.of(context)!.moreText}",
                                                            style:
                                                                Pallete
                                                                    .Quicksand14blackwe600,
                                                          ),
                                                        ),
                                                      )
                                                      : Container(),
                                                ],
                                              ),
                                            )
                                            : Container(),
                                        item.userType == 2
                                            ? Container()
                                            : item.userType == 1 &&
                                                item.beforeImage != ""
                                            ? Column(
                                              children: [
                                                const SizedBox(height: 5),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 15,
                                                        right: 15,
                                                      ),
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        item.rating!.toString(),
                                                        style:
                                                            Pallete
                                                                .Quicksand14blackwe400,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      RatingBarIndicator(
                                                        rating: double.parse(
                                                          item.rating!
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Container(),
                                        const SizedBox(height: 2),
                                        item.commentCount != 0
                                            ? Container(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                              ),
                                              alignment: Alignment.topLeft,
                                              child: InkWell(
                                                onTap: () {
                                                  CommentBottomSheet(
                                                    context,
                                                    kSize,
                                                    index,
                                                    item,
                                                  );
                                                },
                                                child: Text(
                                                  "${Languages.of(context)!.viewallText} ${item.commentCount.toString()} ${Languages.of(context)!.commentsText}",
                                                  style:
                                                      Pallete
                                                          .Quicksand14drktxtGreywe500,
                                                ),
                                              ),
                                            )
                                            : Container(),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                          ),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            getpostTime(item.createdAt!),
                                            style:
                                                Pallete
                                                    .Quicksand14drktxtGreywe500,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                                                                      ) => SalonDetailScreen(
                                                                        id:
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
                                                                Pallete
                                                                    .Quicksand14blackwe600,
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
                                                              Pallete
                                                                  .Quicksand14drktxtGreywe500,
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      items
                                                          .comments![cindex]
                                                          .comment
                                                          .toString(),
                                                      style:
                                                          Pallete
                                                              .Quicksand14Blackwe400,
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
                                    items.id.toString(),
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
              (context) => SalonDetailScreen(id: id.toString(), userType: "1"),
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
            style: Pallete.Quicksand14blackwe600.copyWith(
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
          TextSpan(text: '$word ', style: Pallete.Quicksand14darkGreykwe400),
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
                                          style: Pallete.Quicksand12Blackkwe400,
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
                                  style: Pallete.Quicksand16drkBlackbold,
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
                            style: Pallete.Quicksand18drkBlackbold,
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
                            style: Pallete.Quicksand17Blackw500,
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
                                    color: AppColors.kPinkColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      type == "report"
                                          ? Languages.of(context)!.reportText
                                          : Languages.of(context)!.blockText,
                                      style: Pallete.Quicksand14whitewe600,
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
                                      color: AppColors.kPinkColor,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.cancelText,
                                      style: Pallete.Quicksand14pinkwe600,
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
