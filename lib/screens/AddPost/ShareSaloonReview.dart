import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:five_pointed_star/five_pointed_star.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/createpostmodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/screens/AddPost/mentionTextifield.dart';
import 'package:pinkGossip/services/localnotification.dart';
import 'package:pinkGossip/utils/apiservice.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/customeCamara.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/viewModels/createpostviewmodel.dart';
import 'package:pinkGossip/viewModels/searchuserlistviewmodel.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class SharesaloonreviewPage extends StatefulWidget {
  final String id;
  const SharesaloonreviewPage({super.key, this.id = ''});

  @override
  State<SharesaloonreviewPage> createState() => _SharesaloonreviewPageState();
}

class _SharesaloonreviewPageState extends State<SharesaloonreviewPage>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool isLoadingPostReview = false;
  String userid = "";
  String salonid = "";

  SharedPreferences? pref;
  TextEditingController searchsaloncontroller = TextEditingController();

  File beforeImage = File("");
  File afterImage = File("");
  File otherData = File("");

  VideoPlayerController? _videoController;
  VideoPlayerController? controllerVideoDurationChk;

  List<UserList> salonUserlist = [];
  List<UserList> searchsalonlist = [];
  UserList? selectedUser;

  List<UserList> tagUserList = [];
  List<String> taggedUserIds = [];
  TextEditingController reviewcontroller = TextEditingController();

  bool isScanning = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  int totalStep = 5;
  int currentStep = 1;

  int totalcount = 0;

  int cleanlinesscount = 0;
  int stafffriendinesscount = 0;
  int organizationcount = 0;
  int timemanagementcount = 0;
  int moderncount = 0;
  int bookingprocesscount = 0;
  int communicationcount = 0;

  late List<CameraDescription> _cameras;
  camerainitialisation() async {
    _cameras = await availableCameras();
  }

  bool get wantKeepAlive => true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    camerainitialisation();
    if (widget.id.isNotEmpty) {
      salonid = widget.id;
    }
    getPrefValues();
  }

  getPrefValues() async {
    pref = await SharedPreferences.getInstance();
    userid = pref!.getString('userid')!;
    int? step = pref!.getInt("step");

    if (step != null) {
      // print("step${step}");
      salonid = pref!.getString('curruntsalonid')!;
      // print("salonid${salonid}");
      // print("beforimagepref${pref!.getString("beforeImage")}");
      String? path = pref!.getString("beforeImage");
      // print(File(path!).existsSync());

      if (path != null && File(path).existsSync()) {
        // print("beforeImage${path}");
        beforeImage = File(path);
      }
      String? path1 = pref!.getString("afterImage");
      if (path1 != null && File(path1).existsSync()) {
        // print("afterImage${path1}");
        afterImage = File(path1);
      }
      String? path2 = pref!.getString("otherData");
      if (path2 != null && File(path2).existsSync()) {
        // print("otherData${path2}");
        otherData = File(path2);
      }
      currentStep = pref!.getInt("step") ?? 0;
    }

    // getPickedMedia();
    await getSalonUserList();
    getTagUserList("1");
  }

  Future<File> saveImagePermanently(File image) async {
    final dir = await getApplicationDocumentsDirectory();

    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newPath = '${dir.path}/$fileName';

    final bytes = await image.readAsBytes(); // 👈 IMPORTANT

    final newFile = File(newPath);
    await newFile.writeAsBytes(bytes, flush: true);

    return newFile;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            Text(
              Languages.of(context)!.PostReviewText,
              style: Pallete.Quicksand16drkBlackBold,
            ),
            InkWell(
              onTap: () async {
                LocalNotificationService.cancelAfterImageNotifications();
                pref!.remove("step");
                pref!.remove("curruntsalonid");
                pref!.remove("beforeImage");
                pref!.remove("afterImage");
                pref!.remove("otherData");
                if (beforeImage.path.isNotEmpty ||
                    afterImage.path.isNotEmpty ||
                    otherData.path.isNotEmpty) {
                  clearPostDataAlert(context, kSize);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => BottomNavBar(index: 2),
                    ),
                    ModalRoute.withName('/'),
                  );
                }
              },
              child: Image.asset(
                "lib/assets/images/wrong.png",
                width: 22,
                color: AppColors.kBlackColor,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                getStepsHeaderIndicator(),
                getStep1UI(kSize),
                getStep2UI(kSize),
                getStep3UI(kSize),
                getStep4UI(kSize),
                getStep5UI(kSize),
              ],
            ),
          ),

          if (isLoadingPostReview)
            Container(
              height: kSize.height,
              width: kSize.width,
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future scanerBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  Languages.of(context)!.scanDescriptionText,
                  textAlign: TextAlign.center,
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(flex: 3, child: _buildQrView(context)),
            ],
          ),
        );
      },
    ).then((value) {
      //
    });
  }

  getStepsHeaderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        getStepIndicator(
          currentStep,
          totalStep,
          1,
          Languages.of(context)!.selectsalonText,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 1,
          width: 20,
          color: Colors.black,
        ),
        getStepIndicator(
          currentStep,
          totalStep,
          2,
          Languages.of(context)!.addbeforeText,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 1,
          width: 20,
          color: Colors.black,
        ),
        getStepIndicator(
          currentStep,
          totalStep,
          3,
          Languages.of(context)!.addafterText,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 1,
          width: 20,
          color: Colors.black,
        ),
        getStepIndicator(
          currentStep,
          totalStep,
          4,
          Languages.of(context)!.pictureVideoText,
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 1,
          width: 20,
          color: Colors.black,
        ),

        getStepIndicator(
          currentStep,
          totalStep,
          5,
          Languages.of(context)!.writereviewText,
        ),
      ],
    );
  }

  getStepIndicator(int currentStep, int totalStep, index, String title) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            //
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:
                  currentStep == index
                      ? AppColors.kPinkColor
                      : AppColors.drktxtGrey,
            ),
            child: Center(
              child: Text(
                "${index}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          textAlign: TextAlign.center,
          title,
          style:
              currentStep == index
                  ? Pallete.Quicksand10Blackkwe600.copyWith(fontSize: 8)
                  : Pallete.Quicksand10darkGreykwe500.copyWith(fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // var scanArea =
    //     (MediaQuery.of(context).size.width < 400 ||
    //             MediaQuery.of(context).size.height < 400)
    //         ? 150.0
    //         : 300.0;

    SharedPreferences? postReviewPref;
    return QRView(
      key: qrKey,
      // onQRViewCreated: _onQRViewCreated,
      onQRViewCreated: (controller) {
        setState(() {
          this.controller = controller;
        });
        controller.scannedDataStream.listen((scanData) {
          if (isScanning == true) return;

          setState(() {
            result = scanData;
          });

          if (result != null) {
            String dataString = result!.code!;
            print(dataString);
            List<String> parts = dataString.split(' ');
            setState(() {
              isScanning = true;
            });

            if (parts.isNotEmpty && parts[0] == "pinkgossipQRCode=2") {
              Navigator.pop(context);
              setState(() {
                salonid = parts[1];
                currentStep++;
              });
              postReviewPref!.setInt('idss', int.parse(salonid));

              controller.dispose();
              kToast(Languages.of(context)!.QRCodeScanSuccessfullyText);
            } else {
              controller.dispose();
              Navigator.pop(context);
              kToast(Languages.of(context)!.QRCodenotrecognizedText);
            }
          }
        });
      },
      overlay: QrScannerOverlayShape(
        overlayColor: Colors.white,
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: (MediaQuery.of(context).size.width * 60) / 100,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Languages.of(context)!.noPermissionText)),
      );
    }
  }

  getSalonUserList() async {
    setState(() {
      isLoading = true;
    });
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<SearchUserListViewModelViewModel>(
          context,
          listen: false,
        ).getsearchUserList("2", userid);
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

              salonUserlist = model.userList!;
              if (salonid.isNotEmpty) {
                for (final salon in salonUserlist) {
                  if (salon.id.toString() == salonid) {
                    selectedUser = salon;
                    salonid = salon.id.toString();
                    searchsaloncontroller.text = salon.salonName ?? '';
                    searchsalonlist.clear();
                    // currentStep = 2;
                    break;
                  }
                }
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

  getStep1UI(Size kSize) {
    return Visibility(
      visible: currentStep == 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              Languages.of(context)!.searchDescriptionText,
              textAlign: TextAlign.center,
              style: Pallete.Quicksand18drkkBlackColorwe500,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              maxLines: 1,
              controller: searchsaloncontroller,
              onFieldSubmitted: (value) async {
                SharedPreferences postReviewPref =
                    await SharedPreferences.getInstance();
                postReviewPref.remove('salonname');
                postReviewPref.remove('idss');
              },
              onChanged: (value) {
                if (searchsaloncontroller.text.trim().isNotEmpty) {
                  setState(() {
                    searchsalonlist =
                        salonUserlist
                            .where(
                              (user) => user.salonName!.toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            )
                            .toList();
                  });
                }
                print(
                  "searchsalonlist = = ${searchsalonlist.toList().toString()}",
                );
                if (searchsaloncontroller.text.isEmpty) {
                  searchsalonlist.clear();
                  setState(() {});
                }
              },
              autocorrect: true,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.kTextColor,
              decoration: InputDecoration(
                fillColor: AppColors.kWhiteColor,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                hintText: Languages.of(context)!.search2Text,
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
                  borderSide: BorderSide(width: 1, color: AppColors.kPinkColor),
                ),
                focusColor: AppColors.kPinkColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
          ),
          searchsaloncontroller.text.trim().length >= 2
              ? Card(
                color: AppColors.kWhiteColor,
                child: Column(
                  children:
                      searchsalonlist.map((user) {
                        final String imageUrl =
                            "${API.baseUrl}/api/${user.profileImage}";

                        debugPrint("Profile Image URL: $imageUrl");
                        return ListTile(
                          title: Row(
                            children: [
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17.5),
                                  child: Image.network(
                                    Uri.encodeFull(
                                      "${API.baseUrl}/api/${user.profileImage}",
                                    ),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.kPinkColor,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        ImageUtils.profileLogo,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(user.salonName!),
                            ],
                          ),
                          onTap: () async {
                            setState(() {
                              selectedUser = user;
                              salonid = user.id.toString();
                              searchsaloncontroller.text = user.salonName!;
                              searchsalonlist.clear();
                              currentStep++;
                              pref!.setInt("step", currentStep);

                              pref!.setString("curruntsalonid", salonid);
                            });

                            FocusScopeNode currentFocus = FocusScope.of(
                              context,
                            );
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                        );
                      }).toList(),
                ),
              )
              : Container(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              Languages.of(context)!.orText,
              textAlign: TextAlign.center,
              style: Pallete.Quicksand24drktxtGreywe500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            alignment: Alignment.center,
            width: kSize.width,
            child: Image.asset("lib/assets/images/qrcodeimage.png"),
          ),
          const SizedBox(height: 12),
          Container(
            height: 30,
            width: 150,
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () {
                scanerBottomSheet(context);
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.ScanQRcodeText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 55,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () async {
                print("continue tapppedd");

                if (searchsaloncontroller.text.isNotEmpty) {
                  currentStep++;
                  pref!.setInt("step", currentStep);
                  pref!.setString("curruntsalonid", salonid);
                  setState(() {});
                } else {
                  kToast(Languages.of(context)!.pleaseentersalonText);
                }
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.continueText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  getStep2UI(Size kSize) {
    return Visibility(
      visible: currentStep == 2,
      child: Column(
        children: [
          const SizedBox(height: 15),
          beforeImage.path == ""
              ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                height: kSize.height / 3.2,
                width: kSize.width / 1.8,
                child: Image.asset(ImageUtils.uploadimage, fit: BoxFit.cover),
              )
              : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                width: kSize.width / 1.8,
                height: kSize.height / 3.2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.file(beforeImage, fit: BoxFit.cover),
                ),
              ),
          const SizedBox(height: 15),
          Text(
            textAlign: TextAlign.center,
            Languages.of(context)!.ClicktotakeorselectyourbeforeimageText,
            style: Pallete.Quicksand15blackwe300,
          ),
          const SizedBox(height: 10),
          Container(
            height: 30,
            width: 150,
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () {
                print("add before");
                showPostOptionsBottomSheet(context, "Before", false);
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.uploadText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 55,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () async {
                if (beforeImage.path == "") {
                  kToast(Languages.of(context)!.pleaseaddbeforeimageText);
                } else {
                  print("SOURCE EXISTS: ${beforeImage.existsSync()}");

                  beforeImage = await saveImagePermanently(beforeImage);
                  //notification call
                  // 30 minutes pachi
                  print("local notification send 1 minuits ====${1001}");
                  LocalNotificationService.scheduleNotification(
                    id: 1001,
                    delay: const Duration(minutes: 30),
                  );

                  // 1 hour pachi
                  LocalNotificationService.scheduleNotification(
                    id: 1002,
                    delay: const Duration(hours: 1),
                  );
                  print("local notification send 2 minuits ====${1002}");

                  print("TARGET EXISTS: ${beforeImage.existsSync()}");
                  setState(() {
                    currentStep++;
                    pref!.setInt("step", currentStep);

                    pref!.setString("beforeImage", beforeImage.path);
                  });
                }
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.continueText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            width: kSize.width,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getBorderButtonDecoration(),
            child: InkWell(
              onTap: () async {
                setState(() {
                  currentStep--;
                });
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.previousText,
                  style: Pallete.Quicksand15blackwe600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showDeepLinkWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          // title: const Text(
          //   "Hey 💕 welcome on Pink Gossip",
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
          content: const Text(
            "You’re doing amazing btw 💕\n\nWant to win 150 points more?\n\nLeave a quick written review to help other Dolls choose with confidence ✨",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Later
              },
              child: Text(
                "Ok",
                style: Pallete.Quicksand14drktxtGreywe500.copyWith(
                  color: AppColors.kBlackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeepLinkWelcomeDialog2() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          content: const Text(
            "WOW 😍 look great!And you did amazing with your content 💕In one appointment, you collected 300 points.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Ok",
                style: Pallete.Quicksand14drktxtGreywe500.copyWith(
                  color: AppColors.kBlackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  showPostOptionsBottomSheet(
    BuildContext context,
    String type,
    bool needVideo,
  ) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              showOptionTextWithIcon(
                Languages.of(context)!.TakePhotoText,
                Icons.camera_alt_outlined,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CameraApp(
                            cameras: _cameras,
                            needVideo: needVideo,
                          ),
                    ),
                  ).then((value) async {
                    print(value);

                    if (value != null) {
                      if (type == "Before") {
                        beforeImage = value as File;
                        await _cropImage(beforeImage.path, type);
                      } else if (type == "After") {
                        afterImage = value as File;
                        await _cropImage(afterImage.path, type);
                      } else {
                        otherData = value as File;
                        String pathExtension = path.extension(otherData.path);
                        print("pathExtension ------->$pathExtension");
                        if (pathExtension == ".jpg") {
                          await _cropImage(otherData.path, type);
                        }
                      }
                    }
                    setState(() {});
                  });
                },
              ),
              showOptionTextWithIcon(
                Languages.of(context)!.PhotoLibraryText,
                Icons.photo_library_outlined,
                () {
                  Navigator.pop(context);
                  pickImageORVideo(type);
                },
              ),
              showOptionTextWithIcon(
                Languages.of(context)!.CancelText,
                Icons.cancel_outlined,
                () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    ).then((value) async {
      if (type == "Other") {
        if (otherData.path.endsWith('.mp4') ||
            otherData.path.endsWith('.MP4') ||
            otherData.path.endsWith('.mov')) {
          _videoController = null;
        }
      }
    });
  }

  showOptionTextWithIcon(String title, IconData iconData, Function() onTap) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Pallete.Quicksand15blackwe300),
            Icon(iconData, color: Colors.black),
          ],
        ),
      ),
    );
  }

  pickImageORVideo(String type) async {
    setState(() {
      if (type == "Before") {
        beforeImage = File("");
      } else if (type == "After") {
        afterImage = File("");
      } else {
        // Other
        otherData = File("");
      }
    });
    try {
      final XFile? result;
      if ((type == "Before") || (type == "After")) {
        result = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 95,
          maxHeight: 1080,
          maxWidth: 1080,
        );
      } else {
        result = await ImagePicker().pickMedia(
          imageQuality: 95,
          maxHeight: 1080,
          maxWidth: 1080,
        );
      }

      if (result != null) {
        print("result ${result.path}");
        if (result.path.endsWith('.mp4') ||
            result.path.endsWith('.MP4') ||
            result.path.endsWith('.mov')) {
          controllerVideoDurationChk = VideoPlayerController.file(
            File(result.path!),
          );
          await controllerVideoDurationChk!.initialize();
          final Duration duration = controllerVideoDurationChk!.value.duration;
          final file = File(result.path!);
          final int fileSize = await file.length();
          // Convert to MB
          final double fileSizeInMB = fileSize / (1024 * 1024);
          print("Video size: ==  ${fileSizeInMB.toStringAsFixed(2)} MB");

          if (duration.inSeconds > 60) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Languages.of(context)!.maximumuploadlimit60secondText,
                ),
              ),
            );
          } else if (fileSizeInMB > 20) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Languages.of(context)!.maximumuploadSize10mbText),
              ),
            );
          } else {
            otherData = File(result.path);
            _videoController = VideoPlayerController.file(otherData);
            await _videoController!.initialize();
          }

          await controllerVideoDurationChk!.dispose();
          setState(() {});
        } else {
          if (type == "Before") {
            beforeImage = File(result.path);
            await _cropImage(beforeImage!.path, type);
          } else if (type == "After") {
            afterImage = File(result.path);
            await _cropImage(afterImage!.path, type);
          } else {
            otherData = File(result.path);
            await _cropImage(otherData!.path, type);
          }
        }

        setState(() {});
      }
    } on PlatformException catch (error) {
      print('Failed to pick media: $error');
    }
  }

  _cropImage(String path, String type) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',

          toolbarColor: Colors.green,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          cropFrameColor: Colors.white,
          cropGridColor: Colors.transparent,
          showCropGrid: true,
          // Set fixed crop window size
          cropFrameStrokeWidth: 1,
        ),
        IOSUiSettings(
          title: '',
          resetButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
          rectWidth: 500,
          rectHeight: 500,
          minimumAspectRatio: 1,
          aspectRatioLockEnabled: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
      ],
    );
    File? selectfile;
    if (croppedFile != null) {
      setState(() {
        selectfile = File(croppedFile.path);
        if (type == "Before") {
          beforeImage = selectfile!;
        } else if (type == "After") {
          afterImage = selectfile!;
        } else {
          otherData = selectfile!;
        }
      });
    }
  }

  getStep3UI(Size kSize) {
    return Visibility(
      visible: currentStep == 3,
      child: Column(
        children: [
          const SizedBox(height: 15),
          afterImage.path == ""
              ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                height: kSize.height / 3.2,
                width: kSize.width / 1.8,
                child: Image.asset(ImageUtils.uploadimage, fit: BoxFit.cover),
              )
              : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                width: kSize.width / 1.8,
                height: kSize.height / 3.2,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.file(afterImage, fit: BoxFit.cover),
                ),
              ),
          const SizedBox(height: 15),
          Text(
            textAlign: TextAlign.center,
            Languages.of(context)!.ClicktotakeorselectyourAfterimageText,
            style: Pallete.Quicksand15blackwe300,
          ),
          const SizedBox(height: 10),
          Container(
            height: 30,
            width: 150,
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () {
                print("add after");
                showPostOptionsBottomSheet(context, "After", false);
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.uploadText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 55,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () async {
                if (afterImage.path == "") {
                  kToast(Languages.of(context)!.pleaseaddafterimageText);
                } else {
                  print("SOURCE EXISTS: ${afterImage.existsSync()}");
                  LocalNotificationService.cancelAfterImageNotifications();

                  afterImage = await saveImagePermanently(afterImage);

                  print("TARGET EXISTS: ${afterImage.existsSync()}");

                  setState(() {
                    currentStep++;
                    pref!.setInt("step", currentStep);

                    pref!.setString("afterImage", afterImage.path);
                  });
                }
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.continueText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            width: kSize.width,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getBorderButtonDecoration(),
            child: InkWell(
              onTap: () async {
                setState(() {
                  currentStep--;
                });
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.previousText,
                  style: Pallete.Quicksand15blackwe600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  getStep4UI(Size kSize) {
    return Visibility(
      visible: currentStep == 4,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: kSize.height / 3.2,
            width: kSize.width / 1.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
            ),
            child:
                otherData.path != ""
                    ? Container(
                      height: kSize.height / 3.2,
                      width: kSize.width / 1.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child:
                            otherData.path.endsWith('.mp4') ||
                                    otherData.path.endsWith('.MP4') ||
                                    otherData.path.endsWith('.mov')
                                ? showVideo(otherData)
                                : Image.file(
                                  File(otherData.path),
                                  fit: BoxFit.cover,
                                ),
                      ),
                    )
                    : Image.asset(
                      height: kSize.height / 3.2,
                      width: kSize.width / 1.8,
                      ImageUtils.uploadimage,
                      fit: BoxFit.cover,
                    ),
          ),

          const SizedBox(height: 15),
          Text(
            textAlign: TextAlign.center,
            Languages.of(context)!.uploadotherpictureorvideoText,
            style: Pallete.Quicksand15blackwe300,
          ),
          const SizedBox(height: 10),
          Container(
            height: 30,
            width: 150,
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () {
                print("add other");
                showPostOptionsBottomSheet(context, "Other", true);
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.uploadText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 55,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getButtonDecoration(),
            child: InkWell(
              onTap: () async {
                if (otherData.path == "") {
                  kToast(
                    Languages.of(context)!.pleaseselectatleastonepictureText,
                  );
                } else {
                  setState(() {
                    currentStep++;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showDeepLinkWelcomeDialog();
                    });
                    pref!.setInt("step", currentStep);
                    pref!.setString("otherData", otherData.path);
                  });
                }
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.continueText,
                  style: Pallete.buttonTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            width: kSize.width,
            margin: const EdgeInsets.only(left: 30, right: 30),
            decoration: Pallete.getBorderButtonDecoration(),
            child: InkWell(
              onTap: () async {
                setState(() {
                  currentStep--;
                });
              },
              child: Center(
                child: Text(
                  Languages.of(context)!.previousText,
                  style: Pallete.Quicksand15blackwe600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  showVideo(File? postData) {
    return Stack(
      children: [
        VideoPlayer(
          _videoController ??= VideoPlayerController.file(postData!)
            ..initialize().then((_) {
              setState(() {});
              // _videoController!.play();
            }),
        ),

        Center(
          child: GestureDetector(
            onTap: () {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
              setState(() {});
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.kPinkColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: AppColors.kWhiteColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getStep5UI(Size kSize) {
    return Visibility(
      visible: currentStep == 5,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                Languages.of(context)!.RatingText,
                style: Pallete.Quicksand15blackwe600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  Languages.of(context)!.CleanlinessText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  color: AppColors.klightGreyColor,
                  selectedColor: AppColors.kPinkColor,
                  defaultSelectedCount: cleanlinesscount,
                  onChange: (count) async {
                    SharedPreferences postReviewPref =
                        await SharedPreferences.getInstance();

                    setState(() {
                      cleanlinesscount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  cleanlinesscount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.StafffriendlinessText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  color: AppColors.klightGreyColor,
                  defaultSelectedCount: stafffriendinesscount,
                  selectedColor: AppColors.kPinkColor,
                  onChange: (count) async {
                    setState(() {
                      stafffriendinesscount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  stafffriendinesscount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.OrganizationText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  color: AppColors.klightGreyColor,
                  defaultSelectedCount: organizationcount,
                  selectedColor: AppColors.kPinkColor,
                  onChange: (count) async {
                    setState(() {
                      organizationcount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  organizationcount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.TimemanagementText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  defaultSelectedCount: timemanagementcount,
                  color: AppColors.klightGreyColor,
                  selectedColor: AppColors.kPinkColor,
                  onChange: (count) async {
                    setState(() {
                      timemanagementcount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  timemanagementcount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.ModernText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  color: AppColors.klightGreyColor,
                  selectedColor: AppColors.kPinkColor,
                  defaultSelectedCount: moderncount,
                  onChange: (count) async {
                    setState(() {
                      moderncount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  moderncount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.BookingprocessText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  color: AppColors.klightGreyColor,
                  selectedColor: AppColors.kPinkColor,
                  defaultSelectedCount: bookingprocesscount,
                  onChange: (count) async {
                    setState(() {
                      bookingprocesscount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  bookingprocesscount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  Languages.of(context)!.CommunicationText,
                  style: Pallete.Quicksand15blackwe600,
                ),
                const SizedBox(width: 10),
                FivePointedStar(
                  defaultSelectedCount: communicationcount,
                  color: AppColors.klightGreyColor,
                  selectedColor: AppColors.kPinkColor,
                  onChange: (count) async {
                    setState(() {
                      communicationcount = count;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  communicationcount.toString(),
                  style: Pallete.Quicksand18drkkBlackColorwe500,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                Languages.of(context)!.writereviewText,
                style: Pallete.Quicksand15blackwe600,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              height: kSize.height / 4,
              width: kSize.width,
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                border: Border.all(color: AppColors.kBorderColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MentionTextField(
                type: "PostReview",
                userList: tagUserList,
                storedata: reviewcontroller.text,
                onChanged: (txt) async {
                  print("txt = ${txt}");
                  setState(() {
                    reviewcontroller.text = txt;
                  });

                  reviewcontroller.addListener(() {});
                },
                onTaggedUserIdsChanged: (List<String> ids) {
                  if (ids.isNotEmpty) {
                    setState(() {
                      taggedUserIds = ids;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.topRight,
              child: Text(
                Languages.of(context)!.characterlimit500Text,
                style: Pallete.Quicksand14drktxtGreywe500,
              ),
            ),
            const SizedBox(height: 25),
            InkWell(
              child: Container(
                height: 55,
                decoration: Pallete.getButtonDecoration(),
                child: InkWell(
                  onTap: () async {
                    totalcount =
                        cleanlinesscount +
                        stafffriendinesscount +
                        organizationcount +
                        timemanagementcount +
                        moderncount +
                        bookingprocesscount +
                        communicationcount;
                    print("totalcount == ${totalcount}");
                    double avrageRating = totalcount / 7;
                    double averageRatingString = double.parse(
                      avrageRating.toStringAsFixed(1),
                    );
                    print("averageRatingString == ${averageRatingString}");
                    List<File> postsFiles = [];
                    postsFiles.add(otherData!);
                    createPost(
                      salonid,
                      userid,
                      beforeImage,
                      afterImage,
                      postsFiles,
                      "mp4",
                      averageRatingString,
                      "",
                      "",
                      reviewcontroller.text,
                      taggedUserIds,
                      "SalonReview",
                    );
                  },
                  child: Center(
                    child: Text(
                      Languages.of(context)!.submitReviewText,
                      style: Pallete.buttonTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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

  createPost(
    String salon_id,
    String user_id,
    File before_image,
    File after_image,
    List<File> other,
    String fileExtension,
    double rating,
    String reward_type,
    String reward_image,
    String review,
    List<String> tag_users,
    String post_type, {
    String rewardpoint = "0",
  }) async {
    print("get CreatePost function call === $other");
    setState(() {
      isLoadingPostReview = true;
    });
    print("mainfunc == ${rating}");

    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<CreatePostViewModel>(
          context,
          listen: false,
        ).CreatePost(
          salon_id,
          user_id,
          before_image,
          after_image,
          other,
          fileExtension,
          rating,
          reward_type,
          reward_image,
          review,
          tag_users,
          post_type,
          rewardpoint,
        );
        if (Provider.of<CreatePostViewModel>(
              context,
              listen: false,
            ).isLoading ==
            false) {
          if (Provider.of<CreatePostViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            setState(() {
              isLoadingPostReview = false;

              print("Success");
              CreatePostModel model =
                  Provider.of<CreatePostViewModel>(
                        context,
                        listen: false,
                      ).createpostresponse.response
                      as CreatePostModel;
              // _showDeepLinkWelcomeDialog2();
              kToast(
                "WOW 😍 look great!And you did amazing with your content 💕In one appointment, you collected 300 points.",
              );
              pref!.remove("step");
              pref!.remove("curruntsalonid");
              pref!.remove("beforeImage");
              pref!.remove("afterImage");
              pref!.remove("otherData");
              print("model message = ${model.message}");

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
          isLoadingPostReview = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  Future<dynamic> clearPostDataAlert(BuildContext context, Size kSize) {
    return showDialog(
      context: context,
      builder:
          (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: AlertDialog(
              backgroundColor: AppColors.kWhiteColor,
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              content: Text(
                Languages.of(context)!.postreviewcanceltitleText,
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
                            pref!.remove("step");
                            pref!.remove("curruntsalonid");
                            pref!.remove("beforeImage");
                            pref!.remove("afterImage");
                            pref!.remove("otherData");
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        BottomNavBar(index: 2),
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
}
