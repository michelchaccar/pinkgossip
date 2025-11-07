import 'dart:async';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:pinkGossip/bottomnavi.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/models/addstorymodel.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:pinkGossip/viewModels/addstoryviewmodel.dart';
import 'package:camera/camera.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as pathData;

class AddStory extends StatefulWidget {
  final Function(bool)? onImageSelected;
  final Function(bool)? onImagetype1Selected;
  String? type;

  AddStory({
    super.key,
    this.onImageSelected,
    this.onImagetype1Selected,
    required this.type,
  });

  @override
  State<AddStory> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
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

  final List<Widget> _mediaList = [];
  final List<File> path = [];

  File? selectMedia;

  File? _file;
  int currentPage = 0;

  bool showGallery = false;
  bool isLoading = false;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool isRecording = false;
  double progress = 0.0;
  VideoPlayerController? controllerVideoDurationChk;
  Timer? _timer;
  final int videoMaxLength = 60;
  bool isVideoEnabled = false;
  bool isFilePassed = false;

  SharedPreferences? prefs;
  String userid = "";
  String profileimg = "";

  getuserid() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs!.getString('userid')!;
    profileimg = prefs!.getString('profileimg')!;

    print("userid   ${userid}");
  }

  @override
  // _fetchNewMedia() async {
  //   final PermissionState ps = await PhotoManager.requestPermissionExtend();
  //   if (ps.isAuth) {
  //     List<AssetPathEntity> album =
  //         await PhotoManager.getAssetPathList(type: RequestType.common);
  //     List<AssetEntity> media =
  //         await album[0].getAssetListPaged(page: currentPage, size: 60);
  //     for (var asset in media) {
  //       if (asset.type == AssetType.image || asset.type == AssetType.video) {
  //         final file = await asset.file;
  //         // if (file != null) {
  //         //   path.add(File(file.path));
  //         //   _file = path[0];
  //         // }
  //         if (file != null) {
  //           if (asset.type == AssetType.video) {
  //             final videoDuration = asset.videoDuration;
  //             print(
  //                 "Actual video duration in seconds: ${videoDuration.inSeconds}");
  //             if (videoDuration.inSeconds > 15) {
  //               print("objvideoDuration.inSeconds > 15");
  //               final trimmedFile = await _trimVideoTo15Seconds(file);
  //               if (trimmedFile != null) {
  //                 path.add(trimmedFile);
  //               }
  //             } else {
  //               path.add(File(file.path));
  //             }
  //           } else {
  //             path.add(File(file.path));
  //           }
  //           _file = path[0];
  //         }
  //       }
  //     }
  //     List<Widget> temp = [];
  //     for (var asset in media) {
  //       temp.add(
  //         FutureBuilder(
  //           future:
  //               asset.thumbnailDataWithSize(const ThumbnailSize(1024, 1024)),
  //           builder: (context, snapshot) {
  //             final videoDuration = asset.videoDuration;
  //             final durationString = _formatDuration(videoDuration);
  //             if (snapshot.connectionState == ConnectionState.done) {
  //               return Stack(
  //                 children: [
  //                   Positioned.fill(
  //                     bottom: 0,
  //                     left: 0,
  //                     right: 0,
  //                     top: 0,
  //                     child: Image.memory(
  //                       snapshot.data!,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                   if (asset.type == AssetType.video)
  //                     Positioned(
  //                       right: 8,
  //                       bottom: 8,
  //                       child: Text(
  //                         durationString,
  //                         style: Pallete.Quicksand16drkBlackbold.copyWith(
  //                             color: AppColors.kWhiteColor),
  //                       ),
  //                     ),
  //                 ],
  //               );
  //             }
  //             return Container();
  //           },
  //         ),
  //       );
  //     }
  //     setState(() {
  //       _mediaList.addAll(temp);
  //       currentPage++;
  //     });
  //   }
  // }
  Future<File?> _trimVideoTo15Seconds(File videoFile) async {
    final directory = await getTemporaryDirectory();
    final outputPath = '${directory.path}/trimmed_video.mp4';

    final command = '-i ${videoFile.path} -ss 0 -t 15 -c copy $outputPath';

    print("command == ${command}");
    // await FFmpegKit.execute(command);

    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      return outputFile;
    }
    return null;
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00'; // Handle null duration

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds' // Format as HH:MM:SS
        : '$minutes:$seconds'; // Format as MM:SS
  }

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    // _fetchNewMedia();
    _initializeCamera();
    getuserid();
  }

  Future<void> _initializeCamera([int cameraIndex = 0]) async {
    // Get the list of available cameras.
    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      print('No cameras found');
      return;
    }

    // Set the selected camera (front or rear based on index).
    _selectedCameraIndex = cameraIndex;
    final selectedCamera = _cameras[_selectedCameraIndex];

    isFrontCamera = selectedCamera.lensDirection == CameraLensDirection.front;

    // Initialize the controller with the selected camera.
    _cameraController = CameraController(selectedCamera, ResolutionPreset.high);
    await _cameraController!.initialize();

    setState(() {}); // Rebuild the widget after camera initialization.
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose(); // Dispose of the video controller
    _timer?.cancel();
    super.dispose();
  }

  // Method to toggle between front and rear cameras
  Future<void> _switchCamera() async {
    if (_cameras.length > 1) {
      // Switch between front and rear cameras
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      await _initializeCamera(_selectedCameraIndex);
    } else {
      print('Only one camera is available.');
    }
  }

  bool isFrontCamera = false;
  void _closeCamera() {
    // Dispose the camera controller to release resources
    _cameraController?.dispose();
    _cameraController = null; // Reset the controller
    print("Camera has been closed.");
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      selectMedia = null;
      final XFile picture = await _cameraController!.takePicture();
      print("isFrontCamera ${isFrontCamera}");
      if (isFrontCamera) {
        final bytes = await File(picture.path).readAsBytes();
        final image = img.decodeImage(bytes);
        final flippedImage = img.flipHorizontal(image!);
        final flippedImageBytes = img.encodeJpg(flippedImage);

        final flippedImageFile = File(picture.path)
          ..writeAsBytesSync(flippedImageBytes);

        setState(() {
          selectMedia = flippedImageFile;
        });
      } else {
        setState(() {
          selectMedia = File(picture.path);
        });
      }
      setState(() {
        selectMedia = File(picture.path);
      });
      _closeCamera();

      String pathExtension = pathData.extension(selectMedia!.path);
      print("pathExtension --------------------->$pathExtension");
      if (pathExtension == ".jpg") {
        await _cropImage(selectMedia!.path);
      }

      print('Picture saved to: ${picture.path}'); // Print the image path
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.startVideoRecording();
      print('Recording video started'); // Print message when recording starts

      setState(() {
        isRecording = true;
        progress = 0.0;
      });

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          progress += 1 / (videoMaxLength * 10);
          if (progress >= 1.0) {
            _stopVideoRecording();
          }
        });
      });
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo) {
      final XFile video = await _cameraController!.stopVideoRecording();
      print('Video recorded to: ${video.path}'); // Print the video path

      if (isFilePassed == false) {
        setState(() {
          isFilePassed = true;
        });
        selectMedia = File(video.path);
        await _playVideo(selectMedia!);
      }

      setState(() {
        isRecording = false;
        progress = 0.0; // Reset progress
        _timer?.cancel(); // Cancel the timer
      });
    }
  }

  int indexx = 0;

  Future<void> _playVideo(File videoFile) async {
    // Dispose previous controller if any
    _videoController?.dispose();

    // Initialize a new video player controller
    _videoController = VideoPlayerController.file(videoFile);
    await _videoController!.initialize();
    setState(() {});

    // Start playing the video
    _videoController!.play();
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.kBlackColor,
      appBar:
          selectMedia == null
              ? AppBar(
                backgroundColor: AppColors.kBlackColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          if (widget.type == "Home") {
                            _closeCamera();
                            Navigator.pop(context);
                          } else {
                            _closeCamera();
                            if (selectMedia == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BottomNavBar(index: 2),
                                ),
                              );
                            } else {
                              print("on calllll");
                              _closeCamera();
                              Navigator.pop(context);
                            }
                          }

                          // selectMedia = null;
                          // if (showGallery == false) {
                          //   Navigator.pop(context);
                          // } else {
                          //   print("else");

                          //   setState(() {
                          //     showGallery = false;

                          //     _unselectselectImage();
                          //     _unselecttype1selectImage();
                          //   });
                          // }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            "lib/assets/images/wrong.png",
                            width: 25,
                            color: AppColors.kWhiteColor,
                          ),
                        ),
                      ),
                      // : Container(),
                    ),
                    Text(
                      Languages.of(context)!.addtostoryText,
                      style: Pallete.Quicksand18Whiitewe600,
                    ),
                    Expanded(flex: 1, child: Container()),
                  ],
                ),
                centerTitle: false,
              )
              : AppBar(
                backgroundColor: AppColors.kBlackColor,
                toolbarHeight: 0,
              ),
      body: Stack(
        children: [
          SafeArea(
            child:
                selectMedia == null
                    ? Stack(
                      children: [
                        // showGallery
                        //     ? Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           const SizedBox(height: 20),
                        //           Padding(
                        //             padding:
                        //                 const EdgeInsets.only(left: 12, right: 12),
                        //             child: Text(
                        //               Languages.of(context)!.recentText,
                        //               style: Pallete.Quicksand18drkWhitebold,
                        //             ),
                        //           ),
                        //           const SizedBox(height: 20),
                        //           Expanded(
                        //             child: GridView.builder(
                        //               shrinkWrap: true,
                        //               itemCount: _mediaList.length,
                        //               gridDelegate:
                        //                   const SliverGridDelegateWithFixedCrossAxisCount(
                        //                       crossAxisCount: 3,
                        //                       mainAxisSpacing: 1,
                        //                       crossAxisSpacing: 2,
                        //                       childAspectRatio: 0.58),
                        //               itemBuilder: (context, index) {
                        //                 return GestureDetector(
                        //                   onTap: () async {
                        //                     setState(() {
                        //                       selectMedia = File("");
                        //                       indexx = index;
                        //                       _file = path[index];
                        //                       selectMedia = _file;
                        //                     });
                        //                     if (selectMedia != null &&
                        //                             selectMedia!.path
                        //                                 .endsWith('.mp4') ||
                        //                         selectMedia!.path
                        //                             .endsWith('.MP4') ||
                        //                         selectMedia!.path
                        //                             .endsWith('.mov')) {
                        //                       await _playVideo(selectMedia!);
                        //                     }
                        //                     print("_file = ${_file}");
                        //                   },
                        //                   child: Stack(
                        //                     alignment: Alignment.bottomRight,
                        //                     children: [
                        //                       _mediaList[index],
                        //                     ],
                        //                   ),
                        //                 );
                        //               },
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     :
                        _cameraController != null &&
                                _cameraController!.value.isInitialized
                            ? Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: CameraPreview(_cameraController!),
                                ),
                                Positioned(
                                  right: 15,
                                  bottom: 12,
                                  child: GestureDetector(
                                    onTap: _switchCamera,
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration:
                                                isVideoEnabled
                                                    ? BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColors
                                                                .kPinkColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    )
                                                    : Pallete.getButtonDecoration(),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isVideoEnabled = false;
                                                });
                                              },
                                              child: Center(
                                                child: Text(
                                                  "Image",
                                                  style: Pallete
                                                      .Quicksand12Greywe400.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration:
                                                isVideoEnabled
                                                    ? Pallete.getButtonDecoration()
                                                    : BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColors
                                                                .kPinkColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isVideoEnabled = true;
                                                });
                                              },
                                              child: Center(
                                                child: Text(
                                                  "Video",
                                                  style: Pallete
                                                      .Quicksand12Greywe400.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            // onTap: _takePicture,
                                            // onLongPressStart:
                                            //     (details) => _startVideoRecording(),
                                            // onLongPressEnd:
                                            //     (details) => _stopVideoRecording(),
                                            onTap: () {
                                              if (isVideoEnabled) {
                                                if (isRecording) {
                                                  _stopVideoRecording();
                                                } else {
                                                  kToast(
                                                    "Click again to stop recording!",
                                                  );
                                                  _startVideoRecording();
                                                }
                                              } else {
                                                _takePicture();
                                              }
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  height: 75,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          37.5,
                                                        ),
                                                    border:
                                                        isRecording
                                                            ? Border.all(
                                                              color: Colors.red,
                                                              width: 5.0,
                                                            )
                                                            : null, // Red border when recording
                                                  ),
                                                ),
                                                if (isRecording)
                                                  Positioned.fill(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: CircularProgressIndicator(
                                                        value: progress,
                                                        strokeWidth:
                                                            4.0, // Thickness of the progress line
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              Colors.red,
                                                            ), // Progress color
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: Text(
                                "",
                                style: Pallete.Quicksand14Whiitewe600,
                              ),
                            ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              bottom: 15,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _videoController = null;
                                print("select from gallery$pickStoryType1");
                                pickStoryType1();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.kWhiteColor,
                                    width: 2,
                                  ),
                                ),
                                height: 50,
                                width: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Center(
                                      child: Icon(
                                        Icons.photo,
                                        color: AppColors.kWhiteColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // if (!showGallery && _mediaList.isNotEmpty)
                        //   Align(
                        //     alignment: Alignment.bottomLeft,
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(left: 10, bottom: 15),
                        //       child: GestureDetector(
                        //         onTap: () {
                        //           setState(() {
                        //             _selectImage();
                        //             _selecttype1Image();
                        //             showGallery = true;
                        //           });
                        //         },
                        //         child: Container(
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(12),
                        //               border: Border.all(
                        //                   color: AppColors.kWhiteColor, width: 2),
                        //             ),
                        //             height: 50,
                        //             width: 50,
                        //             child: Padding(
                        //               padding: const EdgeInsets.all(2.0),
                        //               child: ClipRRect(
                        //                   borderRadius: BorderRadius.circular(12),
                        //                   child: Center(child: _mediaList[0])),
                        //             )),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    )
                    : Scaffold(
                      backgroundColor: AppColors.kBlackColor,
                      bottomNavigationBar: Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  widget.type == "Home"
                                      ? const EdgeInsets.all(0)
                                      : const EdgeInsets.only(bottom: 15),
                              child: Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                  color: AppColors.darkgreybgcolor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    doAddStory(selectMedia!);
                                    setState(() {});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          color: AppColors.kWhiteColor,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image:
                                                profileimg.isNotEmpty
                                                    ? NetworkImage(
                                                      "${API.baseUrl}/api/${profileimg}",
                                                    )
                                                    : const AssetImage(
                                                          "lib/assets/images/person.png",
                                                        )
                                                        as ImageProvider<
                                                          Object
                                                        >,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        Languages.of(context)!.yourstoryText,
                                        style: Pallete.Quicksand14Whiitewe600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_videoController != null) {
                                        setState(() {
                                          _videoController!.value.isPlaying
                                              ? _videoController!.pause()
                                              : _videoController!.play();
                                        });
                                      }
                                    },
                                    child:
                                        selectMedia!.path.endsWith('.mp4') ||
                                                selectMedia!.path.endsWith(
                                                  '.MP4',
                                                ) ||
                                                selectMedia!.path.endsWith(
                                                  '.mov',
                                                )
                                            ? Stack(
                                              children: [
                                                VideoPlayer(
                                                  _videoController ??=
                                                      VideoPlayerController.file(
                                                          selectMedia!,
                                                        )
                                                        ..initialize().then((
                                                          _,
                                                        ) {
                                                          setState(() {});
                                                          _videoController!
                                                              .play();
                                                        }),
                                                ),
                                                _videoController!
                                                        .value
                                                        .isPlaying
                                                    ? Center(
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              AppColors
                                                                  .kPinkColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.pause,
                                                            color:
                                                                AppColors
                                                                    .kWhiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : Center(
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              AppColors
                                                                  .kPinkColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.play_arrow,
                                                            color:
                                                                AppColors
                                                                    .kWhiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            )
                                            : SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                              child: Image.file(
                                                selectMedia!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectMedia = null;
                                      showGallery = true;
                                    });
                                    await _initializeCamera();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      top: 10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Image.asset(
                                        "lib/assets/images/wrong.png",
                                        width: 25,
                                        height: 25,
                                        color: AppColors.kWhiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isLoading
                              ? SizedBox(
                                height: kSize.height,
                                width: kSize.width,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.kPinkColor,
                                  ),
                                ),
                              )
                              : Container(),
                        ],
                      ),
                    ),
          ),
          isLoading
              ? Container(
                color: Colors.black.withOpacity(0.6),
                height: kSize.height,
                width: kSize.width,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.kPinkColor),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  Future pickStoryType1() async {
    try {
      print("old selectMedia = ${selectMedia}");
      // selectMedia = null;
      final image = await ImagePicker().pickMedia(
        imageQuality: 95,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (image == null) return;
      if (image.path.endsWith('.mp4') ||
          image.path.endsWith('.MP4') ||
          image.path.endsWith('.mov')) {
        controllerVideoDurationChk = VideoPlayerController.file(
          File(image.path!),
        );
        await controllerVideoDurationChk!.initialize();
        final Duration duration = controllerVideoDurationChk!.value.duration;
        print("duration is ==${duration.inSeconds}");
        if (duration.inSeconds > 60) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Languages.of(context)!.maximumuploadlimit60secondText,
              ),
            ),
          );
        } else {
          selectMedia = File(image.path);
          _videoController = VideoPlayerController.file(selectMedia!);
          await _videoController!.initialize();
        }

        await controllerVideoDurationChk!.dispose();
        setState(() {});
      } else {
        final imageTemp = File(image.path);

        // print("imageTemp == ${imageTemp}");

        setState(() {
          selectMedia = File(image.path);
        });
        String pathExtension = pathData.extension(selectMedia!.path);
        print("pathExtension --------------------->$pathExtension");
        if (pathExtension == ".jpg") {
          await _cropImage(selectMedia!.path);
        }

        print("selected selectMedia = ${selectMedia}");
      }

      // print("IMAGE PATH = ${image.path}");
    } on PlatformException catch (error) {
      print('Failed to pick image: $error');
    }
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
    if (croppedFile != null) {
      setState(() {
        selectMedia = File(croppedFile.path);
      });
    }
  }

  Route _createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => BottomNavBar(index: 0),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var opacityTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(opacityTween),
          child: child,
        );
      },
    );
  }

  doAddStory(File story_data) async {
    print("get doPostLike function call");
    setState(() {
      isLoading = true;
    });
    getuserid();
    isInternetAvailable().then((isConnected) async {
      if (isConnected) {
        await Provider.of<AddStoryViewModel>(
          context,
          listen: false,
        ).doAddStory(userid, story_data);
        if (Provider.of<AddStoryViewModel>(context, listen: false).isLoading ==
            false) {
          if (Provider.of<AddStoryViewModel>(
                context,
                listen: false,
              ).isSuccess ==
              true) {
            print("Success");
            AddStoryResponseModel model =
                Provider.of<AddStoryViewModel>(
                      context,
                      listen: false,
                    ).addstoryresponse.response
                    as AddStoryResponseModel;

            if (model.success == true) {
              kToast(model.message!);

              if (widget.type == "Home") {
                Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => BottomNavBar(
                //               index: 0,
                //             )),
                //     ModalRoute.withName('/'));
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => BottomNavBar(index: 2),
                  ),
                  ModalRoute.withName('/'),
                );
              }
              setState(() {
                isLoading = false;
              });
            }

            kToast(model.message!);
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
