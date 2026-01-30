// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'dart:math';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/screens/HomeScreens/addstory.dart';
import 'package:pinkGossip/screens/HomeScreens/mystoryview.dart';
import 'package:pinkGossip/screens/HomeScreens/otherstoryview.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/screens/Profile/singleuserstoryshow.dart';
import 'package:pinkGossip/viewModels/getstoryviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewModels/searchuserlistviewmodel.dart';

class SearchForHomeScreen extends StatefulWidget {
  const SearchForHomeScreen({super.key});

  @override
  State<SearchForHomeScreen> createState() => _SearchForHomeScreenState();
}

class _SearchForHomeScreenState extends State<SearchForHomeScreen>
    with TickerProviderStateMixin {
  int selectindex = 0;

  TextEditingController _searchController = TextEditingController();
  List<UserList> homeSearchList = [];
  List<UserList> enthusiastssearchingList = [];
  List<UserList> salonsearchingList = [];

  bool isLoading = false;

  String userid = "";
  String myFireabseiD = "";
  SharedPreferences? prefs;

  List<Stories> myStoryArray = [];

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    myFireabseiD = prefs!.getString('FirebaseId')!;

    print("userid   ${userid}");
  }

  late final TabController _tabController;

  void enthusiastsfilterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      enthusiastssearchingList =
          homeSearchList
              .where(
                (item) => ('${item.firstName!} ${item.lastName!}')
                    .toLowerCase()
                    .contains(query),
              )
              .toList();
    });
  }

  void salonsearchingListfilterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      salonsearchingList =
          homeSearchList
              .where(
                (item) => ('${item.salonName!}').toLowerCase().contains(query),
              )
              .toList();
      // salonsearchingList =
      //     homeSearchList
      //         .where(
      //           (item) => ('${item.firstName!} ${item.lastName!}')
      //               .toLowerCase()
      //               .contains(query),
      //         )
      //         .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getuserid();
    getsearchUserList("1");
    getStory();

    _tabController.addListener(() {
      setState(() {
        enthusiastssearchingList.clear();
        salonsearchingList.clear();
      });
      print("tab index == ${_tabController.index}");
      if (_tabController.index == 0) {
        getsearchUserList("1");
        enthusiastsfilterList();
      } else if (_tabController.index == 1) {
        getsearchUserList("2");
        salonsearchingListfilterList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          toolbarHeight: 60,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.kAppBArBGColor,
          automaticallyImplyLeading: false,
          elevation: 2.0,
          title: Row(
            children: [
              InkWell(
                overlayColor: const WidgetStatePropertyAll(
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    maxLines: 1,
                    autocorrect: true,
                    controller: _searchController,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.search,
                    cursorColor: AppColors.kTextColor,
                    onChanged: (value) {
                      if (_tabController.index == 0) {
                        enthusiastsfilterList();
                      } else if (_tabController.index == 1) {
                        salonsearchingListfilterList();
                      }
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      fillColor: AppColors.kWhiteColor,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      hintText: Languages.of(context)!.searchText,
                      hintStyle: Pallete.textFieldTextStyle,
                      suffixIcon: const Icon(Icons.search, size: 30),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.kTextFieldBorderColor,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.kPinkColor,
                        ),
                      ),
                      focusColor: AppColors.kPinkColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Center(
                  child: TabBar(
                    isScrollable: false,
                    controller: _tabController,
                    indicatorColor: AppColors.kPinkColor,
                    labelColor: AppColors.kBlackColor,
                    unselectedLabelStyle: Pallete.Quicksand16drkBlackBold,
                    labelStyle: Pallete.Quicksand16drkBlackBold,
                    indicatorSize: TabBarIndicatorSize.tab,
                    onTap: (value) {
                      //   if (value == 0) {
                      //     getsearchUserList("1");
                      //   } else if (value == 1) {
                      //     getsearchUserList("2");
                      //   }
                      if (value == 0) {
                        getsearchUserList("1");
                        enthusiastsfilterList();
                      } else if (value == 1) {
                        getsearchUserList("2");
                        salonsearchingListfilterList();
                      }
                    },
                    tabs: [
                      Tab(text: Languages.of(context)!.gossiperText),
                      Tab(text: Languages.of(context)!.beautybusinessText),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        enthusiastssearchingList.isEmpty
                            ? Center(
                              child: Text(
                                Languages.of(context)!.NodatafoundText,
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: enthusiastssearchingList.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SalonDetailScreen(
                                              id:
                                                  enthusiastssearchingList[index]
                                                      .id
                                                      .toString(),
                                              userType: "1",
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
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          enthusiastssearchingList[index]
                                                      .profileImage !=
                                                  ""
                                              ? Container(
                                                decoration:
                                                    enthusiastssearchingList[index]
                                                            .storyData!
                                                            .isNotEmpty
                                                        ? const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .kPinkColor,
                                                              AppColors
                                                                  .kPinkColor,
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                        )
                                                        : const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var oppFirebase = "";
                                                    enthusiastssearchingList[index]
                                                        .storyData!
                                                        .forEach((element) {
                                                          oppFirebase =
                                                              element
                                                                  .firebaseId!;
                                                        });

                                                    if (enthusiastssearchingList[index]
                                                        .storyData!
                                                        .isNotEmpty) {
                                                      if (myFireabseiD ==
                                                          oppFirebase) {
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
                                                                      enthusiastssearchingList[index]
                                                                          .firstName ??
                                                                      "",
                                                                  lastname:
                                                                      enthusiastssearchingList[index]
                                                                          .lastName ??
                                                                      "",
                                                                  img:
                                                                      enthusiastssearchingList[index]
                                                                          .profileImage ??
                                                                      "",
                                                                  salonanme:
                                                                      enthusiastssearchingList[index]
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
                                                                  storyData:
                                                                      enthusiastssearchingList[index]
                                                                          .storyData,
                                                                  myFireabseiD:
                                                                      myFireabseiD,
                                                                  firstname:
                                                                      enthusiastssearchingList[index]
                                                                          .firstName!,
                                                                  lastname:
                                                                      enthusiastssearchingList[index]
                                                                          .lastName!,
                                                                  profileimage:
                                                                      "${API.baseUrl}/api/${enthusiastssearchingList[index].profileImage!}",
                                                                  salonname:
                                                                      enthusiastssearchingList[index]
                                                                          .salonName!,
                                                                  type:
                                                                      "UserList",
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
                                                                    enthusiastssearchingList[index]
                                                                        .id
                                                                        .toString(),
                                                                userType: "1",
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    backgroundImage: NetworkImage(
                                                      "${API.baseUrl}/api/${enthusiastssearchingList[index].profileImage!}",
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : Container(
                                                decoration:
                                                    enthusiastssearchingList[index]
                                                            .storyData!
                                                            .isNotEmpty
                                                        ? const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .kPinkColor,
                                                              AppColors
                                                                  .kPinkColor,
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                        )
                                                        : const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var oppFirebase = "";
                                                    enthusiastssearchingList[index]
                                                        .storyData!
                                                        .forEach((element) {
                                                          oppFirebase =
                                                              element
                                                                  .firebaseId!;
                                                        });

                                                    if (enthusiastssearchingList[index]
                                                        .storyData!
                                                        .isNotEmpty) {
                                                      if (myFireabseiD ==
                                                          oppFirebase) {
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
                                                                      enthusiastssearchingList[index]
                                                                          .firstName ??
                                                                      "",
                                                                  lastname:
                                                                      enthusiastssearchingList[index]
                                                                          .lastName ??
                                                                      "",
                                                                  img:
                                                                      enthusiastssearchingList[index]
                                                                          .profileImage ??
                                                                      "",
                                                                  salonanme:
                                                                      enthusiastssearchingList[index]
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
                                                                  storyData:
                                                                      enthusiastssearchingList[index]
                                                                          .storyData,
                                                                  myFireabseiD:
                                                                      myFireabseiD,
                                                                  firstname:
                                                                      enthusiastssearchingList[index]
                                                                          .firstName!,
                                                                  lastname:
                                                                      enthusiastssearchingList[index]
                                                                          .lastName!,
                                                                  profileimage:
                                                                      "${API.baseUrl}/api/${enthusiastssearchingList[index].profileImage!}",
                                                                  salonname:
                                                                      enthusiastssearchingList[index]
                                                                          .salonName!,
                                                                  type:
                                                                      "UserList",
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
                                                                    enthusiastssearchingList[index]
                                                                        .id
                                                                        .toString(),
                                                                userType: "1",
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.person,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${enthusiastssearchingList[index].firstName} ${enthusiastssearchingList[index].lastName}",
                                                style:
                                                    Pallete
                                                        .Quicksand14blackwe600,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${enthusiastssearchingList[index].followerCount.toString()} ${Languages.of(context)!.FollowersText}",
                                                style:
                                                    Pallete
                                                        .Quicksand14blackwe400,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        salonsearchingList.isEmpty
                            ? Center(
                              child: Text(
                                Languages.of(context)!.NodatafoundText,
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: salonsearchingList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SalonDetailScreen(
                                              id:
                                                  salonsearchingList[index].id
                                                      .toString(),
                                              userType: "2",
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
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          salonsearchingList[index]
                                                      .profileImage !=
                                                  ""
                                              ? Container(
                                                decoration:
                                                    salonsearchingList[index]
                                                            .storyData!
                                                            .isNotEmpty
                                                        ? const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .kPinkColor,
                                                              AppColors
                                                                  .kPinkColor,
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                        )
                                                        : const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var oppFirebase = "";
                                                    salonsearchingList[index]
                                                        .storyData!
                                                        .forEach((element) {
                                                          oppFirebase =
                                                              element
                                                                  .firebaseId!;
                                                        });
                                                    if (salonsearchingList[index]
                                                        .storyData!
                                                        .isNotEmpty) {
                                                      if (myFireabseiD ==
                                                          oppFirebase) {
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
                                                                      salonsearchingList[index]
                                                                          .firstName ??
                                                                      "",
                                                                  lastname:
                                                                      salonsearchingList[index]
                                                                          .lastName ??
                                                                      "",
                                                                  img:
                                                                      salonsearchingList[index]
                                                                          .profileImage ??
                                                                      "",
                                                                  salonanme:
                                                                      salonsearchingList[index]
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
                                                                  storyData:
                                                                      salonsearchingList[index]
                                                                          .storyData,
                                                                  myFireabseiD:
                                                                      myFireabseiD,
                                                                  firstname:
                                                                      salonsearchingList[index]
                                                                          .firstName!,
                                                                  lastname:
                                                                      salonsearchingList[index]
                                                                          .lastName!,
                                                                  profileimage:
                                                                      "${API.baseUrl}/api/${salonsearchingList[index].profileImage!}",
                                                                  salonname:
                                                                      salonsearchingList[index]
                                                                          .salonName!,
                                                                  type:
                                                                      "UserList",
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
                                                                    salonsearchingList[index]
                                                                        .id
                                                                        .toString(),
                                                                userType: "2",
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    backgroundImage: NetworkImage(
                                                      "${API.baseUrl}/api/${salonsearchingList[index].profileImage!}",
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : Container(
                                                decoration:
                                                    salonsearchingList[index]
                                                            .storyData!
                                                            .isNotEmpty
                                                        ? const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              AppColors
                                                                  .kPinkColor,
                                                              AppColors
                                                                  .kPinkColor,
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                        )
                                                        : const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var oppFirebase = "";
                                                    salonsearchingList[index]
                                                        .storyData!
                                                        .forEach((element) {
                                                          oppFirebase =
                                                              element
                                                                  .firebaseId!;
                                                        });
                                                    if (salonsearchingList[index]
                                                        .storyData!
                                                        .isNotEmpty) {
                                                      if (myFireabseiD ==
                                                          oppFirebase) {
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
                                                                      salonsearchingList[index]
                                                                          .firstName ??
                                                                      "",
                                                                  lastname:
                                                                      salonsearchingList[index]
                                                                          .lastName ??
                                                                      "",
                                                                  img:
                                                                      salonsearchingList[index]
                                                                          .profileImage ??
                                                                      "",
                                                                  salonanme:
                                                                      salonsearchingList[index]
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
                                                                  storyData:
                                                                      salonsearchingList[index]
                                                                          .storyData,
                                                                  myFireabseiD:
                                                                      myFireabseiD,
                                                                  firstname:
                                                                      salonsearchingList[index]
                                                                          .firstName!,
                                                                  lastname:
                                                                      salonsearchingList[index]
                                                                          .lastName!,
                                                                  profileimage:
                                                                      "${API.baseUrl}/api/${salonsearchingList[index].profileImage!}",
                                                                  salonname:
                                                                      salonsearchingList[index]
                                                                          .salonName!,
                                                                  type:
                                                                      "UserList",
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
                                                                    salonsearchingList[index]
                                                                        .id
                                                                        .toString(),
                                                                userType: "2",
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.person,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                // "${salonsearchingList[index].firstName} ${salonsearchingList[index].lastName}",
                                                "${salonsearchingList[index].salonName}",
                                                style:
                                                    Pallete
                                                        .Quicksand14blackwe600,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${salonsearchingList[index].followerCount.toString()} followers",
                                                style:
                                                    Pallete
                                                        .Quicksand14blackwe400,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                    isLoading
                        ? Container(
                          height: kSize.height,
                          width: kSize.width,
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getsearchUserList(String type) async {
    print("get doPostLike function call");
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SearchUserListViewModelViewModel>(
          context,
          listen: false,
        ).getsearchUserList(type, userid);
        if (Provider.of<SearchUserListViewModelViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<SearchUserListViewModelViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              // enthusiastssearchingList.clear();
              // salonsearchingList.clear();
              isLoading = false;
              print("Success");
              SalonSearchListModel model =
                  Provider.of<SearchUserListViewModelViewModel>(
                        context,
                        listen: false,
                      ).searchuserlistresponse.response
                      as SalonSearchListModel;

              homeSearchList = model.userList!;

              if (_tabController.index == 0) {
                enthusiastsfilterList();
              } else if (_tabController.index == 1) {
                homeSearchList!.removeWhere(
                  (element) => element.salonName!.isEmpty,
                );
                salonsearchingListfilterList();
              }
              // enthusiastssearchingList.addAll(homeSearchList);
              // salonsearchingList.addAll(homeSearchList);
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
