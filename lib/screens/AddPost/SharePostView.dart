import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';

import 'package:pinkGossip/models/createpostmodel.dart';
import 'package:pinkGossip/models/rewardtemplatemodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/screens/AddPost/mentionTextifield.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/customeCamara.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/createpostviewmodel.dart';
import 'package:pinkGossip/viewModels/searchuserlistviewmodel.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

class SharepostviewPage extends StatefulWidget {
  SharepostviewPage({super.key, required this.type});
  String? type;

  @override
  State<SharepostviewPage> createState() => _SharepostviewPageState();
}

class _SharepostviewPageState extends State<SharepostviewPage> {
  List<RewardTemplateModel> rewardTemplateList = [];
  RewardTemplateModel? selectedRewardTemplate;
  bool isRewardTemplateLoading = false;

  SharedPreferences? prefs;
  bool isLoading = false;
  String userid = "";
  int totalStep = 2;
  int currentStep = 1;
  late List<CameraDescription> _cameras;
  camerainitialisation() async {
    _cameras = await availableCameras();
  }

  VideoPlayerController? _videoController;
  VideoPlayerController? controllerVideoDurationChk;
  File? postData;
  TextEditingController addcommentcontroller = TextEditingController();
  TextEditingController pointValuecontroller = TextEditingController();

  List<UserList> tagUserList = [];
  List<String> taggedUserIds = [];

