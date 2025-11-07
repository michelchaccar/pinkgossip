import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  CameraApp({super.key, this.cameras, this.needVideo});
  List<CameraDescription>? cameras;
  bool? needVideo = true;
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController cameraController;
  int selectedCameraIndex = 0; // Track which camera is active
  bool isRecording = false;
  double progress = 0.0;
  Timer? _timer;
  final int videoMaxLength = 60;
  bool isVideoEnabled = false;
  bool isFilePassed = false;

  @override
  void initState() {
    super.initState();

    print("widget.needVideo --- ${widget.needVideo}");

    cameraController = CameraController(
      widget.cameras![0],
      ResolutionPreset.max,
    );
    cameraController
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    // return CameraPreviewBox(cameraController);
    return Stack(
      children: [
        if (cameraController != null && cameraController!.value.isInitialized)
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
              border: Border.all(color: AppColors.kPinkColor, width: 1),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        Positioned(
          right: 15,
          bottom: 15,
          child: GestureDetector(
            onTap: () async {
              if (widget.cameras == null || widget.cameras!.length < 2) {
                print("No multiple cameras available.");
                return;
              }

              setState(() async {
                selectedCameraIndex = (selectedCameraIndex == 0) ? 1 : 0;

                try {
                  // Dispose the old controller
                  // await cameraController?.dispose();
                  // cameraController = null; // Avoid using an old reference

                  // Initialize new camera
                  cameraController = CameraController(
                    widget.cameras![selectedCameraIndex],
                    ResolutionPreset.medium,
                  );

                  await cameraController!.initialize();
                  setState(() {}); // Refresh UI
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration:
                        isVideoEnabled
                            ? BoxDecoration(
                              border: Border.all(color: AppColors.kPinkColor),
                              borderRadius: BorderRadius.circular(10),
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
                          style: Pallete.Quicksand12Greywe400.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  widget.needVideo == false
                      ? Container()
                      : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration:
                            isVideoEnabled
                                ? Pallete.getButtonDecoration()
                                : BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.kPinkColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
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
                              style: Pallete.Quicksand12Greywe400.copyWith(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    // onTap: _takePicture,
                    onTap: () {
                      if (isVideoEnabled) {
                        if (isRecording) {
                          if (widget.needVideo == false) {
                            return;
                          }
                          _stopVideoRecording();
                        } else {
                          if (widget.needVideo == false) {
                            return;
                          }
                          kToast("Click again to stop recording!");
                          _startVideoRecording();
                        }
                      } else {
                        _takePicture();
                      }
                    },
                    // onLongPressStart: (details) {
                    //   if (widget.needVideo == false) {
                    //     return;
                    //   }
                    //   _startVideoRecording();
                    // },
                    // onLongPressEnd: (details) {
                    //   if (widget.needVideo == false) {
                    //     return;
                    //   }
                    //   print(" recorded  onLongPressEnd");
                    //   _stopVideoRecording();
                    // },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(37.5),
                            border:
                                isRecording
                                    ? Border.all(color: Colors.red, width: 5.0)
                                    : null, // Red border when recording
                          ),
                        ),
                        if (isRecording)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth:
                                    4.0, // Thickness of the progress line
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ), // Progress color
                              ),
                            ),
                          ),
                        // if (isRecording)
                        //   Positioned.fill(
                        //     child: Align(
                        //       alignment: Alignment.center,
                        //       child: Text(
                        //         "${progress.toStringAsFixed(1) * 10}",
                        //         // "${progress}",
                        //         style: Pallete.Quicksand12Greywe400.copyWith(
                        //           color: Colors.red,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _takePicture() async {
    print("📸 Capture button tapped!"); // ✅ This should appear in the log

    if (cameraController == null || !cameraController!.value.isInitialized) {
      print("❌ Camera is not initialized.");
      return;
    }

    try {
      final XFile picture = await cameraController!.takePicture();
      print("✅ Image captured: ${picture.path}");

      double aspectRatio = cameraController!.value.aspectRatio;
      final imageBytes = await picture.readAsBytes();

      img.Image capturedImage = img.decodeImage(imageBytes)!;

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
        ..writeAsBytesSync(img.encodeJpg(croppedImage));
      print("✅ Cropped Image saved: ${croppedFile.path}");

      if (selectedCameraIndex == 1) {
        img.Image flippedImage = img.flipHorizontal(croppedImage);
        await croppedFile.writeAsBytes(img.encodeJpg(flippedImage));
        print("🔄 Image mirrored successfully!");
      }

      setState(() {});
      print(" croppedFile value $croppedFile");
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, croppedFile);
      });
      //
    } catch (e) {
      print("🚨 Error capturing image: $e");
    }
  }

  Future<void> _startVideoRecording() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      await cameraController!.startVideoRecording();
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
    if (cameraController != null && cameraController!.value.isRecordingVideo) {
      final XFile video = await cameraController!.stopVideoRecording();
      print('Video recorded to: ${video.path}'); // Print the video path
      setState(() {
        isRecording = false;
        progress = 0.0; // Reset progress
        _timer?.cancel(); // Cancel the timer
      });
      if (isFilePassed == false) {
        setState(() {
          isFilePassed = true;
        });
        File videoFile = File("");
        if (videoFile.path.isEmpty) {
          videoFile = File(video.path);
          print(" Video recorded File $videoFile");
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context, videoFile);
          });
        }
      }
    }
  }
}
