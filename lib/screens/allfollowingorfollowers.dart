// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_print, unnecessary_brace_in_string_interps, curly_braces_in_flow_control_structures
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/allfollowersorfollowingmodel.dart';
import 'package:pinkGossip/models/followingmodel.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/models/unfollwmodel.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/allfollowersorfollowviewmodel.dart';
import 'package:pinkGossip/viewModels/followingviewmodel.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:pinkGossip/viewModels/unfollwviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllFollowingorFollowers extends StatefulWidget {
  final String name, type, usertype, navigationType;
  int userid, totlefollowing, totlefollowers;
  AllFollowingorFollowers({
    super.key,
    required this.userid,
    required this.name,
    required this.type,
    required this.totlefollowing,
    required this.totlefollowers,
    required this.usertype,
    required this.navigationType,
  });

  @override
  State<AllFollowingorFollowers> createState() =>
      _AllFollowingorFollowersState();
}

class _AllFollowingorFollowersState extends State<AllFollowingorFollowers>
    with TickerProviderStateMixin {
  bool isLoading = false;

  TabController? _tabController;

  List<UserList> followdetaillist = [];

  SharedPreferences? prefs;

  List<Stories> myStoryArray = [];

  String userid = "";
  String myFireabseiD = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    myFireabseiD = prefs!.getString('FirebaseId')!;

    print("userid   ${userid}");
  }

  @override
  void initState() {
    super.initState();
    getuserid();
    print("widget.usertype    == ${widget.usertype}");
    getStory();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.type == "following") {
      _tabController!.animateTo(1);
      getFollowersorFollow(widget.userid.toString(), widget.type);
    } else {
      _tabController!.animateTo(0);
      getFollowersorFollow(widget.userid.toString(), widget.type);
    }
    _tabController!.addListener(() {
      if (_tabController!.index == 0) {
        getFollowersorFollow(widget.userid.toString(), "follower");
      } else if (_tabController!.index == 1) {
        getFollowersorFollow(widget.userid.toString(), "following");
      }
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
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
              Row(
                children: [
                  InkWell(
                    overlayColor: const WidgetStatePropertyAll(
                      AppColors.kWhiteColor,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      widget.navigationType == "salondetail"
                          ? Navigator.pop(context)
                          : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavBar(index: 4),
                            ),
                          );
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
                  Text(widget.name, style: Pallete.Quicksand16drkBlackBold),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
              width: kSize.width,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: AppColors.kPinkColor,
                overlayColor: const WidgetStatePropertyAll(
                  AppColors.kAppBArBGColor,
                ),
                indicatorColor: AppColors.kPinkColor,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (value) {},
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.totlefollowers} ${Languages.of(context)!.FollowersText}",
                          // style: Pallete.Quicksand15blackwe600,
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.totlefollowing} ${Languages.of(context)!.FollowingText}",
                          // style: Pallete.Quicksand15blackwe600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? Container(
                        height: kSize.height,
                        width: kSize.width,
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      )
                      : SizedBox(
                        width: kSize.width,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            followdetaillist.isNotEmpty
                                ? Container(
                                  color: Colors.white,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: followdetaillist.length,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 2,
                                              color: AppColors.kBorderColor,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => SalonDetailScreen(
                                                        id:
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                        userType:
                                                            followdetaillist[index]
                                                                .userType
                                                                .toString(),
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    followdetaillist[index]
                                                                .profileImage !=
                                                            ""
                                                        ? GestureDetector(
                                                          onTap: () {
                                                            if (followdetaillist[index]
                                                                .storyData!
                                                                .isNotEmpty) {
                                                              if (myFireabseiD ==
                                                                  followdetaillist[index]
                                                                      .firebaseId!) {
                                                                print(
                                                                  "id matcheddd",
                                                                );

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
                                                                              followdetaillist[index].firstName ??
                                                                              "",
                                                                          lastname:
                                                                              followdetaillist[index].lastName ??
                                                                              "",
                                                                          img:
                                                                              followdetaillist[index].profileImage ??
                                                                              "",
                                                                          salonanme:
                                                                              followdetaillist[index].salonName ??
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
                                                                          storyFollowFollowingData:
                                                                              followdetaillist[index].storyData!,
                                                                          myFireabseiD:
                                                                              myFireabseiD,
                                                                          firstname:
                                                                              followdetaillist[index].firstName!,
                                                                          lastname:
                                                                              followdetaillist[index].lastName!,
                                                                          profileimage:
                                                                              "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                          salonname:
                                                                              followdetaillist[index].salonName!,
                                                                          type:
                                                                              "Followers",
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
                                                                            followdetaillist[index].id.toString(),
                                                                        userType:
                                                                            followdetaillist[index].userType.toString(),
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration:
                                                                followdetaillist[index]
                                                                        .storyData!
                                                                        .isNotEmpty
                                                                    ? const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
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
                                                                            Alignment.bottomRight,
                                                                      ),
                                                                    )
                                                                    : const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3.0,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 25.0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey[300],
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                    "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        : GestureDetector(
                                                          onTap: () {
                                                            if (followdetaillist[index]
                                                                .storyData!
                                                                .isNotEmpty) {
                                                              if (myFireabseiD ==
                                                                  followdetaillist[index]
                                                                      .firebaseId!) {
                                                                print(
                                                                  "id matcheddd",
                                                                );

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
                                                                              followdetaillist[index].firstName ??
                                                                              "",
                                                                          lastname:
                                                                              followdetaillist[index].lastName ??
                                                                              "",
                                                                          img:
                                                                              followdetaillist[index].profileImage ??
                                                                              "",
                                                                          salonanme:
                                                                              followdetaillist[index].salonName ??
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
                                                                          storyFollowFollowingData:
                                                                              followdetaillist[index].storyData!,
                                                                          myFireabseiD:
                                                                              myFireabseiD,
                                                                          firstname:
                                                                              followdetaillist[index].firstName!,
                                                                          lastname:
                                                                              followdetaillist[index].lastName!,
                                                                          profileimage:
                                                                              "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                          salonname:
                                                                              followdetaillist[index].salonName!,
                                                                          type:
                                                                              "Followers",
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
                                                                            followdetaillist[index].id.toString(),
                                                                        userType:
                                                                            followdetaillist[index].userType.toString(),
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration:
                                                                followdetaillist[index]
                                                                        .storyData!
                                                                        .isNotEmpty
                                                                    ? const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
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
                                                                            Alignment.bottomRight,
                                                                      ),
                                                                    )
                                                                    : const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3.0,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 25.0,
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
                                                    followdetaillist[index]
                                                                .userType ==
                                                            1
                                                        ? Text(
                                                          "${followdetaillist[index].firstName} ${followdetaillist[index].lastName}",
                                                          style:
                                                              Pallete
                                                                  .Quicksand15blackwe600,
                                                        )
                                                        : Text(
                                                          followdetaillist[index]
                                                              .salonName!,
                                                          style:
                                                              Pallete
                                                                  .Quicksand15blackwe600,
                                                        ),
                                                    const SizedBox(height: 2),
                                                  ],
                                                ),
                                                widget.usertype == "profile"
                                                    ? Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          userRemove(
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                            userid,
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.RemoveText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : followdetaillist[index].id
                                                            .toString() ==
                                                        userid
                                                    ? Container()
                                                    : followdetaillist[index]
                                                            .isFollowed ==
                                                        0
                                                    ? Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          print(
                                                            "followers tab in follow",
                                                          );
                                                          userFollowing(
                                                            userid,
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                            "0",
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.followText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          userUnfollow(
                                                            userid,
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.unfollowText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    "0 ${Languages.of(context)!.follwersText}",
                                    style: Pallete.Quicksand16drkBlackbold,
                                  ),
                                ),
                            followdetaillist.isNotEmpty
                                ? Container(
                                  color: Colors.white,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: followdetaillist.length,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 2,
                                              color: AppColors.kBorderColor,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => SalonDetailScreen(
                                                        id:
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                        userType:
                                                            followdetaillist[index]
                                                                .userType
                                                                .toString(),
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    followdetaillist[index]
                                                                .profileImage !=
                                                            ""
                                                        ? GestureDetector(
                                                          onTap: () {
                                                            if (followdetaillist[index]
                                                                .storyData!
                                                                .isNotEmpty) {
                                                              if (myFireabseiD ==
                                                                  followdetaillist[index]
                                                                      .firebaseId!) {
                                                                print(
                                                                  "id matcheddd",
                                                                );

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
                                                                              followdetaillist[index].firstName ??
                                                                              "",
                                                                          lastname:
                                                                              followdetaillist[index].lastName ??
                                                                              "",
                                                                          img:
                                                                              followdetaillist[index].profileImage ??
                                                                              "",
                                                                          salonanme:
                                                                              followdetaillist[index].salonName ??
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
                                                                          storyFollowFollowingData:
                                                                              followdetaillist[index].storyData!,
                                                                          myFireabseiD:
                                                                              myFireabseiD,
                                                                          firstname:
                                                                              followdetaillist[index].firstName!,
                                                                          lastname:
                                                                              followdetaillist[index].lastName!,
                                                                          profileimage:
                                                                              "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                          salonname:
                                                                              followdetaillist[index].salonName!,
                                                                          type:
                                                                              "Followers",
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
                                                                            followdetaillist[index].id.toString(),
                                                                        userType:
                                                                            followdetaillist[index].userType.toString(),
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration:
                                                                followdetaillist[index]
                                                                        .storyData!
                                                                        .isNotEmpty
                                                                    ? const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
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
                                                                            Alignment.bottomRight,
                                                                      ),
                                                                    )
                                                                    : const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3.0,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 25.0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey[300],
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                    "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        : GestureDetector(
                                                          onTap: () {
                                                            if (followdetaillist[index]
                                                                .storyData!
                                                                .isNotEmpty) {
                                                              if (myFireabseiD ==
                                                                  followdetaillist[index]
                                                                      .firebaseId!) {
                                                                print(
                                                                  "id matcheddd",
                                                                );

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
                                                                              followdetaillist[index].firstName ??
                                                                              "",
                                                                          lastname:
                                                                              followdetaillist[index].lastName ??
                                                                              "",
                                                                          img:
                                                                              followdetaillist[index].profileImage ??
                                                                              "",
                                                                          salonanme:
                                                                              followdetaillist[index].salonName ??
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
                                                                          storyFollowFollowingData:
                                                                              followdetaillist[index].storyData!,
                                                                          myFireabseiD:
                                                                              myFireabseiD,
                                                                          firstname:
                                                                              followdetaillist[index].firstName!,
                                                                          lastname:
                                                                              followdetaillist[index].lastName!,
                                                                          profileimage:
                                                                              "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                                          salonname:
                                                                              followdetaillist[index].salonName!,
                                                                          type:
                                                                              "Followers",
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
                                                                            followdetaillist[index].id.toString(),
                                                                        userType:
                                                                            followdetaillist[index].userType.toString(),
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration:
                                                                followdetaillist[index]
                                                                        .storyData!
                                                                        .isNotEmpty
                                                                    ? const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
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
                                                                            Alignment.bottomRight,
                                                                      ),
                                                                    )
                                                                    : const BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3.0,
                                                                ),
                                                            child: CircleAvatar(
                                                              radius: 25.0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey[300],
                                                              child: const Icon(
                                                                Icons.person,
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                    // Container(
                                                    //     height: 50,
                                                    //     width: 50,
                                                    //     decoration: BoxDecoration(
                                                    //         color: Colors
                                                    //             .greenAccent,
                                                    //         borderRadius:
                                                    //             BorderRadius
                                                    //                 .circular(
                                                    //                     25)),
                                                    //     child: ClipRRect(
                                                    //       borderRadius:
                                                    //           BorderRadius
                                                    //               .circular(
                                                    //                   30),
                                                    //       child:
                                                    //           Image.network(
                                                    //         loadingBuilder:
                                                    //             (BuildContext
                                                    //                     context,
                                                    //                 Widget
                                                    //                     child,
                                                    //                 ImageChunkEvent?
                                                    //                     loadingProgress) {
                                                    //           if (loadingProgress ==
                                                    //               null)
                                                    //             return child;
                                                    //           return SizedBox(
                                                    //             height: 100,
                                                    //             width: 100,
                                                    //             child: Center(
                                                    //               child:
                                                    //                   CircularProgressIndicator(
                                                    //                 color: AppColors
                                                    //                     .kBlackColor,
                                                    //                 value: loadingProgress.expectedTotalBytes !=
                                                    //                         null
                                                    //                     ? loadingProgress.cumulativeBytesLoaded /
                                                    //                         loadingProgress.expectedTotalBytes!
                                                    //                     : null,
                                                    //               ),
                                                    //             ),
                                                    //           );
                                                    //         },
                                                    //         "${API.baseUrl}/api/${followdetaillist[index].profileImage!}",
                                                    //         fit: BoxFit.cover,
                                                    //       ),
                                                    //     ),
                                                    //   )
                                                    // : Container(
                                                    //     height: 50,
                                                    //     width: 50,
                                                    //     decoration: BoxDecoration(
                                                    //         border: Border.all(
                                                    //             color: AppColors
                                                    //                 .drktxtGrey),
                                                    //         borderRadius:
                                                    //             BorderRadius
                                                    //                 .circular(
                                                    //                     25)),
                                                    //     child: ClipRRect(
                                                    //       borderRadius:
                                                    //           BorderRadius
                                                    //               .circular(
                                                    //                   30),
                                                    //       child: const Icon(
                                                    //           Icons.person),
                                                    //     ),
                                                    //   ),
                                                    const SizedBox(width: 10),
                                                    followdetaillist[index]
                                                                .userType ==
                                                            1
                                                        ? Text(
                                                          "${followdetaillist[index].firstName} ${followdetaillist[index].lastName}",
                                                          style:
                                                              Pallete
                                                                  .Quicksand15blackwe600,
                                                        )
                                                        : Text(
                                                          followdetaillist[index]
                                                              .salonName!,
                                                          style:
                                                              Pallete
                                                                  .Quicksand15blackwe600,
                                                        ),
                                                    const SizedBox(height: 2),
                                                  ],
                                                ),
                                                widget.usertype == "profile"
                                                    ? Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          userUnfollow(
                                                            userid,
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.followingText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : followdetaillist[index].id
                                                            .toString() ==
                                                        userid
                                                    ? Container()
                                                    : followdetaillist[index]
                                                            .isFollowed ==
                                                        0
                                                    ? Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          userFollowing(
                                                            userid,
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                            "0",
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.followText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : Container(
                                                      height: 28,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          userUnfollow(
                                                            userid,
                                                            followdetaillist[index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            Languages.of(
                                                              context,
                                                            )!.unfollowText,
                                                            style:
                                                                Pallete
                                                                    .Quicksand14Whiitewe600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    "0 ${Languages.of(context)!.followingText}",
                                    style: Pallete.Quicksand16drkBlackbold,
                                  ),
                                ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  userUnfollow(String following_id, String follower_id) async {
    print("get userUnfollow function call");
    setState(() {
      isLoading = true;
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
              isLoading = false;
              UnfollowiModel model =
                  Provider.of<UnfollowViewModel>(
                        context,
                        listen: false,
                      ).unfollowresponse.response
                      as UnfollowiModel;

              if (model.success == true) {
                if (_tabController!.index == 1) {
                  widget.totlefollowing = widget.totlefollowing - 1;
                  getFollowersorFollow(widget.userid.toString(), "following");
                } else {
                  getFollowersorFollow(widget.userid.toString(), "follower");
                }
              }

              kToast(model.message!);
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

  userRemove(String following_id, String follower_id) async {
    print("get userUnfollow function call");
    setState(() {
      isLoading = true;
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
              isLoading = false;
              UnfollowiModel model =
                  Provider.of<UnfollowViewModel>(
                        context,
                        listen: false,
                      ).unfollowresponse.response
                      as UnfollowiModel;

              if (model.success == true) {
                widget.totlefollowers = widget.totlefollowers - 1;
                getFollowersorFollow(widget.userid.toString(), "follower");
              }

              kToast(model.message!);
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

  getFollowersorFollow(String id, String follow_type) async {
    print("get getProfileDetails function call");
    setState(() {
      isLoading = true;
    });

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<AllFollowerorFollowViewModel>(
          context,
          listen: false,
        ).getFollowersorFollow(id, follow_type, userid);
        if (Provider.of<AllFollowerorFollowViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<AllFollowerorFollowViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;

              print("Success");
              Allfollowingorfollowersmodel model =
                  Provider.of<AllFollowerorFollowViewModel>(
                        context,
                        listen: false,
                      ).allfollowerorfollowresponse.response
                      as Allfollowingorfollowersmodel;

              followdetaillist = model.userList!;
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
                if (_tabController!.index == 1) {
                  getFollowersorFollow(widget.userid.toString(), "following");
                } else {
                  getFollowersorFollow(widget.userid.toString(), "follower");
                }
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
}