  Future<void> getRewardTemplateList() async {
    setState(() => isRewardTemplateLoading = true);

    try {
      final request = await HttpClient().getUrl(
        Uri.parse("https://pinkgossipapp.com/api/reward-template-list"),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      final decoded = jsonDecode(body);

      if (decoded['success'] == true) {
        rewardTemplateList =
            (decoded['reward_template_list'] as List)
                .map((e) => RewardTemplateModel.fromJson(e))
                .toList();
        print(decoded['reward_template_list'].length); // must be > 0
        print(rewardTemplateList.isNotEmpty);
      }
    } catch (e) {
      debugPrint("Reward Template API Error: $e");
    }

    setState(() => isRewardTemplateLoading = false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefValues();
    camerainitialisation();
    getTagUserList("1");
    if (widget.type == "RewardPost") {
      getRewardTemplateList();
    }
  }

  getPrefValues() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
  }

  Widget rewardTemplateDropdown(Size kSize) {
    if (isRewardTemplateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 50,
      width: kSize.width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kBorderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RewardTemplateModel>(
          hint: Text(
            "Select Reward Template (Optional)",
            style: Pallete.Quicksand15darkgreye500,
          ),
          value: selectedRewardTemplate,
          isExpanded: true,
          items:
              rewardTemplateList.map((template) {
                return DropdownMenuItem(
                  value: template,
                  child: Text(template.rewardType),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedRewardTemplate = value;

              // Autofill description
              addcommentcontroller.text = value!.rewardDesc;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
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
              Text(
                widget.type == "NormalPost"
                    ? Languages.of(context)!.sharepostText
                    : Languages.of(context)!.postARewardText,
                style: Pallete.Quicksand16drkBlackBold,
              ),
              InkWell(
                onTap: () async {
                  if (postData != null) {
                    clearPostDataAlert(context, kSize);
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (BuildContext context) => BottomNavBar(index: 2),
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
                  const SizedBox(height: 20),
                  Visibility(
                    visible: currentStep == 1,
                    child: SizedBox(
                      child: Column(
                        children: [
                          if (widget.type == "RewardPost") ...[
                            rewardTemplateDropdown(kSize),
                            const SizedBox(height: 15),
                          ],
                          Container(
                            height: kSize.height / 2,
                            width: kSize.width - 10,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Builder(
                              builder: (_) {
                                // 1️⃣ User selected image/video
                                if (postData != null) {
                                  return Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child:
                                        postData!.path.endsWith('.mp4') ||
                                                postData!.path.endsWith(
                                                  '.MP4',
                                                ) ||
                                                postData!.path.endsWith('.mov')
                                            ? showVideo(postData)
                                            : Image.file(
                                              File(postData!.path),
                                              fit: BoxFit.cover,
                                            ),
                                  );
                                }

                                // 2️⃣ Reward template image (ONLY for RewardPost)
                                if (selectedRewardTemplate != null) {
                                  return Image.network(
                                    "https://pinkgossipapp.com/api/${selectedRewardTemplate!.rewardImage}",
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Image.asset(
                                          ImageUtils.uploadimage,
                                          fit: BoxFit.cover,
                                        ),
                                  );
                                }

                                // 3️⃣ Default placeholder image
                                return Image.asset(
                                  ImageUtils.uploadimage,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 5),
                          Text(
                            widget.type == "NormalPost"
                                ? Languages.of(
                                  context,
                                )!.UploadpictureorvideoText
                                : Languages.of(context)!.uploadimageText,
                            style: Pallete.Quicksand16drktxtGreywe500,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 30,
                            width: 150,
                            decoration: Pallete.getButtonDecoration(),
                            child: InkWell(
                              onTap: () {
                                showPostOptionsBottomSheet(context);
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
                                // Image / video MUST for NormalPost & RewardPost
                                if (postData == null) {
                                  kToast(
                                    Languages.of(
                                      context,
                                    )!.pleaseselectatleastonepictureText,
                                  );
                                  return;
                                }

                                currentStep++;
                                setState(() {});
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
                  ),
                  Visibility(
                    visible: currentStep == 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.type == "NormalPost"
                              ? Container()
                              : getPointofRewardUiBox(kSize),
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
                            child:
                                widget.type == "NormalPost"
                                    ? MentionTextField(
                                      userList: tagUserList,
                                      type: "PostReview",
                                      storedata: addcommentcontroller.text,
                                      onChanged: (txt) async {
                                        print("txt = ${txt}");
                                        setState(() {
                                          addcommentcontroller.text = txt;
                                        });
                                      },
                                      onTaggedUserIdsChanged: (
                                        List<String> ids,
                                      ) {
                                        // if (ids.isNotEmpty) {
                                        //   setState(() {
                                        //     taggedUserIds = ids;
                                        //   });
                                        //   print(
                                        //     "Currently Tagged User IDs: ${taggedUserIds.join(', ')}",
                                        //   );
                                        // }
                                      },
                                    )
                                    : TextField(
                                      controller: addcommentcontroller,
                                      maxLines: null,
                                      style: Pallete
                                          .Quicksand15darkgreye500.copyWith(
                                        color: AppColors.kBlackColor,
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      decoration: InputDecoration(
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 15,
                                            ),
                                        hintText:
                                            Languages.of(
                                              context,
                                            )!.descOfRewardAndOfferText,
                                        hintStyle: Pallete
                                            .Quicksand15darkgreye500.copyWith(
                                          color: AppColors.kBlackColor,
                                        ),
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 22),
                          InkWell(
                            child: Container(
                              height: 55,
                              decoration: Pallete.getButtonDecoration(),
                              child: InkWell(
                                onTap: () async {
                                  if (widget.type == "NormalPost" &&
                                      postData == null) {
                                    kToast("Please select image or video");
                                    return;
                                  }

                                  if (widget.type == "RewardPost" &&
                                      selectedRewardTemplate == null) {
                                    kToast("Please select reward template");
                                    return;
                                  }

                                  print("Reward Post Submit Clicked");
                                  List<File> postsFiles = [];
                                  if (postData != null) {
                                    postsFiles.add(postData!);
                                  }

                                  if (widget.type == "RewardPost") {
                                    if (pointValuecontroller.text.isEmpty ||
                                        pointValuecontroller.text == "0") {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            Languages.of(
                                              context,
                                            )!.pleaseenterpointvalueText,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (addcommentcontroller.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            Languages.of(
                                              context,
                                            )!.pleaseenterdescriptionText,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    createPost(
                                      userid,
                                      userid,
                                      File(""),
                                      File(""),
                                      postsFiles,
                                      "",
                                      0,
                                      selectedRewardTemplate!.rewardType,
                                      selectedRewardTemplate!.rewardImage,
                                      addcommentcontroller.text,
                                      taggedUserIds,
                                      "RewardPost",
                                      rewardpoint: pointValuecontroller.text,
                                    );
                                  } else {
                                    createPost(
                                      userid,
                                      userid,
                                      File(""),
                                      File(""),
                                      postsFiles,
                                      "",
                                      0,
                                      "",
                                      "",
                                      addcommentcontroller.text,
                                      taggedUserIds,
                                      "NormalPost",
                                    );
                                  }
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
                                //
                                currentStep--;
                                setState(() {});
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
      ),
    );
  }

  getStepsHeaderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      // children: List.generate(totalStep, (index) {
      //   return getStepIndicator(currentStep, totalStep, index);
      // }),
      children: [
        getStepIndicator(
          currentStep,
          totalStep,
          1,
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
          2,
          Languages.of(context)!.submitpostText,
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
    print("Reward Post Submit Clicked 1");
    // print("get CreatePost function call === $other");
    await compress.VideoCompress.deleteAllCache();
    setState(() {
      isLoading = true;
    });
    // print("mainfunc == ${rating}");

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
          } else {
            setState(() {
              isLoading = false;
            });
            kToast("File Not uploaded!");
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

  showPostOptionsBottomSheet(BuildContext context) {
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
                            needVideo: widget.type == "NormalPost",
                          ),
                    ),
                  ).then((value) async {
                    print(value);

                    if (value != null) {
                      postData = value as File;

                      String pathExtension = path.extension(postData!.path);
                      if (pathExtension == ".jpg") {
                        await _cropImage(postData!.path);
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
                  pickImageORVideo();
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
      if (postData != null &&
          (postData!.path.endsWith('.mp4') ||
              postData!.path.endsWith('.MP4') ||
              postData!.path.endsWith('.mov'))) {
        _videoController = null;
      }
    });
  }

  _cropImage(String path) async {
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
        postData = selectfile;
      });
    }
  }

  pickImageORVideo() async {
    setState(() {
      postData = null;
    });
    try {
      final XFile? result;
      if (widget.type == "NormalPost") {
        result = await ImagePicker().pickMedia(
          imageQuality: 95,
          maxHeight: 1080,
          maxWidth: 1080,
        );
      } else {
        result = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 95,
          maxHeight: 1080,
          maxWidth: 1080,
        );
      }

      if (result != null) {
        print("result ${result.path}");

        // print("postData ${postData!.path}");
        if (result.path.endsWith('.mp4') ||
            result.path.endsWith('.MP4') ||
            result.path.endsWith('.mov')) {
          controllerVideoDurationChk = VideoPlayerController.file(
            File(result.path!),
          );
          await controllerVideoDurationChk!.initialize();
          final Duration duration = controllerVideoDurationChk!.value.duration;
          print("duration is == ${duration.inSeconds}");
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
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Video is within 15 seconds ✅')),
            // );
            postData = File(result.path);
            _videoController = VideoPlayerController.file(postData!);
            await _videoController!.initialize();
          }

          await controllerVideoDurationChk!.dispose();
          setState(() {});
        } else {
          postData = File(result.path);
          await _cropImage(postData!.path);
        }

        setState(() {});
      }
    } on PlatformException catch (error) {
      print('Failed to pick media: $error');
    }
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

  showVideo(File? postData) {
    if (postData == null) return Container();

    return Stack(
      children: [
        VideoPlayer(
          _videoController ??= VideoPlayerController.file(postData)
            ..initialize().then((_) {
              setState(() {});
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

  getTagUserList(String type) async {
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
                Languages.of(context)!.postSharecanceltitleText,
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

  getPointofRewardUiBox(Size kSize) {
    return Column(
      children: [
        // Text(
        //   Languages.of(context)!.pointValueforRewardText,
        //   style: Pallete.Quicksand16drkBlackBold,
        // ),
        // const SizedBox(height: 10),
        Container(
          height: 50,
          width: kSize.width,
          decoration: BoxDecoration(
            color: AppColors.kWhiteColor,
            border: Border.all(color: AppColors.kBorderColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: pointValuecontroller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // <-- integers only
              ],
              style: Pallete.Quicksand15darkgreye500.copyWith(
                color: AppColors.kBlackColor,
              ),
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: Languages.of(context)!.pointValueforRewardText,
                hintStyle: Pallete.Quicksand15darkgreye500.copyWith(
                  color: AppColors.kBlackColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
