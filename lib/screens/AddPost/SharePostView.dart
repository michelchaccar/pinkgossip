import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';

import 'package:pinkGossip/models/createpostmodel.dart';
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
  const SharepostviewPage({super.key});

  @override
  State<SharepostviewPage> createState() => _SharepostviewPageState();
}

class _SharepostviewPageState extends State<SharepostviewPage> {
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
  List<UserList> tagUserList = [];
  List<String> taggedUserIds = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefValues();
    camerainitialisation();
    getTagUserList("1");
  }

  getPrefValues() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
  }

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
              Languages.of(context)!.sharepostText,
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
                const SizedBox(height: 20),
                Visibility(
                  visible: currentStep == 1,
                  child: SizedBox(
                    child: Column(
                      children: [
                        Container(
                          height: kSize.height / 2,
                          width: kSize.width - 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          child:
                              postData != null
                                  ? Container(
                                    height: kSize.height / 2,
                                    width: kSize.width - 10,

                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child:
                                          postData!.path.endsWith('.mp4') ||
                                                  postData!.path.endsWith(
                                                    '.MP4',
                                                  ) ||
                                                  postData!.path.endsWith(
                                                    '.mov',
                                                  )
                                              ? showVideo(postData)
                                              : Image.file(
                                                File(postData!.path),
                                                fit: BoxFit.cover,
                                              ),
                                    ),
                                  )
                                  : Image.asset(
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
                              if (postData != null) {
                                currentStep++;
                                setState(() {});
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
                ),
                Visibility(
                  visible: currentStep == 2,
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
                            type: "PostReview",
                            storedata: addcommentcontroller.text,
                            onChanged: (txt) async {
                              print("txt = ${txt}");
                              setState(() {
                                addcommentcontroller.text = txt;
                              });
                            },
                            onTaggedUserIdsChanged: (List<String> ids) {
                              // if (ids.isNotEmpty) {
                              //   setState(() {
                              //     taggedUserIds = ids;
                              //   });
                              //   print(
                              //     "Currently Tagged User IDs: ${taggedUserIds.join(', ')}",
                              //   );
                              // }
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
                                List<File> postsFiles = [];
                                postsFiles.add(postData!);
                                createPost(
                                  userid,
                                  userid,
                                  File(""),
                                  File(""),
                                  postsFiles,
                                  "",
                                  0,
                                  addcommentcontroller.text,
                                  taggedUserIds,
                                  "NormalPost",
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
    String review,
    List<String> tag_users,
    String post_type,
  ) async {
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
          review,
          tag_users,
          post_type,
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
                      builder: (context) => CameraApp(cameras: _cameras),
                    ),
                  ).then((value) async {
                    print(value);

                    if (value != null) {
                      postData = value as File;
                    }
                    String pathExtension = path.extension(postData!.path);
                    print("pathExtension --------------------->$pathExtension");
                    if (pathExtension == ".jpg") {
                      await _cropImage(postData!.path);
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
      if (postData!.path.endsWith('.mp4') ||
          postData!.path.endsWith('.MP4') ||
          postData!.path.endsWith('.mov')) {
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
      final XFile? result = await ImagePicker().pickMedia(
        imageQuality: 95,
        maxHeight: 1080,
        maxWidth: 1080,
      );

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

          if (duration.inSeconds > 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video is longer than 15 seconds!')),
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
}
