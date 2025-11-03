// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, must_be_immutable, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/checkusernameexistmodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/models/updateprofilephoto.dart';
import 'package:pinkGossip/viewModels/checkusernameexistviewmodel.dart';
import 'package:pinkGossip/viewModels/searchuserlistviewmodel.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmdoel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/models/updateprofilemodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/updateprofileviewmodel.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  Map<String, dynamic> userData = {};
  List<SalonOpenDay>? getsalonOpenDays;
  String latitude, longitude;
  EditProfileScreen({
    super.key,
    required this.userData,
    required this.latitude,
    required this.longitude,
    required this.getsalonOpenDays,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = false;
  TextEditingController firstnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController saloncontroller = TextEditingController();
  TextEditingController websitecontroller = TextEditingController();
  // TextEditingController opentimecontroller = TextEditingController();

  SharedPreferences? prefs;
  String userid = "";
  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;

    print("userid ${userid}");
  }

  var selectedStartday = "";
  var selectedEndday = "";

  final String iosApiKey = 'AIzaSyCRNjykxoRKwqenOpoqBdoYz1CTvPYI5So';
  final String androidApiKey = 'AIzaSyCRNjykxoRKwqenOpoqBdoYz1CTvPYI5So';
  List<String> _predictions = [];
  String? _selectedPlaceId;

  List<Map<String, String>> openingClosingTimes = [];

  void onTimesUpdated(List<Map<String, String>> times) {
    setState(() {
      openingClosingTimes = times;
    });

    print("Updated times: $openingClosingTimes");
  }

  Future<void> _fetchPredictions(String input) async {
    const apiKey = "AIzaSyCRNjykxoRKwqenOpoqBdoYz1CTvPYI5So";
    const apiUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    final response = await http.get(
      Uri.parse('$apiUrl?input=$input&types=geocode&key=$apiKey'),
    );
    // print("response.body == ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _predictions = List<String>.from(
            data['predictions'].map((prediction) => prediction['description']),
          );

          _selectedPlaceId = data['predictions'][0]['place_id'];

          print("_selectedPlaceId == ${_selectedPlaceId}");
        });
      } else {
        setState(() {
          _predictions = [];
        });
      }
    } else {
      throw Exception('Failed to fetch predictions');
    }
  }

  final Set<String> checkedUsernames =
      {}; // To store previously checked usernames

  @override
  void initState() {
    super.initState();

    getTagUserList("1");

    Pallete.latitude =
        widget.latitude.isNotEmpty ? double.parse(widget.latitude) : 0.0;
    Pallete.longtude =
        widget.longitude.isNotEmpty ? double.parse(widget.longitude) : 0.0;
    firstnameController.text = widget.userData["firstname"];
    lastnameController.text = widget.userData["lastname"];
    usernameController.text = widget.userData["username"];
    bioController.text = widget.userData["bio"];
    emailController.text = widget.userData["email"];
    websitecontroller.text = widget.userData["site_name"];
    contactController.text = widget.userData["contact"];
    addressController.text = widget.userData["address"];
    saloncontroller.text = widget.userData["salonname"];
    // opendaycontroller.text = widget.userData["opendays"];
    // opentimecontroller.text = widget.userData["opentime"];
    selectedStartday = widget.userData["opendays"].toString().split("-").first;
    selectedEndday = widget.userData["opendays"].toString().split("-").last;
    getuserid();
    opentimeControllers = List.generate(7, (_) => TextEditingController());
    closetimeControllers = List.generate(7, (_) => TextEditingController());
    opentimes = List.generate(7, (_) => TimeOfDay.now());
    closetimes = List.generate(7, (_) => TimeOfDay.now());
    switches = List.generate(7, (_) => false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will run after the build method has completed
      _initializeWeekdayAndTimes();
    });

    // widget.getsalonOpenDays!.forEach((element) {
    //   print(
    //       "element == ${element.open} ${element.startTime} ${element.endTime}");
    // });
  }

  List<Map<String, String>> openCloseTimes = [];

  final Completer<GoogleMapController> _senderMapcontroller = Completer();

  Future<void> _fetchPlaceDetails(String placeId) async {
    const apiKey = "AIzaSyCRNjykxoRKwqenOpoqBdoYz1CTvPYI5So";
    const apiUrl = "https://maps.googleapis.com/maps/api/place/details/json";
    final response = await http.get(
      Uri.parse('$apiUrl?place_id=$placeId&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        print("Latitude: ${location['lat']}, Longitude: ${location['lng']}");
        setState(() {
          Pallete.latitude = location['lat'];
          Pallete.longtude = location['lng'];
          _addMarker();
          print("Pallete.latitude = ${Pallete.latitude}");
          print("Pallete.longtude = ${Pallete.longtude}");
        });

        final newCameraPosition = CameraPosition(
          target: LatLng(Pallete.latitude, Pallete.longtude),
          zoom: 15.0,
        );

        _animateCamera(newCameraPosition);
      } else {
        throw Exception('Failed to fetch place details');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  void _animateCamera(CameraPosition position) async {
    final GoogleMapController controller = await _senderMapcontroller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _senderMapcontroller.complete(controller);
  }

  void _addMarker() {
    _markers.add(
      Marker(
        markerId: MarkerId(
          LatLng(Pallete.latitude, Pallete.longtude).toString(),
        ),
        position: LatLng(Pallete.latitude, Pallete.longtude),
        // infoWindow: const InfoWindow(
        //   title: 'Your goods will be picked from here',
        // ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _selectPrediction(int index) {
    setState(() {
      _fetchPlaceDetails(_selectedPlaceId!);
    });
  }

  late List<TextEditingController> opentimeControllers;
  late List<TextEditingController> closetimeControllers;
  late List<TimeOfDay> opentimes;
  late List<TimeOfDay> closetimes;
  late List<bool> switches;
  late List<String> weekday;

  bool isTagUserShow = false;
  List<UserList> filteredUserList = [];

  void insertTag(UserList user) {
    String currentText = bioController.text;
    int lastAtIndex = currentText.lastIndexOf("@");

    if (lastAtIndex != -1) {
      // Replace the text from @ to cursor position with the username
      String beforeAt = currentText.substring(0, lastAtIndex);
      String afterAt = currentText.substring(
        bioController.selection.base.offset,
      );

      // Create the new text with the tagged user
      String newText = '$beforeAt@${user.userName} $afterAt';

      // Update the TextField text and set cursor position
      bioController.text = newText;
      bioController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: beforeAt.length + user.userName!.length + 2,
        ), // +2 for '@ ' (the space after the username)
      );
    } else {
      // If there's no '@', just add the username
      String newText = currentText + '@${user.userName} ';
      bioController.text = newText;
      bioController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }

    setState(() {
      isTagUserShow = false;
    });
  }

  void _onTextChanged(String value) {
    final taggedUserIds = getTaggedUserIds();
    print("taggedUserIds =${taggedUserIds}");

    int lastAtIndex = value.lastIndexOf('@');
    int cursorPosition = bioController.selection.base.offset;

    if (lastAtIndex != -1 && cursorPosition > lastAtIndex) {
      String searchText =
          value.substring(lastAtIndex + 1, cursorPosition).toLowerCase();

      setState(() {
        if (searchText.isEmpty) {
          filteredUserList = tagUserList;
          isTagUserShow = true;
        } else {
          filteredUserList =
              tagUserList.where((user) {
                if (user.userName == null) return false;

                return user.userName!.toLowerCase().contains(searchText) ||
                    (user.firstName != null &&
                        user.firstName!.toLowerCase().contains(searchText)) ||
                    (user.lastName != null &&
                        user.lastName!.toLowerCase().contains(searchText));
              }).toList();

          isTagUserShow = filteredUserList.isNotEmpty;
        }
      });
    } else {
      setState(() {
        isTagUserShow = false;
      });
    }
  }

  List<String> getTaggedUserIds() {
    final mentionedUsernames = <String>[];
    final parts = bioController.text.split(" ");
    for (var part in parts) {
      if (part.startsWith("@")) {
        mentionedUsernames.add(part.substring(1));
      }
    }

    final taggedUserIds =
        tagUserList
            .where((user) => mentionedUsernames.contains(user.userName))
            .map((user) => user.id.toString())
            .toList();
    return taggedUserIds;
  }

  @override
  void dispose() {
    for (var controller in opentimeControllers) {
      controller.dispose();
    }
    for (var controller in closetimeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeWeekdayAndTimes() {
    setState(() {
      weekday = [
        Languages.of(context)!.MonText,
        Languages.of(context)!.TueText,
        Languages.of(context)!.WedText,
        Languages.of(context)!.ThuText,
        Languages.of(context)!.FriText,
        Languages.of(context)!.SatText,
        Languages.of(context)!.SunText,
      ];

      widget.getsalonOpenDays!.forEach((element) {
        String dayShort = element.open!.substring(0, 3);
        int index = weekday.indexWhere(
          (week) => week.substring(0, 3) == dayShort,
        );

        if (index != -1) {
          switches[index] = true;
          opentimeControllers[index].text = element.startTime ?? "09:00:00";
          closetimeControllers[index].text = element.endTime ?? "05:00:00";
        }
      });
    });
  }

  void updateTimes() {
    setState(() {
      for (int i = 0; i < switches.length; i++) {
        String day = weekday[i].substring(0, 3);
        int existingIndex = openCloseTimes.indexWhere(
          (entry) => entry['day'] == day,
        );

        if (switches[i]) {
          String openTime =
              opentimeControllers[i].text.isNotEmpty
                  ? opentimeControllers[i].text
                  : "09:00:00";
          String closeTime =
              closetimeControllers[i].text.isNotEmpty
                  ? closetimeControllers[i].text
                  : "05:00:00";

          if (existingIndex != -1) {
            openCloseTimes[existingIndex] = {
              "day": day,
              "openTime": openTime,
              "closeTime": closeTime,
            };
          } else {
            openCloseTimes.add({
              "day": day,
              "openTime": openTime,
              "closeTime": closeTime,
            });
          }
        } else {
          if (existingIndex != -1) {
            openCloseTimes.removeAt(existingIndex);
          }
        }
      }

      print("openCloseTimes == ${openCloseTimes}");

      String formattedTimes = openCloseTimes
          .map((time) {
            return "{day: '${time['day']}', openTime: '${time['openTime']}', closeTime: '${time['closeTime']}'}";
          })
          .join(",\n");

      print("Updated times:\n[$formattedTimes]");
    });
  }

  @override
  Widget build(BuildContext context) {
    weekday = [
      Languages.of(context)!.MonText,
      Languages.of(context)!.TueText,
      Languages.of(context)!.WedText,
      Languages.of(context)!.ThuText,
      Languages.of(context)!.FriText,
      Languages.of(context)!.SatText,
      Languages.of(context)!.SunText,
    ];
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
                Text(
                  Languages.of(context)!.EditProfileText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                // Username is already taken. Please choose another.
                print("usernameController ${usernameController.text}");
                print("saloncontroller ${saloncontroller.text}");
                print("usertype ${widget.userData["usertype"]}");
                if (usernameController.text.isEmpty) {
                  kToast(Languages.of(context)!.pleaseenterusernameText);
                }
                if (firstnameController.text.isEmpty) {
                  kToast(Languages.of(context)!.pleaseenterfirstnameText);
                } else if (lastnameController.text.isEmpty) {
                  kToast(Languages.of(context)!.pleaseenterlastnameText);
                } else if (saloncontroller.text.isEmpty &&
                    widget.userData["usertype"] != 1) {
                  kToast(Languages.of(context)!.pleaseentersalonnameText);
                } else if (emailController.text.isEmpty) {
                  kToast(Languages.of(context)!.pleaseenteremailText);
                } else if (ValidationChecks.validateEmail(
                      emailController.text,
                    ) ==
                    false) {
                  kToast(Languages.of(context)!.entervalidemailText);
                } else {
                  if (contactController.text.isNotEmpty) {
                    if (contactController.text.length != 10) {
                      kToast(
                        Languages.of(context)!.pleaseenter10digitnumberText,
                      );
                      return;
                    }
                  }
                  userProfileUpdate(
                    firstnameController.text,
                    lastnameController.text,
                    emailController.text,
                    saloncontroller.text,
                    contactController.text,
                    addressController.text,
                    widget.userData["usertype"],
                    // "${selectedStartday}-${selectedEndday}",
                    // opentimecontroller.text,
                    bioController.text,
                    websitecontroller.text,
                    Pallete.latitude.toString(),
                    Pallete.longtude.toString(),
                    openCloseTimes,
                    usernameController.text,
                  );
                }
              },
              icon: const Icon(Icons.done),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.topCenter,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45.0,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            widget.userData["profileImage"].isNotEmpty
                                ? NetworkImage(
                                  "${API.baseUrl}/api/${widget.userData["profileImage"]}",
                                )
                                : const AssetImage(
                                      "lib/assets/images/person.png",
                                    )
                                    as ImageProvider<Object>,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: Container(
                          height: 25.0,
                          width: 25.0,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 12.0,
                              ),
                            ],
                            color: AppColors.kblueColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await pickImage();
                            },
                            borderRadius: BorderRadius.circular(13),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 16.0,
                              color: AppColors.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // GestureDetector(
                      //   onTap: () async {
                      //     await pickImage();
                      //   },
                      //   child: Text(Languages.of(context)!.editpictureText,
                      //       style: Pallete.Quicksand15blackBold.copyWith(
                      //           color: Colors.blue)),
                      // )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    Languages.of(context)!.usernameText,
                    style: Pallete.Quicksand15blackwe300,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    maxLines: 1,
                    autocorrect: true,
                    onChanged: (value) {
                      if (widget.userData["username"] ==
                          usernameController.text) {
                        print("not change");
                      } else {
                        if (!checkedUsernames.contains(value) &&
                            value.isNotEmpty) {
                          checkedUsernames.add(value);
                          getcheckUsernameExist(value);
                        }
                      }
                    },
                    style: Pallete.textFieldTextStyle,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    controller: usernameController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.kTextColor,
                    decoration: Pallete.getTextfieldDecoration(
                      Languages.of(context)!.usernameText,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    Languages.of(context)!.firstNameText,
                    style: Pallete.Quicksand15blackwe300,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    maxLines: 1,
                    autocorrect: true,
                    style: Pallete.textFieldTextStyle,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    controller: firstnameController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.kTextColor,
                    decoration: Pallete.getTextfieldDecoration(
                      Languages.of(context)!.firstNameText,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    Languages.of(context)!.lastNameText,
                    style: Pallete.Quicksand15blackwe300,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    maxLines: 1,
                    autocorrect: true,
                    style: Pallete.textFieldTextStyle,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    controller: lastnameController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.kTextColor,
                    decoration: Pallete.getTextfieldDecoration(
                      Languages.of(context)!.lastNameText,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    Languages.of(context)!.EmailText,
                    style: Pallete.Quicksand15blackwe300,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    maxLines: 1,
                    autocorrect: true,
                    style: Pallete.textFieldTextStyle,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.kTextColor,
                    decoration: Pallete.getTextfieldDecoration(
                      Languages.of(context)!.EmailText,
                    ),
                  ),
                ),
                widget.userData["usertype"] == 1
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.BioText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            maxLines: null,
                            autocorrect: true,
                            style: Pallete.textFieldTextStyle,
                            // onChanged: _onTextChanged,
                            scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            controller: bioController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.kTextColor,
                            decoration: Pallete.getTextfieldDecoration(
                              Languages.of(context)!.BioText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // if (isTagUserShow)
                        //   ListView.builder(
                        //     itemCount: filteredUserList.length,
                        //     shrinkWrap: true,
                        //     physics: const NeverScrollableScrollPhysics(),
                        //     itemBuilder: (context, index) {
                        //       final user = filteredUserList[index];
                        //       return ListTile(
                        //         onTap: () => insertTag(user),
                        //         leading: user.profileImage != null &&
                        //                 user.profileImage!.isNotEmpty
                        //             ? Container(
                        //                 height: 40,
                        //                 width: 40,
                        //                 decoration: BoxDecoration(
                        //                   image: DecorationImage(
                        //                     fit: BoxFit.cover,
                        //                     image: NetworkImage(
                        //                         "${API.baseUrl}/api/${user.profileImage!}"),
                        //                   ),
                        //                   borderRadius: BorderRadius.circular(20),
                        //                 ),
                        //               )
                        //             : Container(
                        //                 height: 40,
                        //                 width: 40,
                        //                 decoration: BoxDecoration(
                        //                   color: Colors.black12,
                        //                   borderRadius: BorderRadius.circular(20),
                        //                 ),
                        //                 child: const Center(
                        //                   child: Icon(Icons.person),
                        //                 ),
                        //               ),
                        //         title: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               user.userName ?? '',
                        //               style:
                        //                   Pallete.Quicksand14Whiitewe600.copyWith(
                        //                 color: AppColors.kBlackColor,
                        //               ),
                        //             ),
                        //             Text(
                        //               "${user.firstName ?? ''}${user.lastName ?? ''}",
                        //               style:
                        //                   Pallete.Quicksand14Whiitewe500.copyWith(
                        //                 color: AppColors.kBlackColor,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //   ),

                        // Container(
                        //   margin: const EdgeInsets.only(left: 20, right: 20),
                        //   child: TextFormField(
                        //       maxLines: 1,
                        //       autocorrect: true,
                        //       style: Pallete.textFieldTextStyle,
                        //       scrollPadding: EdgeInsets.only(
                        //           bottom:
                        //               MediaQuery.of(context).viewInsets.bottom),
                        //       controller: addressController,
                        //       keyboardType: TextInputType.emailAddress,
                        //       textInputAction: TextInputAction.done,
                        //       cursorColor: AppColors.kTextColor,
                        //       decoration: Pallete.getTextfieldDecoration(
                        //         "Address",
                        //       )),
                        // ),
                        const SizedBox(height: 15),
                      ],
                    )
                    : Container(),
                widget.userData["usertype"] == 2
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.SalonnameText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            maxLines: 1,
                            autocorrect: true,
                            style: Pallete.textFieldTextStyle,
                            scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            controller: saloncontroller,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.kTextColor,
                            decoration: Pallete.getTextfieldDecoration(
                              Languages.of(context)!.SalonnameText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.BioText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            maxLines: null,
                            autocorrect: true,
                            style: Pallete.textFieldTextStyle,
                            // onChanged: _onTextChanged,
                            scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            controller: bioController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.kTextColor,
                            decoration: Pallete.getTextfieldDecoration(
                              Languages.of(context)!.BioText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.websiteText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            maxLines: null,
                            autocorrect: true,
                            style: Pallete.textFieldTextStyle,
                            // onChanged: _onTextChanged,
                            scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            controller: websitecontroller,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.kTextColor,
                            decoration: Pallete.getTextfieldDecoration(
                              Languages.of(context)!.websiteText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.telephonenumberText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            maxLines: 1,
                            autocorrect: true,
                            style: Pallete.textFieldTextStyle,
                            scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            controller: contactController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.kTextColor,
                            decoration: Pallete.getTextfieldDecoration(
                              Languages.of(context)!.telephonenumberText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            Languages.of(context)!.AddressText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                        ),
                        Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: TextFormField(
                                    readOnly: false,
                                    onTap: () {
                                      setState(() {});
                                    },
                                    style: Pallete.textFieldTextStyle,
                                    scrollPadding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                    controller: addressController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    cursorColor: AppColors.kTextColor,
                                    onFieldSubmitted: (value) {
                                      setState(() {});
                                      _predictions.clear();
                                      Pallete.closeKeyboard(context);

                                      setState(() {});
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _fetchPredictions(value);
                                      });
                                      if (value.isEmpty) {
                                        setState(() {
                                          _predictions.clear();
                                        });
                                      }
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      fillColor: AppColors.kWhiteColor,
                                      filled: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 14,
                                          ),
                                      hintText:
                                          Languages.of(context)!.AddressText,
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
                                const SizedBox(height: 15),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Text(
                                    "${Languages.of(context)!.OpenDaysText} & ${Languages.of(context)!.OpenTimeText}",
                                    style: Pallete.Quicksand15blackwe300,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: weekday.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 5,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    weekday[index],
                                                    style:
                                                        Pallete
                                                            .Quicksand15blackwe600,
                                                  ),
                                                ),
                                                Switch(
                                                  value: switches[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      switches[index] = value;

                                                      if (!switches[index]) {
                                                        opentimeControllers[index]
                                                            .text = "09:00:00";
                                                        closetimeControllers[index]
                                                            .text = "05:00:00";
                                                      }
                                                      updateTimes();
                                                    });
                                                  },
                                                  activeColor:
                                                      AppColors.kWhiteColor,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  inactiveThumbColor:
                                                      AppColors.kBlackColor,
                                                  inactiveTrackColor:
                                                      AppColors.kAppBArBGColor,
                                                  activeTrackColor:
                                                      AppColors.kPinkColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 2,
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: Center(
                                                      child: TextField(
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            Pallete
                                                                .Quicksand12Blackkwe400,
                                                        controller:
                                                            opentimeControllers[index],
                                                        readOnly: true,
                                                        onTap: () async {
                                                          TimeOfDay?
                                                          pickedTime =
                                                              await showTimePicker(
                                                                initialTime:
                                                                    opentimes[index],
                                                                context:
                                                                    context,
                                                              );
                                                          if (pickedTime !=
                                                              null) {
                                                            String
                                                            formattedTime =
                                                                DateFormat(
                                                                  'HH:mm:ss',
                                                                ).format(
                                                                  DateTime(
                                                                    DateTime.now()
                                                                        .year,
                                                                    DateTime.now()
                                                                        .month,
                                                                    DateTime.now()
                                                                        .day,
                                                                    pickedTime
                                                                        .hour,
                                                                    pickedTime
                                                                        .minute,
                                                                  ),
                                                                );
                                                            setState(() {
                                                              opentimeControllers[index]
                                                                      .text =
                                                                  formattedTime;

                                                              updateTimes();
                                                            });
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                          // suffixIcon: const Icon(
                                                          //   Icons.watch_later_outlined,
                                                          //   size: 20,
                                                          // ),
                                                          fillColor:
                                                              AppColors
                                                                  .kWhiteColor,
                                                          filled: true,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 10,
                                                              ),
                                                          hintText: "09:00:00",
                                                          hintStyle:
                                                              Pallete
                                                                  .Quicksand12Blackkwe400,
                                                          enabledBorder: const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                            borderSide: BorderSide(
                                                              width: 2,
                                                              color:
                                                                  AppColors
                                                                      .kBorderColor,
                                                            ),
                                                          ),
                                                          focusedBorder: const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                            borderSide: BorderSide(
                                                              width: 1,
                                                              color:
                                                                  AppColors
                                                                      .kBorderColor,
                                                            ),
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  Languages.of(context)!.toText,
                                                  style:
                                                      Pallete
                                                          .Quicksand12Blackkwe400,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 2,
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: Center(
                                                      child: TextField(
                                                        textAlign:
                                                            TextAlign.center,
                                                        controller:
                                                            closetimeControllers[index],
                                                        style:
                                                            Pallete
                                                                .Quicksand12Blackkwe400,
                                                        readOnly: true,
                                                        onTap: () async {
                                                          TimeOfDay?
                                                          pickedTime =
                                                              await showTimePicker(
                                                                initialTime:
                                                                    closetimes[index],
                                                                context:
                                                                    context,
                                                              );
                                                          if (pickedTime !=
                                                              null) {
                                                            String
                                                            formattedTime =
                                                                DateFormat(
                                                                  'HH:mm:ss',
                                                                ).format(
                                                                  DateTime(
                                                                    DateTime.now()
                                                                        .year,
                                                                    DateTime.now()
                                                                        .month,
                                                                    DateTime.now()
                                                                        .day,
                                                                    pickedTime
                                                                        .hour,
                                                                    pickedTime
                                                                        .minute,
                                                                  ),
                                                                );
                                                            setState(() {
                                                              closetimeControllers[index]
                                                                      .text =
                                                                  formattedTime;

                                                              updateTimes();
                                                            });
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                          // suffixIcon: const Icon(
                                                          //   Icons.watch_later_outlined,
                                                          //   size: 20,
                                                          // ),
                                                          fillColor:
                                                              AppColors
                                                                  .kWhiteColor,
                                                          filled: true,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 10,
                                                              ),
                                                          hintText: "05:00:00",
                                                          hintStyle:
                                                              Pallete
                                                                  .Quicksand12Blackkwe400,
                                                          enabledBorder: const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                            borderSide: BorderSide(
                                                              width: 2,
                                                              color:
                                                                  AppColors
                                                                      .kBorderColor,
                                                            ),
                                                          ),
                                                          focusedBorder: const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                ),
                                                            borderSide: BorderSide(
                                                              width: 1,
                                                              color:
                                                                  AppColors
                                                                      .kBorderColor,
                                                            ),
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: _predictions.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.kWhiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.klightGreyColor,
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.location_on_outlined,
                                    ),
                                    title: Text(
                                      _predictions[index],
                                      style: Pallete.Quicksand12drktxtGreywe500,
                                    ),
                                    onTap: () async {
                                      _selectPrediction(index);
                                      setState(() {
                                        _fetchPlaceDetails(_selectedPlaceId!);
                                      });

                                      Pallete.closeKeyboard(context);
                                      setState(() {
                                        addressController.text =
                                            _predictions[index];
                                        _predictions.clear();
                                      });

                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                    : Container(),
              ],
            ),
          ),
          isLoading
              ? Container(
                height: kSize.height,
                width: kSize.width,
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.kPinkColor),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  File image = File("");

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

  ProfilePhotoUpdate(String profile_image) async {
    print("get ProfilePhotoUpdate function call");
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

  List<UserList> tagUserList = [];

  getTagUserList(String type) async {
    print("get getTagUserList function call");
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
              isLoading = false;
              print("Success");
              SalonSearchListModel model =
                  Provider.of<SearchUserListViewModelViewModel>(
                        context,
                        listen: false,
                      ).searchuserlistresponse.response
                      as SalonSearchListModel;

              tagUserList = model.userList!;
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

  getcheckUsernameExist(String user_name) async {
    print("get getcheckUsernameExist function call");
    setState(() {
      // isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CheckUserNameExistViewModel>(
          context,
          listen: false,
        ).getcheckUsernameExist(user_name);
        if (Provider.of<CheckUserNameExistViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CheckUserNameExistViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              // isLoading = false;
              print("Success");
              CheckUsernameExistModel model =
                  Provider.of<CheckUserNameExistViewModel>(
                        context,
                        listen: false,
                      ).checkusernameexistresponse.response
                      as CheckUsernameExistModel;

              if (model.success == true) {
                kToast(Languages.of(context)!.usernamenotavailableText);
              }
            });
          } else {
            setState(() {
              // isLoading = false;
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
  // Future<void> getLatLong(String placeName) async {
  //   try {
  //     var locations = await locationFromAddress(placeName);
  //     for (var location in locations) {
  //       print(
  //           "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
  //       Pallete.getlatitude = location.latitude;
  //       Pallete.getlongitude = location.longitude;
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  // void showPlacePicker() async {
  //   LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
  //       builder: (context) => MapLocationPicker(
  //             iosApiKey,
  //             tapToSelectLocation: 'Tap to select this location',
  //             nearBy: "",
  //             findingPlace: 'Finding place...',
  //             noResultsFound: 'No results found',
  //             pinColor: Colors.red,
  //             autoTheme: true,
  //           )));

  //   print(result.latLng!.latitude);
  //   print(result.latLng!.longitude);
  //   print(result.formattedAddress);
  //   addressController.text = result.formattedAddress!;
  //   Pallete.getlatitude = result.latLng!.latitude;
  //   Pallete.getlongitude = result.latLng!.longitude;
  // }

  Future addressPicker(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.20,
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 15),
                // PlacesAutocomplete(
                //   barBackgroundColor:
                //       const MaterialStatePropertyAll(Colors.white),
                //   barElevation: const MaterialStatePropertyAll(0),
                //   dividerColor: Colors.white,
                //   viewBackgroundColor: Colors.white,
                //   apiKey: Platform.isIOS
                //       ? iosApiKey
                //       : Platform.isAndroid
                //           ? androidApiKey
                //           : "",
                //   language: "en",
                //   components: [Component(Component.country, "us")],
                //   barOverlayColor:
                //       const MaterialStatePropertyAll(Colors.white),
                //   onSuggestionSelected: (p0) {
                //     Navigator.pop(context);
                //     Navigator.pop(context);
                //   },
                //   onPlacesDetailsResponse: (value) {
                //     setState(() {
                //       addressController.text =
                //           value?.result.formattedAddress ?? "";

                //       getLatLong(addressController.text);
                //     });
                //   },
                // ),
                // MapAutoCompleteField(
                //   googleMapApiKey: Platform.isIOS
                //       ? iosApiKey
                //       : Platform.isAndroid
                //           ? androidApiKey
                //           : "",
                //   controller: addressController,
                //   itemBuilder: (BuildContext context, suggestion) {
                //     return ListTile(
                //       title: Text(suggestion.description),
                //     );
                //   },
                //   onSuggestionSelected: (suggestion) {
                //     addressController.text = suggestion.description;
                //     print(
                //         "suggestion.description == ${suggestion.description}");
                //     Navigator.pop(context);

                //     getLatLong(suggestion.description);
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  userProfileUpdate(
    String first_name,
    String last_name,
    String email,
    String salon_name,
    String contact_no,
    String address,
    int type,
    // String open_days,
    // String open_time,
    String bio,
    String websitecontroller,
    String latitude,
    String longitude,
    List<Map<String, String>> open_weekdays,
    String user_name,
  ) async {
    print("get userProfileUpdate function call");

    print("openingClosingTimes = ${openingClosingTimes}");
    print("open_weekdays = ${open_weekdays}");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<UpdateProfileViewModel>(
          context,
          listen: false,
        ).userProfileUpdate(
          userid,
          first_name,
          last_name,
          email,
          salon_name,
          contact_no,
          address,
          type,
          // open_days,
          // open_time,
          bio,
          websitecontroller,
          latitude,
          longitude,
          open_weekdays,
          user_name,
        );
        if (Provider.of<UpdateProfileViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<UpdateProfileViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoading = false;
              print("Success");
              ProfileUpdateModel model =
                  Provider.of<UpdateProfileViewModel>(
                        context,
                        listen: false,
                      ).updateprofileresponse.response
                      as ProfileUpdateModel;

              kToast(model.message!);

              print("model.message = ${model.message}");
              print("model.success = ${model.success}");

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

// class GetDayTimeWidet extends StatefulWidget {
//   final Function(List<Map<String, String>>) onTimeUpdate;

//   const GetDayTimeWidet({super.key, required this.onTimeUpdate});

//   @override
//   State<GetDayTimeWidet> createState() => _GetDayTimeWidetState();
// }

// class _GetDayTimeWidetState extends State<GetDayTimeWidet> {
//   late List<TextEditingController> opentimeControllers;
//   late List<TextEditingController> closetimeControllers;
//   late List<TimeOfDay> opentimes;
//   late List<TimeOfDay> closetimes;
//   late List<bool> switches;
//   late List<String> weekday;

//   @override
//   void dispose() {
//     // Dispose of controllers
//     for (var controller in opentimeControllers) {
//       controller.dispose();
//     }
//     for (var controller in closetimeControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Initialize lists
//     opentimeControllers = List.generate(7, (_) => TextEditingController());
//     closetimeControllers = List.generate(7, (_) => TextEditingController());
//     opentimes = List.generate(7, (_) => TimeOfDay.now());
//     closetimes = List.generate(7, (_) => TimeOfDay.now());
//     switches = List.generate(7, (_) => false);
//   }

//   void updateTimes() {
//     List<Map<String, String>> openCloseTimes = [];
//     for (int i = 0; i < switches.length; i++) {
//       if (switches[i]) {
//         String openTime = opentimeControllers[i].text.isNotEmpty
//             ? opentimeControllers[i].text
//             : "09:00 AM";
//         String closeTime = closetimeControllers[i].text.isNotEmpty
//             ? closetimeControllers[i].text
//             : "05:00 PM";

//         // Add only if the day is open
//         openCloseTimes.add({
//           "day": weekday[i].substring(0, 3), // Short form of day
//           "openTime": openTime,
//           "closeTime": closeTime,
//         });
//       }
//       // Skip the days that are closed
//     }

//     // Use join to concatenate the lines with newlines (\n)
//     String formattedTimes =
//         openCloseTimes.map((time) => "  ${time.toString()},").join("\n");

//     print("Updated times:\n$formattedTimes");
//   }

//   @override
//   Widget build(BuildContext context) {
//     weekday = [
//       Languages.of(context)!.MonText,
//       Languages.of(context)!.TueText,
//       Languages.of(context)!.WedText,
//       Languages.of(context)!.ThuText,
//       Languages.of(context)!.FriText,
//       Languages.of(context)!.SatText,
//       Languages.of(context)!.SunText,
//     ];
//     return Row(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: weekday.length,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               return Container(
//                 margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         weekday[index],
//                         style: Pallete.Quicksand15blackwe600,
//                       ),
//                     ),
//                     Switch(
//                       value: switches[index],
//                       onChanged: (value) {
//                         setState(() {
//                           switches[index] = value;

//                           if (!switches[index]) {
//                             opentimeControllers[index].text = "09:00 AM";
//                             closetimeControllers[index].text = "05:00 PM";
//                           }

//                           updateTimes();
//                         });
//                       },
//                       activeColor: AppColors.kWhiteColor,
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       inactiveThumbColor: AppColors.kBlackColor,
//                       inactiveTrackColor: AppColors.kAppBArBGColor,
//                       activeTrackColor: AppColors.kPinkColor,
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       flex: 2,
//                       child: SizedBox(
//                         height: 40,
//                         child: Center(
//                           child: TextField(
//                             textAlign: TextAlign.center,
//                             style: Pallete.Quicksand12Blackkwe400,
//                             controller: opentimeControllers[index],
//                             readOnly: true,
//                             onTap: () async {
//                               TimeOfDay? pickedTime = await showTimePicker(
//                                 initialTime: opentimes[index],
//                                 context: context,
//                               );
//                               if (pickedTime != null) {
//                                 String formattedTime =
//                                     DateFormat('hh:mm a').format(
//                                   DateTime(
//                                     DateTime.now().year,
//                                     DateTime.now().month,
//                                     DateTime.now().day,
//                                     pickedTime.hour,
//                                     pickedTime.minute,
//                                   ),
//                                 );
//                                 setState(() {
//                                   opentimeControllers[index].text =
//                                       formattedTime;

//                                   updateTimes();
//                                 });
//                               }
//                             },
//                             decoration: InputDecoration(
//                               // suffixIcon: const Icon(
//                               //   Icons.watch_later_outlined,
//                               //   size: 20,
//                               // ),
//                               fillColor: AppColors.kWhiteColor,
//                               filled: true,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 10),
//                               hintText: "09:00 AM",
//                               hintStyle: Pallete.Quicksand12Blackkwe400,
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(12)),
//                                 borderSide: BorderSide(
//                                   width: 2,
//                                   color: AppColors.kBorderColor,
//                                 ),
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(12)),
//                                 borderSide: BorderSide(
//                                   width: 1,
//                                   color: AppColors.kBorderColor,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       Languages.of(context)!.toText,
//                       style: Pallete.Quicksand12Blackkwe400,
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       flex: 2,
//                       child: SizedBox(
//                         height: 40,
//                         child: Center(
//                           child: TextField(
//                             textAlign: TextAlign.center,
//                             controller: closetimeControllers[index],
//                             style: Pallete.Quicksand12Blackkwe400,
//                             readOnly: true,
//                             onTap: () async {
//                               TimeOfDay? pickedTime = await showTimePicker(
//                                 initialTime: closetimes[index],
//                                 context: context,
//                               );
//                               if (pickedTime != null) {
//                                 String formattedTime =
//                                     DateFormat('hh:mm a').format(
//                                   DateTime(
//                                     DateTime.now().year,
//                                     DateTime.now().month,
//                                     DateTime.now().day,
//                                     pickedTime.hour,
//                                     pickedTime.minute,
//                                   ),
//                                 );
//                                 setState(() {
//                                   closetimeControllers[index].text =
//                                       formattedTime;

//                                   updateTimes();
//                                 });
//                               }
//                             },
//                             decoration: InputDecoration(
//                               // suffixIcon: const Icon(
//                               //   Icons.watch_later_outlined,
//                               //   size: 20,
//                               // ),
//                               fillColor: AppColors.kWhiteColor,
//                               filled: true,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 10),
//                               hintText: "05:00 PM",
//                               hintStyle: Pallete.Quicksand12Blackkwe400,
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(12)),
//                                 borderSide: BorderSide(
//                                   width: 2,
//                                   color: AppColors.kBorderColor,
//                                 ),
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(12)),
//                                 borderSide: BorderSide(
//                                   width: 1,
//                                   color: AppColors.kBorderColor,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         )
//       ],
//     );
//   }
// }
