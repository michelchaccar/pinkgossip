// ignore_for_file: unnecessary_this, avoid_print, non_constant_identifier_names, use_build_context_synchronously, unnecessary_brace_in_string_interps
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/screens/AddPost/mentionTextifield.dart';
import 'package:pinkGossip/utils/apiservice.dart';
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/localfilevideoplay.dart';
import 'package:pinkGossip/utils/videoplayer.dart';
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:five_pointed_star/five_pointed_star.dart';
// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/models/createpostmodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/createpostviewmodel.dart';
import 'package:video_player/video_player.dart';
import '../../viewModels/searchuserlistviewmodel.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class AddPost extends StatefulWidget {
  String type;
  final Function(bool)? onImageSelected; // Make it nullable
  final Function(bool)? onImagetype1Selected; // Make it nullable
  String? usertype;

  AddPost({
    super.key,
    this.onImageSelected,
    this.onImagetype1Selected,
    this.usertype,
    required this.type,
  });

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  _unselectselectImage() {
    // Use a null check before calling the function
    if (widget.onImageSelected != null) {
      widget.onImageSelected!(
        false,
      ); // Use '!' only if you're sure it's not null
    }
  }

  _selectImage() {
    // Use a null check before calling the function
    if (widget.onImageSelected != null) {
      widget.onImageSelected!(
        true,
      ); // Use '!' only if you're sure it's not null
    }
  }

  _unselecttype1selectImage() {
    // Use a null check before calling the function
    if (widget.onImagetype1Selected != null) {
      widget.onImagetype1Selected!(
        false,
      ); // Use '!' only if you're sure it's not null
    }
  }

  _selecttype1Image() {
    // Use a null check before calling the function
    if (widget.onImagetype1Selected != null) {
      widget.onImagetype1Selected!(
        true,
      ); // Use '!' only if you're sure it's not null
    }
  }

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0; // Track which camera is active

  bool isLoading = false;
  File beforeImage = File("");
  File afterImage = File("");
  File otherImage = File("");
  File videoFilePath = File("");

  String salonid = "";

  List<UserList> userlist = [];
  List<UserList> searchsalonlist = [];
  UserList? selectedUser;
  bool isDropdownOpen = false;

  int totalcount = 0;

  int cleanlinesscount = 0;
  int stafffriendinesscount = 0;
  int organizationcount = 0;
  int timemanagementcount = 0;
  int moderncount = 0;
  int bookingprocesscount = 0;
  int communicationcount = 0;

  bool isScanning = false;

  TextEditingController reviewcontroller = TextEditingController();
  TextEditingController addcommentcontroller = TextEditingController();
  TextEditingController searchsaloncontroller = TextEditingController();

  void _closeCamera() {
    // Dispose the camera controller to release resources
    cameraController?.dispose();
    cameraController = null; // Reset the controller
    print("Camera has been closed.");
  }

  SharedPreferences? prefs;
  String userid = "";
  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;

    print("userid   ${userid}");
  }

  String userTyppe = "";
  String salonID = "";
  String addcommenttexttype2 = "";
  String writereviewsalonController = "";
  int steptype2 = 0;
  List<String> picsvideostype2 = [];
  List<String> picsvideostype1 = [];

  String salonname = "";
  int idss = 0;
  int steptype1 = 0;
  String beforeIMG = "";
  String afterIMG = "";

  getuserType() async {
    prefs = await SharedPreferences.getInstance();
    if (widget.usertype != "" && widget.usertype != null) {
      userTyppe = "2";
      print("in ifffff");
      print("in widget.usertype ${widget.usertype}");
    } else {
      print("in eelsee");
      userTyppe = prefs!.getString('userType')!;
    }

    salonID = prefs!.getString('salonid') ?? "";
    picsvideostype2 = prefs!.getStringList('picandvideostype2') ?? [];
    picsvideostype1 = prefs!.getStringList('picandvideostype1') ?? [];
    steptype2 = prefs!.getInt('steptype2') ?? 1;
    steptype1 = prefs!.getInt('steptype1') ?? 1;
    cleanlinesscount = prefs!.getInt('cleanlinessCount') ?? 0;
    stafffriendinesscount = prefs!.getInt('stafffriendlinessCount') ?? 0;
    organizationcount = prefs!.getInt('organizationCount') ?? 0;
    timemanagementcount = prefs!.getInt('timemanagementCount') ?? 0;
    moderncount = prefs!.getInt('modernCount') ?? 0;
    bookingprocesscount = prefs!.getInt('bookingprocessCount') ?? 0;
    communicationcount = prefs!.getInt('communicationCount') ?? 0;
    addcommenttexttype2 = prefs!.getString('addcommentype2') ?? "";
    writereviewsalonController =
        prefs!.getString('writereviewsalonController') ?? "";
    salonname = prefs!.getString('salonname') ?? "";
    beforeIMG = prefs!.getString('beforeimage') ?? "";
    afterIMG = prefs!.getString('afterimage') ?? "";
    idss = prefs!.getInt('idss') ?? 0;
    print("steptype2  == ${steptype2}");
    print("addcommenttexttype2  == ${addcommenttexttype2}");
    print("salonname  == ${salonname}");
    print("idss  == ${idss}");
    print("picsvideostype2 == ${picsvideostype2}");
    print("beforeIMG == ${beforeIMG}");
    print("steptype1 == ${steptype1}");
    print("afterIMG == ${afterIMG}");
    print("cleanlinesscount == ${cleanlinesscount}");
    print("stafffriendinesscount == ${stafffriendinesscount}");
    print("allOtherdata == ${allOtherdata}");

    /// USER TYPE 2 DATA STORE
    if (steptype2 != null) {
      salonselectindex = steptype2;
      if (steptype2 == 2) {
        salonstep1 = false;
        salonstep2 = true;
      } else {
        salonstep1 = true;
        salonstep2 = false;
      }
    }
    if (picsvideostype2.isNotEmpty) {
      setState(() {
        allOtherdata.clear();
        allOtherdata = picsvideostype2.map((path) => File(path)).toList();
      });
    }
    if (addcommenttexttype2.isNotEmpty) {
      addcommentcontroller.text = addcommenttexttype2;
    }

    /// USER TYPE 1 DATA STORE
    if (steptype1 != null) {
      selectindex = steptype1;
      if (steptype1 == 2) {
        step1 = false;
        step2 = true;
      } else if (steptype1 == 3) {
        step2 = false;
        step1 = false;
        step3 = true;
      } else if (steptype1 == 4) {
        step2 = false;
        step1 = false;
        step3 = false;
        step4 = true;
      } else if (steptype1 == 5) {
        step2 = false;
        step1 = false;
        step3 = false;
        step4 = false;
        step5 = true;
      } else {}
    }
    if (salonname.isNotEmpty) {
      searchsaloncontroller.text = salonname;
    }
    if (idss != null) {
      salonid = idss.toString();
    }
    if (beforeIMG.isNotEmpty) {
      beforeImage = File(beforeIMG);
      print("beforeImage == ${beforeImage}");
    }
    if (afterIMG.isNotEmpty) {
      afterImage = File(afterIMG);
    }
    if (picsvideostype1.isNotEmpty) {
      allOtherdatatype1.clear();
      allOtherdatatype1 = picsvideostype1.map((path) => File(path)).toList();
    }
    if (writereviewsalonController.isNotEmpty) {
      reviewcontroller.text = writereviewsalonController;
    }
  }

  ////// pick Before Image
  Future<void> pickBeforeImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (image == null) return;

      await _cropImagepickBeforeImage(File(image.path));
    } on PlatformException catch (error) {
      print('Failed to pick image: $error');
    }
  }

  Future<void> _cropImagepickBeforeImage(File image) async {
    print("calling 1");
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
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
      });
    }
    SharedPreferences postReviewPref = await SharedPreferences.getInstance();

    await postReviewPref.remove('beforeimage');

    final imageTemp = File(selectfile!.path);
    setState(() => this.beforeImage = imageTemp);
    await postReviewPref.setString('beforeimage', selectfile!.path);

    String? savedList = postReviewPref.getString('beforeimage');
    print('Retrieved after saving: $savedList');

    print("IMAGE PATH = ${selectfile!.path}");
  }

  //////
  ///
  ////// pick After Image
  Future<void> pickAfterImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (image == null) return;

      await _cropImagepickAfterImage(File(image.path));
    } on PlatformException catch (error) {
      print('Failed to pick image: $error');
    }
  }

  Future<void> _cropImagepickAfterImage(File i0mage) async {
    print("calling 2");
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: i0mage.path,
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
      });
    }
    SharedPreferences postReviewPref = await SharedPreferences.getInstance();

    await postReviewPref.remove('afterimage');

    final imageTemp = File(selectfile!.path);
    setState(() => this.afterImage = imageTemp);
    await postReviewPref.setString('afterimage', selectfile!.path);

    String? savedList = postReviewPref.getString('afterimage');
    print('Retrieved after saving: $savedList');

    print("IMAGE PATH = ${selectfile!.path}");
  }

  ///////
  ///
  ///
  int selectindex = 1;
  bool step1 = true;
  bool step2 = false;
  bool step3 = false;
  bool step4 = false;
  bool step5 = false;

  int salonselectindex = 1;
  bool salonstep1 = true;
  bool salonstep2 = false;
  bool salonstep3 = false;
  bool salonstep4 = false;

  List<String> pickedImages = [];
  List<String> pickedVideos = [];
  List<File> allOtherdata = [];
  List<File> allOtherdatatype1 = [];

  @override
  void reassemble() {
    super.reassemble();
    // if (Platform.isAndroid) {
    //   controller!.pauseCamera();
    // }
    // controller!.resumeCamera();
  }

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  ////////
  //// TYPE 1 PICTUREANDVIDEO PICKER
  Future<void> pickAllOtherVideoORImage() async {
    try {
      final List<XFile> result = await ImagePicker().pickMultipleMedia();
      allOtherdata.clear();
      print("result ${result.toString()}");
      if (result.isNotEmpty) {
        await _cropImagespickAllOtherVideoORImage(result);
      }
    } on PlatformException catch (error) {
      print('Failed to pick media: $error');
    }
  }

  Future<void> _cropImagespickAllOtherVideoORImage(
    List<XFile> imageFiles,
  ) async {
    print("calling 3");

    List<File> croppedFiles = [];

    for (var imageFile in imageFiles) {
      print("imageFile.path ${imageFile.path}");

      // Launch the image editor
      File? editedFile = await _openImageEditor(File(imageFile.path));

      if (editedFile != null) {
        print('Edited file path: ${editedFile.path}');
        croppedFiles.add(editedFile);
      }
    }

    // Save edited file paths to SharedPreferences
    List<String> picandvideostype2Pref = [];
    SharedPreferences postReviewPref = await SharedPreferences.getInstance();

    // Clear existing saved list
    await postReviewPref.remove('picandvideostype2');

    // Clear and update your app state list
    allOtherdata.clear();
    for (var file in croppedFiles) {
      allOtherdata.add(file);
      picandvideostype2Pref.add(file.path);
    }

    // Save to preferences
    await postReviewPref.setStringList(
      'picandvideostype2',
      picandvideostype2Pref,
    );

    // Debugging
    print("pickedImages = $pickedImages");
    print("pickedVideos = $pickedVideos");
    print("allOtherdata = $allOtherdata");

    // Trigger UI rebuild
    setState(() {});

    // Confirm saved list
    List<String>? savedList = postReviewPref.getStringList('picandvideostype2');
    print('Retrieved list after saving: $savedList');
    print("croppedFiles = $croppedFiles");
  }

  Future<File?> _openImageEditor(File file) async {
    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProImageEditor.file(
              file,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (Uint8List bytes) async {
                  final editedFile = await CommonFunctions().convertUint8ListToFile(
                    bytes,
                    'edited_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  );

                  Navigator.pop(context, editedFile); // ✅ Return edited file
                },
              ),
            ),
      ),
    );

    return result;
  }

  Future<bool> _wasFrontCameraUsed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFrontCamera') ?? false; // Default to back camera
  }

  // Function to flip image only if taken with front camera
  Future<File> _fixMirroredImage(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());

    if (rawImage != null) {
      final flippedImage = img.flipHorizontal(
        rawImage,
      ); // Flip only front camera images
      final fixedFile = File(imageFile.path)
        ..writeAsBytesSync(img.encodeJpg(flippedImage));
      return fixedFile;
    }
    return imageFile; // Return original if decoding fails
  }

  Future<void> pickAllOtherVideoORImageType1() async {
    try {
      final List<XFile> result = await ImagePicker().pickMultipleMedia();
      allOtherdatatype1.clear();

      if (result.isNotEmpty) {
        await _cropImagespickAllOtherVideoORImageType1(result);
      }
    } on PlatformException catch (error) {
      print('Failed to pick media: $error');
    }
  }

  Future<void> _cropImagespickAllOtherVideoORImageType1(
    List<XFile> imageFiles,
  ) async {
    print("calling 4");
    List<File> croppedFiles = [];

    for (var imageFile in imageFiles) {
      print("imageFile.path ${imageFile.path}");
      if (imageFile.path.endsWith(".jpg") ||
          imageFile.path.endsWith(".jpeg") ||
          imageFile.path.endsWith(".png")) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
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
        if (croppedFile != null) {
          croppedFiles.add(File(croppedFile.path));
        }
      } else {
        croppedFiles.add(File(imageFile.path));
      }
    }

    List<String> picandvideostype1Pref = [];
    SharedPreferences postReviewPref = await SharedPreferences.getInstance();
    List<File> fileList = [];
    setState(() async {
      fileList = croppedFiles;
      await postReviewPref.remove('picandvideostype1');

      for (var file in fileList) {
        allOtherdatatype1.add(File(file.path));
        picandvideostype1Pref.add(file.path);
      }
      print("pickedImages = ${pickedImages}");
      print("pickedVideos = ${pickedVideos}");
      print("allOtherdatatype1 = ${allOtherdatatype1}");

      setState(() {});

      await postReviewPref.setStringList(
        'picandvideostype1',
        picandvideostype1Pref,
      );

      List<String>? savedList = postReviewPref.getStringList(
        'picandvideostype1',
      );
      print('Retrieved list after saving: $savedList');

      print("croppedFiles ${croppedFiles}");
    });
  }

  List<UserList> tagUserList = [];
  List<String> taggedUserIds = [];

  @override
  void initState() {
    super.initState();
    getuserid();
    getUserList();
    getuserType();
    getTagUserList("1");
    // initializeCamera(selectedCameraIndex);
  }

  Future<void> initializeCamera(int cameraIndex) async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras![cameraIndex],
        ResolutionPreset.high,
      );
      await cameraController!.initialize();
      if (mounted) {
        setState(() {}); // Refresh UI after initialization
      }
    }
  }

  void toggleDropdown() {
    setState(() {
      getUserList();
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  String? code;
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
            Text(
              Languages.of(context)!.PostReviewText,
              style: Pallete.Quicksand16drkBlackBold,
            ),
            InkWell(
              onTap: () async {
                ClearPostDataAlert(context, kSize);
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
          userTyppe == "2"
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: kSize.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.topCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  // setState(() {
                                  //   salonselectindex = 1;
                                  //   salonstep1 = true;
                                  //   salonstep2 = false;
                                  // });
                                  _unselectselectImage();
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();
                                  int stepcount = 0;

                                  setState(() {
                                    salonselectindex = salonselectindex - 1;
                                    salonstep1 = true;
                                    salonstep2 = false;

                                    postReviewPref.setInt(
                                      'steptype2',
                                      salonselectindex,
                                    );

                                    stepcount =
                                        postReviewPref.getInt('steptype2')!;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        salonselectindex == 1
                                            ? AppColors.kPinkColor
                                            : AppColors.drktxtGrey,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "1",
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
                                Languages.of(context)!.pictureVideoText,
                                style:
                                    salonselectindex == 1
                                        ? Pallete.Quicksand10Blackkwe600
                                        : Pallete.Quicksand10darkGreykwe500,
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1,
                            width: 20,
                            color: Colors.black,
                          ),
                          Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();

                                  if (allOtherdata.isNotEmpty) {
                                    _selectImage();

                                    int stepcount = 0;
                                    setState(() {
                                      salonselectindex = salonselectindex + 1;
                                      salonstep1 = false;
                                      salonstep2 = true;

                                      postReviewPref.setInt(
                                        'steptype2',
                                        salonselectindex,
                                      );

                                      stepcount =
                                          postReviewPref.getInt('steptype2')!;

                                      setState(() {
                                        salonselectindex = 2;
                                        salonstep1 = false;
                                        salonstep2 = true;
                                      });
                                      print("stepcount == ${stepcount}");
                                    });
                                  } else {
                                    kToast(
                                      Languages.of(
                                        context,
                                      )!.pleaseselectatleastonepictureText,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        salonselectindex == 2
                                            ? AppColors.kPinkColor
                                            : AppColors.drktxtGrey,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "2",
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
                                Languages.of(context)!.submitpostText,
                                style:
                                    salonselectindex == 2
                                        ? Pallete.Quicksand10Blackkwe600
                                        : Pallete.Quicksand10darkGreykwe500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: salonstep1,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          allOtherdata.isNotEmpty
                              ? SizedBox(
                                height: kSize.height / 2,
                                width: kSize.width - 10,
                                child: PageView.builder(
                                  itemCount: allOtherdata.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        SizedBox(
                                          height: kSize.height / 2,
                                          width: kSize.width - 10,
                                          child:
                                              allOtherdata[index].path.endsWith(
                                                        '.mp4',
                                                      ) ||
                                                      allOtherdata[index].path
                                                          .endsWith('.mov')
                                                  ? SizedBox(
                                                    height: kSize.height / 2,
                                                    width: kSize.width - 10,
                                                    child: VideoDisplay(
                                                      selectedAsset: File(
                                                        allOtherdata[index]
                                                            .path,
                                                      ),
                                                    ),
                                                  )
                                                  : Container(
                                                    height: kSize.height / 2,
                                                    width: kSize.width - 10,

                                                    // width:
                                                    //     kSize.width / 1.8,
                                                    // height:
                                                    //     kSize.height / 3.2,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black12,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            1.0,
                                                          ),
                                                      child: Image.file(
                                                        File(
                                                          allOtherdata[index]
                                                              .path,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                        allOtherdata.length > 1
                                            ? Positioned(
                                              top: 8,
                                              right: 10,
                                              child: Container(
                                                height: 25,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: Colors.black45,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}/${allOtherdata.length}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            : Container(),
                                      ],
                                    );
                                  },
                                ),
                              )
                              : Container(
                                height: kSize.height / 2,
                                width: kSize.width - 10,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Image.asset(
                                  ImageUtils.uploadimage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          const SizedBox(height: 5),
                          Text(
                            Languages.of(context)!.UploadpictureorvideoText,
                            style: Pallete.Quicksand16drktxtGreywe500,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 30,
                            width: 150,
                            decoration: Pallete.getButtonDecoration(),
                            child: InkWell(
                              onTap: () {
                                open_bottomsheet_noramPost(context);
                              },
                              child: Center(
                                child: Text(
                                  Languages.of(context)!.uploadText,
                                  style: Pallete.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            height: 55,
                            margin: const EdgeInsets.only(left: 30, right: 30),
                            decoration: Pallete.getButtonDecoration(),
                            child: InkWell(
                              onTap: () async {
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();

                                if (allOtherdata.isNotEmpty) {
                                  _selectImage();

                                  int stepcount = 0;
                                  setState(() {
                                    salonselectindex = salonselectindex + 1;
                                    salonstep1 = false;
                                    salonstep2 = true;

                                    postReviewPref.setInt(
                                      'steptype2',
                                      salonselectindex,
                                    );

                                    stepcount =
                                        postReviewPref.getInt('steptype2')!;

                                    print("stepcount == ${stepcount}");
                                  });
                                } else {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseselectatleastonepictureText,
                                  );
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
                        ],
                      ),
                    ),
                    Visibility(
                      visible: salonstep2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              height: 200,
                              width: kSize.width,
                              decoration: BoxDecoration(
                                color: AppColors.kWhiteColor,
                                border: Border.all(
                                  color: AppColors.kBorderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: MentionTextField(
                                userList: tagUserList,
                                type: "PostReviewTyp2",
                                storedata: addcommentcontroller.text,
                                onChanged: (txt) async {
                                  print("txt = ${txt}");
                                  setState(() {
                                    addcommentcontroller.text = txt;
                                  });

                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();

                                  addcommentcontroller.addListener(() {
                                    print(
                                      "objeaddcommentcontroller = ${addcommentcontroller.text}",
                                    );
                                    postReviewPref.setString(
                                      'addcommentype2',
                                      addcommentcontroller.text,
                                    );
                                  });
                                },
                                onTaggedUserIdsChanged: (List<String> ids) {
                                  if (ids.isNotEmpty) {
                                    setState(() {
                                      taggedUserIds = ids;
                                    });
                                    print(
                                      "Currently Tagged User IDs: ${taggedUserIds.join(', ')}",
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            InkWell(
                              child: Container(
                                height: 55,
                                decoration: Pallete.getButtonDecoration(),
                                child: InkWell(
                                  onTap: () async {
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    await postReviewPref.remove(
                                      'picandvideostype2',
                                    );
                                    await postReviewPref.remove(
                                      'addcommentype2',
                                    );
                                    await postReviewPref.setInt('steptype2', 1);

                                    CreatePost(
                                      userid,
                                      userid,
                                      File(""),
                                      File(""),
                                      allOtherdata,
                                      "",
                                      0,
                                      "",
                                      "",
                                      addcommentcontroller.text,
                                      taggedUserIds,
                                      "NormalPost",
                                    );
                                    print("allOtherdata = ${allOtherdata}");

                                    print(
                                      "createe post == ${salonID} ${userid} ${allOtherdata} ${addcommentcontroller.text}",
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.submitpostText,
                                      style: Pallete.buttonTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 60,
                              width: kSize.width,
                              decoration: Pallete.getBorderButtonDecoration(),
                              child: InkWell(
                                onTap: () async {
                                  _unselectselectImage();
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();
                                  int stepcount = 0;

                                  setState(() {
                                    salonselectindex = salonselectindex - 1;
                                    salonstep1 = true;
                                    salonstep2 = false;

                                    postReviewPref.setInt(
                                      'steptype2',
                                      salonselectindex,
                                    );

                                    stepcount =
                                        postReviewPref.getInt('steptype2')!;
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
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: kSize.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();
                                    _unselecttype1selectImage();
                                    int stepcount = 0;
                                    setState(() {
                                      selectindex = 1;
                                      step1 = true;
                                      step2 = false;

                                      postReviewPref.setInt(
                                        'steptype1',
                                        selectindex,
                                      );

                                      stepcount =
                                          postReviewPref.getInt('steptype1')!;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          selectindex == 1
                                              ? AppColors.kPinkColor
                                              : AppColors.drktxtGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "1",
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
                                  Languages.of(context)!.selectsalonText,
                                  textAlign: TextAlign.center,
                                  style:
                                      selectindex == 1
                                          ? Pallete.Quicksand10Blackkwe600
                                          : Pallete.Quicksand10darkGreykwe500,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1,
                            width: 20,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();
                                    int stepcount = 0;
                                    if (searchsaloncontroller.text.isNotEmpty) {
                                      String? salonNAME = postReviewPref
                                          .getString('salonname');
                                      print("salonNAME == ${salonNAME}");
                                      if (salonNAME!.isNotEmpty) {
                                        _selecttype1Image();
                                        setState(() {
                                          selectindex = selectindex + 1;
                                          step1 = false;
                                          step2 = true;
                                        });

                                        postReviewPref.setInt(
                                          'steptype1',
                                          selectindex,
                                        );

                                        stepcount =
                                            postReviewPref.getInt('steptype1')!;

                                        setState(() {
                                          selectindex = 2;
                                          step1 = false;
                                          step2 = true;
                                          step3 = false;
                                          step4 = false;
                                          step5 = false;
                                        });

                                        print("salonid == ${salonid}");
                                      } else {
                                        if (selectedUser!.salonName ==
                                            searchsaloncontroller.text) {
                                          setState(() {
                                            selectindex = selectindex + 1;
                                            step1 = false;
                                            step2 = true;
                                          });

                                          postReviewPref.setInt(
                                            'steptype1',
                                            selectindex,
                                          );

                                          stepcount =
                                              postReviewPref.getInt(
                                                'steptype1',
                                              )!;

                                          print("salonid == ${salonid}");
                                          setState(() {
                                            selectindex = 2;
                                            step1 = false;
                                            step2 = true;
                                            step3 = false;
                                            step4 = false;
                                            step5 = false;
                                          });
                                        } else {
                                          kToast(
                                            Languages.of(
                                              context,
                                            )!.pleaseselectvalidsalonText,
                                          );
                                        }
                                      }
                                    } else {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseentersalonText,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          selectindex == 2
                                              ? AppColors.kPinkColor
                                              : AppColors.drktxtGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "2",
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
                                  Languages.of(context)!.addbeforeText,
                                  textAlign: TextAlign.center,
                                  style:
                                      selectindex == 2
                                          ? Pallete.Quicksand10Blackkwe600
                                          : Pallete.Quicksand10darkGreykwe500,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1,
                            width: 20,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    if (searchsaloncontroller.text.isEmpty) {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseentersalonText,
                                      );
                                    } else if (beforeImage.path == "") {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseaddbeforeimageText,
                                      );
                                    } else {
                                      SharedPreferences postReviewPref =
                                          await SharedPreferences.getInstance();
                                      int stepcount = 0;

                                      setState(() {
                                        selectindex = selectindex + 1;
                                        step2 = false;
                                        step3 = true;
                                      });
                                      postReviewPref.setInt(
                                        'steptype1',
                                        selectindex,
                                      );

                                      stepcount =
                                          postReviewPref.getInt('steptype1')!;
                                      setState(() {
                                        selectindex = 3;
                                        step1 = false;
                                        step2 = false;
                                        step3 = true;
                                        step4 = false;
                                        step5 = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          selectindex == 3
                                              ? AppColors.kPinkColor
                                              : AppColors.drktxtGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "3",
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
                                  Languages.of(context)!.addafterText,
                                  textAlign: TextAlign.center,
                                  style:
                                      selectindex == 3
                                          ? Pallete.Quicksand10Blackkwe600
                                          : Pallete.Quicksand10darkGreykwe500,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1,
                            width: 20,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    if (searchsaloncontroller.text.isEmpty) {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseentersalonText,
                                      );
                                    } else if (beforeImage.path == "") {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseaddbeforeimageText,
                                      );
                                    } else if (afterImage.path == "") {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseaddbeforeimageText,
                                      );
                                    } else {
                                      SharedPreferences postReviewPref =
                                          await SharedPreferences.getInstance();

                                      int stepcount = 0;
                                      if (afterImage.path == "") {
                                        kToast(
                                          Languages.of(
                                            context,
                                          )!.pleaseaddafterimageText,
                                        );
                                      } else {
                                        setState(() {
                                          selectindex = selectindex + 1;
                                          step3 = false;
                                          step4 = true;
                                        });
                                        postReviewPref.setInt(
                                          'steptype1',
                                          selectindex,
                                        );

                                        stepcount =
                                            postReviewPref.getInt('steptype1')!;
                                        setState(() {
                                          selectindex = 4;
                                          step1 = false;
                                          step2 = false;
                                          step3 = false;
                                          step4 = true;
                                          step5 = false;
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          selectindex == 4
                                              ? AppColors.kPinkColor
                                              : AppColors.drktxtGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "4",
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
                                  Languages.of(context)!.pictureVideoText,
                                  style:
                                      selectindex == 4
                                          ? Pallete.Quicksand10Blackkwe600
                                          : Pallete.Quicksand10darkGreykwe500,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1,
                            width: 20,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    if (searchsaloncontroller.text.isEmpty) {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseentersalonText,
                                      );
                                    } else if (beforeImage.path == "") {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseaddbeforeimageText,
                                      );
                                    } else if (afterImage.path == "") {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseaddbeforeimageText,
                                      );
                                    } else {
                                      SharedPreferences postReviewPref =
                                          await SharedPreferences.getInstance();

                                      int stepcount = 0;
                                      print("otherImage ==== $otherImage");
                                      setState(() {
                                        selectindex = selectindex + 1;
                                        step4 = false;
                                        step5 = true;
                                      });
                                      postReviewPref.setInt(
                                        'steptype1',
                                        selectindex,
                                      );

                                      stepcount =
                                          postReviewPref.getInt('steptype1')!;

                                      setState(() {
                                        selectindex = 5;
                                        step1 = false;
                                        step2 = false;
                                        step3 = false;
                                        step4 = false;
                                        step5 = true;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          selectindex == 5
                                              ? AppColors.kPinkColor
                                              : AppColors.drktxtGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "5",
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
                                  Languages.of(context)!.writereviewText,
                                  style:
                                      selectindex == 5
                                          ? Pallete.Quicksand10Blackkwe600
                                          : Pallete.Quicksand10darkGreykwe500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: step1,
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

                                print("onFieldSubmitted ");

                                postReviewPref.remove('salonname');
                                postReviewPref.remove('idss');
                              },
                              onChanged: (value) {
                                if (searchsaloncontroller.text
                                    .trim()
                                    .isNotEmpty) {
                                  setState(() {
                                    searchsalonlist =
                                        userlist
                                            .where(
                                              (user) => user.salonName!
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  ),
                                            )
                                            .toList();
                                  });
                                }
                                if (searchsaloncontroller.text.isEmpty) {
                                  searchsalonlist.clear();
                                  setState(() {});
                                }
                              },
                              autocorrect: true,
                              scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
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
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35),
                                  ),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: AppColors.kTextFieldBorderColor,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35),
                                  ),
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
                          searchsaloncontroller.text.trim().length >= 2
                              ? Card(
                                color: AppColors.kWhiteColor,
                                child: Column(
                                  children:
                                      searchsalonlist.map((user) {
                                        return ListTile(
                                          title: Row(
                                            children: [
                                              Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        17.5,
                                                      ),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                      "${API.baseUrl}/api/${user.profileImage}",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(user.salonName!),
                                            ],
                                          ),
                                          onTap: () async {
                                            SharedPreferences postReviewPref =
                                                await SharedPreferences.getInstance();

                                            setState(() {
                                              selectedUser = user;
                                              salonid = user.id.toString();
                                              searchsaloncontroller.text =
                                                  user.salonName!;
                                              searchsalonlist.clear();
                                              print("salonid = ${salonid}");
                                            });
                                            postReviewPref.setString(
                                              'salonname',
                                              user.salonName!,
                                            );
                                            postReviewPref.setInt(
                                              'idss',
                                              user.id!,
                                            );

                                            FocusScopeNode currentFocus =
                                                FocusScope.of(context);
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
                            child: Image.asset(
                              "lib/assets/images/qrcodeimage.png",
                            ),
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();
                                int stepcount = 0;
                                if (searchsaloncontroller.text.isNotEmpty) {
                                  String? salonNAME = postReviewPref.getString(
                                    'salonname',
                                  );
                                  print("salonNAME == ${salonNAME}");
                                  if (salonNAME!.isNotEmpty) {
                                    _selecttype1Image();
                                    setState(() {
                                      selectindex = selectindex + 1;
                                      step1 = false;
                                      step2 = true;
                                    });

                                    postReviewPref.setInt(
                                      'steptype1',
                                      selectindex,
                                    );

                                    stepcount =
                                        postReviewPref.getInt('steptype1')!;

                                    print("salonid == ${salonid}");
                                  } else {
                                    if (selectedUser!.salonName ==
                                        searchsaloncontroller.text) {
                                      setState(() {
                                        selectindex = selectindex + 1;
                                        step1 = false;
                                        step2 = true;
                                      });

                                      postReviewPref.setInt(
                                        'steptype1',
                                        selectindex,
                                      );

                                      stepcount =
                                          postReviewPref.getInt('steptype1')!;

                                      print("salonid == ${salonid}");
                                    } else {
                                      kToast(
                                        Languages.of(
                                          context,
                                        )!.pleaseselectvalidsalonText,
                                      );
                                    }
                                  }
                                } else {
                                  kToast(
                                    Languages.of(context)!.pleaseentersalonText,
                                  );
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
                    ),
                    Visibility(
                      visible: step2,
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
                                child: Image.asset(
                                  ImageUtils.uploadimage,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                ),
                                width: kSize.width / 1.8,
                                height: kSize.height / 3.2,
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Image.file(
                                    beforeImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 15),
                          Text(
                            textAlign: TextAlign.center,
                            Languages.of(
                              context,
                            )!.ClicktotakeorselectyourbeforeimageText,
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
                                beforePicPressed(context);
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();
                                int stepcount = 0;

                                if (beforeImage.path == "") {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseaddbeforeimageText,
                                  );
                                } else {
                                  setState(() {
                                    selectindex = selectindex + 1;
                                    step2 = false;
                                    step3 = true;
                                  });
                                  postReviewPref.setInt(
                                    'steptype1',
                                    selectindex,
                                  );

                                  stepcount =
                                      postReviewPref.getInt('steptype1')!;
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();
                                _unselecttype1selectImage();
                                int stepcount = 0;
                                setState(() {
                                  selectindex = selectindex - 1;
                                  step1 = true;
                                  step2 = false;

                                  postReviewPref.setInt(
                                    'steptype1',
                                    selectindex,
                                  );

                                  stepcount =
                                      postReviewPref.getInt('steptype1')!;
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
                    ),
                    Visibility(
                      visible: step3,
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
                                child: Image.asset(
                                  ImageUtils.uploadimage,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                ),
                                width: kSize.width / 1.8,
                                height: kSize.height / 3.2,
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Image.file(
                                    afterImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 15),
                          Text(
                            textAlign: TextAlign.center,
                            Languages.of(
                              context,
                            )!.ClicktotakeorselectyourbeforeimageText,
                            style: Pallete.Quicksand15blackwe300,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 30,
                            width: 150,
                            decoration: Pallete.getButtonDecoration(),
                            child: InkWell(
                              onTap: () {
                                afterPicPressed(context);
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();

                                int stepcount = 0;
                                if (afterImage.path == "") {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseaddafterimageText,
                                  );
                                } else {
                                  setState(() {
                                    selectindex = selectindex + 1;
                                    step3 = false;
                                    step4 = true;
                                  });
                                  postReviewPref.setInt(
                                    'steptype1',
                                    selectindex,
                                  );

                                  stepcount =
                                      postReviewPref.getInt('steptype1')!;
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();

                                int stepcount = 0;
                                setState(() {
                                  selectindex = selectindex - 1;
                                  step3 = false;
                                  step2 = true;
                                });
                                postReviewPref.setInt('steptype1', selectindex);

                                stepcount = postReviewPref.getInt('steptype1')!;
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
                    ),
                    Visibility(
                      visible: step4,
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          allOtherdatatype1.isNotEmpty
                              ? SizedBox(
                                width: kSize.width / 1.8,
                                height: kSize.height / 3.2,
                                child: PageView.builder(
                                  itemCount: allOtherdatatype1.length,
                                  itemBuilder: (context, index) {
                                    if (allOtherdatatype1[index].path.endsWith(
                                          '.mp4',
                                        ) ||
                                        allOtherdatatype1[index].path.endsWith(
                                          '.mov',
                                        )) {}
                                    return Stack(
                                      children: [
                                        Container(
                                          child:
                                              allOtherdatatype1[index].path
                                                          .endsWith('.mp4') ||
                                                      allOtherdatatype1[index]
                                                          .path
                                                          .endsWith('.mov')
                                                  ? SizedBox(
                                                    width: kSize.width / 1.8,
                                                    height: kSize.height / 3.2,
                                                    child: MyVideoPlayer(
                                                      videoUrl:
                                                          allOtherdatatype1[index]
                                                              .path,
                                                    ),
                                                    //     FlickVideoPlayer(
                                                    //   flickManager:
                                                    //       flickManager,
                                                    //   preferredDeviceOrientation: const [
                                                    //     DeviceOrientation
                                                    //         .portraitUp
                                                    //   ],
                                                    // ),
                                                  )
                                                  : Container(
                                                    width: kSize.width / 1.8,
                                                    height: kSize.height / 3.2,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black12,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            1.0,
                                                          ),
                                                      child: Image.file(
                                                        File(
                                                          allOtherdatatype1[index]
                                                              .path,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 10,
                                          child: Container(
                                            height: 25,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: Colors.black45,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}/${allOtherdatatype1.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                ),
                                height: kSize.height / 3.2,
                                width: kSize.width / 1.8,
                                child: Image.asset(
                                  ImageUtils.uploadimage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          const SizedBox(height: 5),
                          Text(
                            Languages.of(
                              context,
                            )!.uploadotherpictureorvideoText,
                            style: Pallete.Quicksand16drktxtGreywe500,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 30,
                            width: 150,
                            decoration: Pallete.getButtonDecoration(),
                            child: InkWell(
                              onTap: () {
                                print("object");
                                pickAllOtherVideoORImageType1();
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();
                                int stepcount = 0;
                                print("otherImage ==== $otherImage");
                                setState(() {
                                  selectindex = selectindex + 1;
                                  step4 = false;
                                  step5 = true;
                                });
                                postReviewPref.setInt('steptype1', selectindex);

                                stepcount = postReviewPref.getInt('steptype1')!;
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
                                SharedPreferences postReviewPref =
                                    await SharedPreferences.getInstance();
                                int stepcount = 0;
                                setState(() {
                                  selectindex = selectindex - 1;
                                  step4 = false;
                                  step3 = true;
                                });
                                postReviewPref.setInt('steptype1', selectindex);

                                stepcount = postReviewPref.getInt('steptype1')!;
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
                    ),
                    Visibility(
                      visible: step5,
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
                                      postReviewPref.setInt(
                                        'cleanlinessCount',
                                        cleanlinesscount,
                                      );

                                      print("mycount = ${cleanlinesscount}");
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    setState(() {
                                      stafffriendinesscount = count;

                                      postReviewPref.setInt(
                                        'stafffriendlinessCount',
                                        stafffriendinesscount,
                                      );
                                      print(
                                        "mycount = ${stafffriendinesscount}",
                                      );
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    setState(() {
                                      organizationcount = count;

                                      postReviewPref.setInt(
                                        'organizationCount',
                                        organizationcount,
                                      );
                                      print("mycount = ${organizationcount}");
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      timemanagementcount = count;
                                      postReviewPref.setInt(
                                        'timemanagementCount',
                                        timemanagementcount,
                                      );
                                      print("mycount = ${timemanagementcount}");
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    setState(() {
                                      moderncount = count;

                                      postReviewPref.setInt(
                                        'modernCount',
                                        moderncount,
                                      );
                                      print("mycount = ${moderncount}");
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      bookingprocesscount = count;
                                      postReviewPref.setInt(
                                        'bookingprocessCount',
                                        bookingprocesscount,
                                      );
                                      print("mycount = ${bookingprocesscount}");
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
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      communicationcount = count;

                                      postReviewPref.setInt(
                                        'communicationCount',
                                        communicationcount,
                                      );
                                      print("mycount = ${communicationcount}");
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
                                border: Border.all(
                                  color: AppColors.kBorderColor,
                                  width: 2,
                                ),
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
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();

                                  reviewcontroller.addListener(() {
                                    print(
                                      "reviewcontroller = ${reviewcontroller.text}",
                                    );
                                    postReviewPref.setString(
                                      'writereviewsalonController',
                                      reviewcontroller.text,
                                    );
                                  });
                                },
                                onTaggedUserIdsChanged: (List<String> ids) {
                                  if (ids.isNotEmpty) {
                                    setState(() {
                                      taggedUserIds = ids;
                                    });
                                    print(
                                      "Currently Tagged User IDs: ${taggedUserIds.join(', ')}",
                                    );
                                  }
                                },
                              ),
                              // child: TextField(
                              //   onTap: () async {
                              //     SharedPreferences postReviewPref =
                              //         await SharedPreferences.getInstance();

                              //     reviewcontroller.addListener(() {
                              //       print(
                              //           "reviewcontroller = ${reviewcontroller.text}");
                              //       postReviewPref.setString(
                              //           'writereviewsalonController',
                              //           reviewcontroller.text);
                              //     });
                              //   },
                              //   maxLines: null,
                              //   controller: reviewcontroller,
                              //   decoration: InputDecoration(
                              //       border: InputBorder.none,
                              //       contentPadding: const EdgeInsets.only(
                              //           left: 15, right: 15),
                              //       hintText: Languages.of(context)!
                              //           .WritereviewaboutthesalonText,
                              //       hintStyle: Pallete
                              //           .Quicksand18drktxtGreyrwe500),
                              // ),
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

                                    print(
                                      "averageRatingString == ${averageRatingString}",
                                    );

                                    CreatePost(
                                      salonid,
                                      userid,
                                      beforeImage,
                                      afterImage,
                                      allOtherdatatype1,
                                      "mp4",
                                      averageRatingString,
                                      "",
                                      "",
                                      reviewcontroller.text,
                                      taggedUserIds,
                                      "SalonReview",
                                    );

                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    await postReviewPref.remove('salonname');
                                    await postReviewPref.remove('idss');
                                    await postReviewPref.remove('beforeimage');
                                    await postReviewPref.remove('afterimage');
                                    await postReviewPref.setInt('steptype1', 1);
                                    await postReviewPref.remove(
                                      'picandvideostype1',
                                    );
                                    await postReviewPref.remove(
                                      'cleanlinessCount',
                                    );
                                    await postReviewPref.remove(
                                      'stafffriendlinessCount',
                                    );
                                    await postReviewPref.remove(
                                      'writereviewsalonController',
                                    );
                                    await postReviewPref.remove(
                                      'organizationCount',
                                    );
                                    await postReviewPref.remove(
                                      'timemanagementCount',
                                    );
                                    await postReviewPref.remove('modernCount');
                                    await postReviewPref.remove(
                                      'bookingprocessCount',
                                    );
                                    await postReviewPref.remove(
                                      'communicationCount',
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
                            // Container(
                            //   height: 60,
                            //   width: kSize.width,
                            //   decoration:
                            //       Pallete.getBorderButtonDecoration(),
                            //   child: InkWell(
                            //     onTap: () {},
                            //     child: Center(
                            //       child: Text(
                            //         Languages.of(context)!.cancelText,
                            //         style: Pallete.Quicksand15blackwe600,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          isLoading
              ? Container(
                height: kSize.height,
                width: kSize.width,
                color: AppColors.kWhiteColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.kBlackColor,
                  ),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  Future beforePicPressed(BuildContext context) {
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
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.TakePhotoText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  await initializeCamera(selectedCameraIndex);

                  print("on call before camera");
                  Navigator.pop(context);
                  openBeforeCameraBottomSheet();
                  setState(() {});
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.PhotoLibraryText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  pickBeforeImage();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.CancelText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(Icons.cancel_outlined, color: Colors.black),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void openAfterCameraBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomsetState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,
                maxChildSize: 1.0,
                minChildSize: 1.0,
                builder: (context, scrollController) {
                  return Stack(
                    children: [
                      if (cameraController != null &&
                          cameraController!.value.isInitialized)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width *
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(child: CircularProgressIndicator()),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic top overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic bottom overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.kPinkColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: GestureDetector(
                          onTap: () async {
                            if (cameras == null || cameras!.length < 2) {
                              print("No multiple cameras available.");
                              return;
                            }

                            bottomsetState(() async {
                              selectedCameraIndex =
                                  (selectedCameraIndex == 0) ? 1 : 0;

                              try {
                                // Dispose the old controller
                                await cameraController?.dispose();
                                cameraController =
                                    null; // Avoid using an old reference

                                // Initialize new camera
                                cameraController = CameraController(
                                  cameras![selectedCameraIndex],
                                  ResolutionPreset.medium,
                                );

                                await cameraController!.initialize();
                                bottomsetState(() {}); // Refresh UI
                              } catch (e) {
                                print("Error switching camera: $e");
                              }
                            });
                          },
                          child: const Icon(
                            Icons.change_circle,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 25),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                print(
                                  "📸 Capture button tapped!",
                                ); // ✅ This should appear in the log

                                if (cameraController == null ||
                                    !cameraController!.value.isInitialized) {
                                  print("❌ Camera is not initialized.");
                                  return;
                                }

                                try {
                                  final XFile picture =
                                      await cameraController!.takePicture();
                                  print("✅ Image captured: ${picture.path}");

                                  double aspectRatio =
                                      cameraController!.value.aspectRatio;
                                  final imageBytes =
                                      await picture.readAsBytes();

                                  img.Image capturedImage =
                                      img.decodeImage(imageBytes)!;

                                  int previewWidth = capturedImage.width;
                                  int previewHeight = capturedImage.height;
                                  print("previewHeight ${previewHeight}");
                                  print("previewWidth ${previewWidth}");

                                  // Calculate the crop area: center 500x500
                                  int cropWidth = 500;
                                  int cropHeight = 500;
                                  int cropX = (previewWidth - cropWidth) ~/ 2;
                                  int cropY = (previewHeight - cropHeight) ~/ 2;

                                  if (previewWidth < cropWidth) {
                                    cropX = 0; // Center crop for width
                                    cropWidth = previewWidth;
                                  }
                                  if (previewHeight < cropHeight) {
                                    cropY = 0; // Center crop for height
                                    cropHeight = previewHeight;
                                  }

                                  img.Image croppedImage = img.copyCrop(
                                    capturedImage,
                                    x: cropX,
                                    y: cropY,
                                    width: cropWidth,
                                    height: cropHeight,
                                  );

                                  final croppedFile = File(picture.path)
                                    ..writeAsBytesSync(
                                      img.encodeJpg(croppedImage),
                                    );
                                  print(
                                    "✅ Cropped Image saved: ${croppedFile.path}",
                                  );

                                  if (selectedCameraIndex == 1) {
                                    img.Image flippedImage = img.flipHorizontal(
                                      croppedImage,
                                    );
                                    await croppedFile.writeAsBytes(
                                      img.encodeJpg(flippedImage),
                                    );
                                    print("🔄 Image mirrored successfully!");
                                  }

                                  bottomsetState(() {});
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();

                                  await postReviewPref.remove('afterimage');

                                  setState(() {
                                    file = File(croppedFile.path);
                                    print(croppedFile.path);
                                    this.afterImage = file!;
                                  });
                                  await postReviewPref.setString(
                                    'afterimage',
                                    croppedFile.path,
                                  );

                                  String? savedList = postReviewPref.getString(
                                    'afterimage',
                                  );
                                  print('Retrieved after saving: $savedList');
                                  setState(() {});
                                  bottomsetState(() {});
                                  _closeCamera();
                                  Navigator.pop(context);
                                } catch (e) {
                                  print("🚨 Error capturing image: $e");
                                }
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(37.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            _closeCamera();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void openBeforeCameraBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomsetState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,
                maxChildSize: 1.0,
                minChildSize: 1.0,
                builder: (context, scrollController) {
                  return Stack(
                    children: [
                      if (cameraController != null &&
                          cameraController!.value.isInitialized)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width *
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(child: CircularProgressIndicator()),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic top overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic bottom overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.kPinkColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: GestureDetector(
                          onTap: () async {
                            if (cameras == null || cameras!.length < 2) {
                              print("No multiple cameras available.");
                              return;
                            }

                            bottomsetState(() async {
                              selectedCameraIndex =
                                  (selectedCameraIndex == 0) ? 1 : 0;

                              try {
                                // Dispose the old controller
                                await cameraController?.dispose();
                                cameraController =
                                    null; // Avoid using an old reference

                                // Initialize new camera
                                cameraController = CameraController(
                                  cameras![selectedCameraIndex],
                                  ResolutionPreset.medium,
                                );

                                await cameraController!.initialize();
                                bottomsetState(() {}); // Refresh UI
                              } catch (e) {
                                print("Error switching camera: $e");
                              }
                            });
                          },
                          child: const Icon(
                            Icons.change_circle,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 25),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                print(
                                  "📸 Capture button tapped!",
                                ); // ✅ This should appear in the log

                                if (cameraController == null ||
                                    !cameraController!.value.isInitialized) {
                                  print("❌ Camera is not initialized.");
                                  return;
                                }

                                try {
                                  final XFile picture =
                                      await cameraController!.takePicture();
                                  print("✅ Image captured: ${picture.path}");

                                  double aspectRatio =
                                      cameraController!.value.aspectRatio;
                                  final imageBytes =
                                      await picture.readAsBytes();

                                  img.Image capturedImage =
                                      img.decodeImage(imageBytes)!;

                                  int previewWidth = capturedImage.width;
                                  int previewHeight = capturedImage.height;
                                  print("previewHeight ${previewHeight}");
                                  print("previewWidth ${previewWidth}");

                                  // Calculate the crop area: center 500x500
                                  int cropWidth = 500;
                                  int cropHeight = 500;
                                  int cropX = (previewWidth - cropWidth) ~/ 2;
                                  int cropY = (previewHeight - cropHeight) ~/ 2;

                                  if (previewWidth < cropWidth) {
                                    cropX = 0; // Center crop for width
                                    cropWidth = previewWidth;
                                  }
                                  if (previewHeight < cropHeight) {
                                    cropY = 0; // Center crop for height
                                    cropHeight = previewHeight;
                                  }

                                  img.Image croppedImage = img.copyCrop(
                                    capturedImage,
                                    x: cropX,
                                    y: cropY,
                                    width: cropWidth,
                                    height: cropHeight,
                                  );

                                  final croppedFile = File(picture.path)
                                    ..writeAsBytesSync(
                                      img.encodeJpg(croppedImage),
                                    );
                                  print(
                                    "✅ Cropped Image saved: ${croppedFile.path}",
                                  );

                                  if (selectedCameraIndex == 1) {
                                    img.Image flippedImage = img.flipHorizontal(
                                      croppedImage,
                                    );
                                    await croppedFile.writeAsBytes(
                                      img.encodeJpg(flippedImage),
                                    );
                                    print("🔄 Image mirrored successfully!");
                                  }

                                  bottomsetState(() {});
                                  SharedPreferences postReviewPref =
                                      await SharedPreferences.getInstance();
                                  await postReviewPref.remove('beforeimage');
                                  setState(() {
                                    file = File(croppedFile.path);
                                    print(croppedFile.path);
                                    this.beforeImage = file!;
                                  });
                                  await postReviewPref.setString(
                                    'beforeimage',
                                    croppedFile.path,
                                  );

                                  String? savedList = postReviewPref.getString(
                                    'beforeimage',
                                  );
                                  print(
                                    'Retrieved after saving beforeimage : $savedList',
                                  );
                                  setState(() {});
                                  bottomsetState(() {});
                                  _closeCamera();
                                  Navigator.pop(context);
                                } catch (e) {
                                  print("🚨 Error capturing image: $e");
                                }
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(37.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            _closeCamera();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future open_bottomsheet_noramPost(BuildContext context) {
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
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.TakePhotoText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  await initializeCamera(selectedCameraIndex);

                  debugPrint("Share Post on call videosphotos");

                  Navigator.pop(context);
                  openCameraBottomSheet();
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.PhotoLibraryText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  print("on click photo 322");
                  pickAllOtherVideoORImage();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.CancelText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(Icons.cancel_outlined, color: Colors.black),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void openCameraBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomsetState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,
                maxChildSize: 1.0,
                minChildSize: 1.0,
                builder: (context, scrollController) {
                  return Stack(
                    children: [
                      if (cameraController != null &&
                          cameraController!.value.isInitialized)
                        // Center(
                        //   child: CameraPreview(cameraController!),
                        // )
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width *
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(child: CircularProgressIndicator()),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic top overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height:
                            (MediaQuery.of(context).size.height - 500) /
                            2, // Dynamic bottom overlay
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.kPinkColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: GestureDetector(
                          onTap: () async {
                            if (cameras == null || cameras!.length < 2) {
                              print("No multiple cameras available.");
                              return;
                            }

                            bottomsetState(() async {
                              selectedCameraIndex =
                                  (selectedCameraIndex == 0) ? 1 : 0;

                              try {
                                // Dispose the old controller
                                await cameraController?.dispose();
                                cameraController =
                                    null; // Avoid using an old reference

                                // Initialize new camera
                                cameraController = CameraController(
                                  cameras![selectedCameraIndex],
                                  ResolutionPreset.medium,
                                );

                                await cameraController!.initialize();
                                bottomsetState(() {}); // Refresh UI
                              } catch (e) {
                                print("Error switching camera: $e");
                              }
                            });
                          },
                          child: const Icon(
                            Icons.change_circle,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 25),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                print("📸 Capture button tapped!");

                                if (cameraController == null ||
                                    !cameraController!.value.isInitialized) {
                                  print("❌ Camera is not initialized.");
                                  return;
                                }

                                try {
                                  final XFile picture =
                                      await cameraController!.takePicture();
                                  print("✅ Image captured: ${picture.path}");

                                  final imageBytes =
                                      await picture.readAsBytes();
                                  img.Image capturedImage =
                                      img.decodeImage(imageBytes)!;

                                  int previewWidth = capturedImage.width;
                                  int previewHeight = capturedImage.height;

                                  // Crop center 500x500
                                  int cropWidth = 500;
                                  int cropHeight = 500;
                                  int cropX = (previewWidth - cropWidth) ~/ 2;
                                  int cropY = (previewHeight - cropHeight) ~/ 2;

                                  if (previewWidth < cropWidth) {
                                    cropX = 0;
                                    cropWidth = previewWidth;
                                  }
                                  if (previewHeight < cropHeight) {
                                    cropY = 0;
                                    cropHeight = previewHeight;
                                  }

                                  img.Image croppedImage = img.copyCrop(
                                    capturedImage,
                                    x: cropX,
                                    y: cropY,
                                    width: cropWidth,
                                    height: cropHeight,
                                  );

                                  // Flip for front camera
                                  if (selectedCameraIndex == 1) {
                                    croppedImage = img.flipHorizontal(
                                      croppedImage,
                                    );
                                    print("🔄 Image mirrored successfully!");
                                  }

                                  // Save cropped image
                                  final croppedFile = File(picture.path)
                                    ..writeAsBytesSync(
                                      img.encodeJpg(croppedImage),
                                    );
                                  print(
                                    "✅ Cropped Image saved: ${croppedFile.path}",
                                  );

                                  // ✅ Launch ProImageEditor
                                  File?
                                  editedFile = await Navigator.push<File?>(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProImageEditor.file(
                                            croppedFile,
                                            callbacks: ProImageEditorCallbacks(
                                              onImageEditingComplete: (
                                                Uint8List bytes,
                                              ) async {
                                                final tempDir =
                                                    await getTemporaryDirectory();
                                                final path =
                                                    '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                                final finalFile = File(path);
                                                await finalFile.writeAsBytes(
                                                  bytes,
                                                );
                                                Navigator.pop(
                                                  context,
                                                  finalFile,
                                                );
                                              },
                                            ),
                                          ),
                                    ),
                                  );

                                  if (editedFile != null) {
                                    List<String> picandvideostype2Pref = [];
                                    SharedPreferences postReviewPref =
                                        await SharedPreferences.getInstance();

                                    allOtherdata.clear();
                                    setState(() {
                                      file = editedFile;
                                      allOtherdata.add(file!);
                                      picandvideostype2Pref.add(file!.path);
                                    });

                                    await postReviewPref.setStringList(
                                      'picandvideostype2',
                                      picandvideostype2Pref,
                                    );

                                    List<String>? savedList = postReviewPref
                                        .getStringList('picandvideostype2');
                                    print(
                                      'Retrieved list after saving: $savedList',
                                    );

                                    _closeCamera();
                                    Navigator.pop(context);
                                  } else {
                                    print("❌ Editing was cancelled or failed");
                                  }

                                  bottomsetState(() {});
                                } catch (e) {
                                  print("🚨 Error capturing image: $e");
                                }
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(37.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            _closeCamera();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future afterPicPressed(BuildContext context) {
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
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.TakePhotoText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  // bool isFrontCamera =
                  //     true; // Change to false if you want default to rear
                  // open_after_camera(isFrontCamera);
                  await initializeCamera(selectedCameraIndex);

                  Navigator.pop(context);

                  openAfterCameraBottomSheet();
                  setState(() {});
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.PhotoLibraryText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  pickAfterImage();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context)!.cancelText,
                        style: Pallete.Quicksand15blackwe300,
                      ),
                      const Icon(Icons.cancel_outlined, color: Colors.black),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  ///////// Post Review ADD BFORE CAMERA
  ////
  final ImagePicker _picker = ImagePicker();
  File? file;

  // void open_before_camera(bool isFrontCamera) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFrontCamera', isFrontCamera);

  //   var image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     preferredCameraDevice:
  //         isFrontCamera ? CameraDevice.front : CameraDevice.rear,
  //   );

  //   if (image != null) {
  //     File imageTemp = File(image.path);

  //     // Check if the image was taken with the front camera
  //     bool wasFrontCamera = await _wasFrontCameraUsed();
  //     if (wasFrontCamera) {
  //       imageTemp = await _fixMirroredImage(imageTemp);
  //     }

  //     _cropImageopen_before_camera(imageTemp);
  //     setState(() {});
  //   }
  // }

  // Future<void> _cropImageopen_before_camera(File image) async {
  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: image.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: '',
  //         toolbarColor: Colors.green,
  //         toolbarWidgetColor: Colors.white,
  //         hideBottomControls: true,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: true,
  //         aspectRatioPresets: [
  //           CropAspectRatioPreset.square,
  //         ],
  //         cropFrameColor: Colors.white,
  //         cropGridColor: Colors.transparent,
  //         showCropGrid: true,
  //         // Set fixed crop window size
  //         cropFrameStrokeWidth: 1,
  //       ),
  //       IOSUiSettings(
  //         title: '',
  //         resetButtonHidden: true,
  //         rotateButtonsHidden: true,
  //         rotateClockwiseButtonHidden: true,
  //         aspectRatioPickerButtonHidden: true,
  //         rectWidth: 500,
  //         rectHeight: 500,
  //         minimumAspectRatio: 1,
  //         aspectRatioLockEnabled: true,
  //         aspectRatioPresets: [
  //           CropAspectRatioPreset.square,
  //         ],
  //       ),
  //     ],
  //   );
  //   File? selectfile;
  //   if (croppedFile != null) {
  //     setState(() {
  //       selectfile = File(croppedFile.path);
  //     });
  //   }
  //   SharedPreferences postReviewPref = await SharedPreferences.getInstance();
  //   await postReviewPref.remove('beforeimage');
  //   setState(() {
  //     file = File(selectfile!.path);
  //     print(selectfile!.path);
  //   });
  //   await postReviewPref.setString('beforeimage', selectfile!.path);

  //   String? savedList = postReviewPref.getString('beforeimage');
  //   print('Retrieved after saving: $savedList');
  //   setState(() {});
  // }

  /////////
  ////
  ///////// Post Review ADD AFTER CAMERA
  ////
  // void open_after_camera(bool isFrontCamera) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFrontCamera', isFrontCamera);

  //   var image = await _picker.pickImage(source: ImageSource.camera);
  //   // final imageTemp = File(image!.path);

  //   if (image != null) {
  //     File imageTemp = File(image.path);

  //     // Check if the image was taken with the front camera
  //     bool wasFrontCamera = await _wasFrontCameraUsed();
  //     if (wasFrontCamera) {
  //       imageTemp = await _fixMirroredImage(imageTemp);
  //     }

  //     _cropImageopen_after_camera(imageTemp);
  //     setState(() {});
  //   }
  //   // if (imageTemp != null) {
  //   //   _cropImageopen_after_camera(imageTemp);
  //   // }
  // }

  // Future<void> _cropImageopen_after_camera(File image) async {
  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: image.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: '',
  //         toolbarColor: Colors.green,
  //         toolbarWidgetColor: Colors.white,
  //         hideBottomControls: true,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: true,
  //         aspectRatioPresets: [
  //           CropAspectRatioPreset.square,
  //         ],
  //         cropFrameColor: Colors.white,
  //         cropGridColor: Colors.transparent,
  //         showCropGrid: true,
  //         // Set fixed crop window size
  //         cropFrameStrokeWidth: 1,
  //       ),
  //       IOSUiSettings(
  //         title: '',
  //         resetButtonHidden: true,
  //         rotateButtonsHidden: true,
  //         rotateClockwiseButtonHidden: true,
  //         aspectRatioPickerButtonHidden: true,
  //         rectWidth: 500,
  //         rectHeight: 500,
  //         minimumAspectRatio: 1,
  //         aspectRatioLockEnabled: true,
  //         aspectRatioPresets: [
  //           CropAspectRatioPreset.square,
  //         ],
  //       ),
  //     ],
  //   );
  //   File? selectfile;
  //   if (croppedFile != null) {
  //     setState(() {
  //       selectfile = File(croppedFile.path);
  //     });
  //   }
  //   SharedPreferences postReviewPref = await SharedPreferences.getInstance();

  //   await postReviewPref.remove('afterimage');

  //   setState(() {
  //     file = File(selectfile!.path);
  //     print(selectfile!.path);
  //     this.afterImage = selectfile!;
  //   });
  //   await postReviewPref.setString('afterimage', selectfile!.path);

  //   String? savedList = postReviewPref.getString('afterimage');
  //   print('Retrieved after saving: $savedList');
  //   setState(() {});
  // }
  ///////
  ///
  ///

  // Future<dynamic> ImgVideoAlert(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
  //             child: AlertDialog(
  //               backgroundColor: AppColors.kWhiteColor,
  //               contentPadding: const EdgeInsets.all(10),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               title: Text(
  //                 "Upload image & Video",
  //                 style: Pallete.Quicksand15blackwe600,
  //               ),
  //               actions: <Widget>[
  //                 Column(
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                             flex: 1,
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.black),
  //                                   borderRadius: BorderRadius.circular(15)),
  //                               height: 40,
  //                               child: InkWell(
  //                                 onTap: () {
  //                                   pickOtherImage();
  //                                   _videoPlayercontroller == null;
  //                                   Navigator.pop(context);
  //                                 },
  //                                 child: const Center(child: Text("Image")),
  //                               ),
  //                             )),
  //                         const SizedBox(width: 10),
  //                         Expanded(
  //                             flex: 1,
  //                             child: InkWell(
  //                               onTap: () {
  //                                 _pickVideo();
  //                                 Navigator.pop(context);
  //                               },
  //                               child: Container(
  //                                 height: 40,
  //                                 decoration: BoxDecoration(
  //                                     border: Border.all(color: Colors.black),
  //                                     borderRadius: BorderRadius.circular(15)),
  //                                 child: const Center(child: Text("Video")),
  //                               ),
  //                             ))
  //                       ],
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             ));
  //       });
  // }

  Future<dynamic> ClearPostDataAlert(BuildContext context, Size kSize) {
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
                            SharedPreferences postReviewPref =
                                await SharedPreferences.getInstance();
                            if (userTyppe == "2") {
                              await postReviewPref.remove('picandvideostype2');
                              await postReviewPref.setInt('steptype2', 1);
                              await postReviewPref.remove('addcommentype2');

                              if (widget.type == "Home") {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (BuildContext context) =>
                                            BottomNavBar(index: 2),
                                  ),
                                  ModalRoute.withName('/'),
                                );
                              }
                            } else {
                              await postReviewPref.remove('salonname');
                              await postReviewPref.remove('idss');
                              await postReviewPref.remove('beforeimage');
                              await postReviewPref.remove('afterimage');
                              await postReviewPref.setInt('steptype1', 1);
                              await postReviewPref.remove('picandvideostype1');
                              await postReviewPref.remove('cleanlinessCount');
                              await postReviewPref.remove(
                                'stafffriendlinessCount',
                              );
                              await postReviewPref.remove(
                                'writereviewsalonController',
                              );
                              await postReviewPref.remove('organizationCount');
                              await postReviewPref.remove(
                                'timemanagementCount',
                              );
                              await postReviewPref.remove('modernCount');
                              await postReviewPref.remove(
                                'bookingprocessCount',
                              );
                              await postReviewPref.remove('communicationCount');

                              if (widget.type == "Home") {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (BuildContext context) =>
                                            BottomNavBar(index: 2),
                                  ),
                                  ModalRoute.withName('/'),
                                );
                              }
                            }
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

  CreatePost(
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
      isLoading = true;
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
              isLoading = false;

              print("Success");
              CreatePostModel model =
                  Provider.of<CreatePostViewModel>(
                        context,
                        listen: false,
                      ).createpostresponse.response
                      as CreatePostModel;

              kToast(model.message!);

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
          isLoading = false;
        });
        kToast(Languages.of(context)!.noInternetText);
      }
    });
  }

  getUserList() async {
    print("get doPostLike function call");
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

              userlist = model.userList!;
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

  Future scanerBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[Expanded(flex: 3, child: _buildQrView(context))],
          ),
        );
      },
    ).then((value) {
      // print("result == ${result}");
      // if (result != null) {
      //   setState(() {
      //     selectindex = selectindex + 1;
      //     step1 = false;
      //     step2 = true;
      //   });
      // }
    });
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 150.0
            : 300.0;

    // SharedPreferences? postReviewPref;
    return QRView(
      key: qrKey,
      // onQRViewCreated: _onQRViewCreated,
      onQRViewCreated: (controller) {
        setState(() {
          this.controller = controller;
        });
        controller.scannedDataStream.listen((scanData) async {
          if (isScanning == true) return;

          setState(() {
            result = scanData;
          });

          if (result != null) {
            String dataString = result!.code!;
            print("dataString----->$dataString");
            List<String> parts = dataString.split('/');
            await getUserIdFromUserName(parts.last);
            setState(() {
              isScanning = true;
            });
            // List<String> parts = dataString.split(' ');
            // setState(() {
            //   isScanning = true;
            // });
            // if (parts.isNotEmpty && parts[0] == "pinkgossipQRCode=2") {
            //   Navigator.pop(context);
            //   setState(() {
            //     salonid = parts[1];
            //     selectindex = selectindex + 1;
            //     step1 = false;
            //     step2 = true;
            //   });
            //   postReviewPref!.setInt('idss', int.parse(salonid));

            //   controller.dispose();
            //   kToast(Languages.of(context)!.QRCodeScanSuccessfullyText);
            // } else {
            //   controller.dispose();
            //   Navigator.pop(context);
            //   kToast(Languages.of(context)!.QRCodenotrecognizedText);
            // }
          }
        });
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Languages.of(context)!.noPermissionText)),
      );
    }
  }

  getUserIdFromUserName(String userId) async {
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        var response = await APIService.getUserID_and_Type(userId);
        if (response is Success) {
          Success result = response;

          if (result.success == true) {
            Map responce = json.decode(result.response.toString());
            print("responce---------------$responce");
            String passedId = responce['user_profile']['id'].toString();
            String userType = responce['user_profile']['user_type'].toString();

            SharedPreferences? postReviewPref;
            postReviewPref = await SharedPreferences.getInstance();
            if (userType.isNotEmpty && userType == "2") {
              Navigator.pop(context);
              setState(() {
                salonid = passedId;
                selectindex = selectindex + 1;
                step1 = false;
                step2 = true;
              });
              postReviewPref.setInt('idss', int.parse(salonid));

              controller!.dispose();
              kToast(Languages.of(context)!.QRCodeScanSuccessfullyText);
            } else {
              controller!.dispose();
              Navigator.pop(context);
              kToast(Languages.of(context)!.QRCodenotrecognizedText);
            }
          }
        }
      }
    });
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
}
