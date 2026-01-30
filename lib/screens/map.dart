import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/salonlistmodel.dart';
import 'package:pinkGossip/screens/Mackeups/salondetail.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/salonlistviewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GooglemapPage extends StatefulWidget {
  const GooglemapPage({super.key});

  @override
  State<GooglemapPage> createState() => _GooglemapPageState();
}

SharedPreferences? prefs;
String userid = "";
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

List<SalonList> salonlistArray = [];
bool isLoading = false;
List<Marker> markers = [];
GoogleMapController? mapController;
String? categorydropdownvalue;

class _GooglemapPageState extends State<GooglemapPage> {
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
    // TODO: implement initState
    super.initState();

    getSalonList('');
    getuserid();
  }

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
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: AppColors.kAppBArBGColor,
            elevation: 1,
            centerTitle: true,
            title: Row(
              children: [
                Text(
                  Languages.of(context)!.mapText,
                  style: Pallete.Quicksand16drkBlackbold,
                ),
              ],
            ),
            leading: SizedBox(
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(ImageUtils.leftarrow),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  key: ValueKey(markers.length),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
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
                    zoom: 11.0,
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                ),

                // Dropdown overlay
                Positioned(
                  top: 10,
                  left: 10,
                  // optional – better UI
                  child: Container(
                    height: 40,
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        hint: Text(
                          Languages.of(context)!.categoriesText,
                          style: Pallete.Quicksand12blackwe500,
                        ),
                        items:
                            categorydroparray
                                .map(
                                  (String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: Pallete.Quicksand12blackwe500,
                                    ),
                                  ),
                                )
                                .toList(),
                        value: categorydropdownvalue,
                        onChanged: (String? value) {
                          setState(() {
                            categorydropdownvalue = value;
                            getSalonList(value!);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
