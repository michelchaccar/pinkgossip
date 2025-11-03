// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/screens/HomeScreens/searchforhomescreen.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/salonlistviewmodel.dart';
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

  SharedPreferences? prefs;
  String userid = "";
  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
  }

  List<SalonList> salonlistArray = [];

  int selectindex = 0;
  late final TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  void initState() {
    super.initState();
    getSalonList('');
    getuserid();
    _tabController = TabController(length: 2, vsync: this);
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
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(ImageUtils.notificationimg),
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
                      physics: NeverScrollableScrollPhysics(),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.asset(ImageUtils.listicon),
                          ),
                        ),
                        Tab(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.asset(ImageUtils.mapImage),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                      SizedBox(
                        height: 300,
                        width: 200,
                        child: Stack(
                          children: [
                            GoogleMap(
                              key: ValueKey(markers.length),
                              // gestureRecognizers: Set()
                              //   ..add(Factory<PanGestureRecognizer>(
                              //       () => PanGestureRecognizer()))
                              //   ..add(Factory<ScaleGestureRecognizer>(
                              //       () => ScaleGestureRecognizer()))
                              //   ..add(Factory<TapGestureRecognizer>(
                              //       () => TapGestureRecognizer())),
                              gestureRecognizers:
                                  <
                                    Factory<OneSequenceGestureRecognizer>
                                  >{}, // optional
                              markers: Set.from(markers),
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target:
                                    markers.isEmpty
                                        ? const LatLng(0, 0)
                                        : LatLng(
                                          markers.first.position.latitude,
                                          markers.first.position.longitude,
                                        ),
                                zoom: 18.0,
                              ),
                              mapType: MapType.normal,
                              onMapCreated: (controller) {
                                setState(() {
                                  mapController = controller;
                                });
                              },
                            ),
                            Container(
                              height: 40,
                              width: 200,
                              margin: const EdgeInsets.only(top: 10, left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 2,
                                  color: AppColors.kBlackColor,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          Languages.of(context)!.categoriesText,
                                          style: Pallete.Quicksand12blackwe500,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items:
                                      categorydroparray
                                          .map(
                                            (
                                              String item,
                                            ) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style:
                                                    Pallete
                                                        .Quicksand12blackwe500,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  value: categorydropdownvalue,
                                  onChanged: (String? value) {
                                    setState(() {
                                      getSalonList(value!);
                                      categorydropdownvalue = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // : Container(),
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
}
