import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CommonFunctions {
  getCamarapickedImage(
    CameraController? cameraController,
    int selectedCameraIndex,
  ) async {
    try {
      final XFile picture = await cameraController!.takePicture();
      print("✅ Image captured: ${picture.path}");

      double aspectRatio = cameraController!.value.aspectRatio;
      final imageBytes = await picture.readAsBytes();

      img.Image capturedImage = img.decodeImage(imageBytes)!;

      int previewWidth = capturedImage.width;
      int previewHeight = capturedImage.height;
      // print("previewHeight ${previewHeight}");
      // print("previewWidth ${previewWidth}");

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
      File clickedImage = File(croppedFile.path);
      return clickedImage;
    } catch (e) {
      print("🚨 Error capturing image: $e");
    }
  }

  saveSingleImage(String prefKey, String filePath) async {
    SharedPreferences appSharedPref = await SharedPreferences.getInstance();
    await appSharedPref.remove(prefKey);
    await appSharedPref.setString(prefKey, filePath);
    String? savedList = appSharedPref.getString(prefKey);
  }

  Future<File> convertUint8ListToFile(Uint8List data, String filename) async {
    final directory =
        await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(data);
    return file;
  }

  ////////////////////////////////////////////////////////////////////////

  void downloadPhoto(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    if (Platform.isAndroid) {
      bool storageGranted = await checkStoragePermission();

      if (storageGranted) {
        try {
          await downloadAndSaveFile(context, fileUrl, fileName);
          kToast("File Downloaded");
        } catch (e) {
          print('ERROR andoird downloadAndSaveFile : $e');
        }
      } else {
        kToast("Please grant permission to download.");
      }
    } else if (Platform.isIOS) {
      try {
        // await downloadFile(fileUrl, fileName, context);
        await downloadAndSaveFile(context, fileUrl, fileName);
      } catch (e) {
        print('Error downloadAndSaveFile ios file: $e');
      }
    }
  }

  Future<void> downloadAndSaveFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    int currentProgressStep = 0;
    StateSetter? setStateSS;
    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Store the dialog's context
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setStateSS = setState;
            return AlertDialog(
              backgroundColor: Colors.transparent,
              content: Center(
                child: SizedBox(
                  height: 55,
                  width: 55,
                  child: CircularStepProgressIndicator(
                    totalSteps: 100,
                    currentStep: currentProgressStep,
                    selectedColor: AppColors.kPinkColor,
                    unselectedColor: Colors.grey[200],
                    selectedStepSize: 5,
                    unselectedStepSize: 5,
                    width: 100,
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    try {
      var now = DateTime.now();
      if (Platform.isAndroid) {
        // final dir =
        //     Platform.isAndroid
        //         ? await getDownloadDirectory()
        //         : await getApplicationDocumentsDirectory();
        Directory? dir;
        if (Platform.isAndroid) {
          // ✅ Use app-specific external directory (works Android 5–14)
          dir = await getExternalStorageDirectory();
          dir ??= await getApplicationDocumentsDirectory();
        } else {
          dir = await getApplicationDocumentsDirectory();
        }

        if (!(await dir!.exists())) {
          await dir.create(recursive: true);
        }
        String extension = path.extension(fileUrl);
        String fileName =
            "PinkGossip-${now.year}${now.month}${now.day}${now.second}${now.millisecond}${now.microsecond}$extension";
        String fullPath = "${dir!.path}/${fileName}";
        print("File savePath: $fullPath");
        await Dio().download(
          fileUrl,
          fullPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              currentProgressStep = (received / total * 100).toInt();
              setStateSS?.call(() {
                currentProgressStep = (received / total * 100).toInt();
              });
            }
          },
        );
        final result = await ImageGallerySaverPlus.saveFile(fullPath);
        print("result ---------------> $result");
      } else if (Platform.isIOS) {
        final request = http.Request('GET', Uri.parse(fileUrl));
        final response = await request.send();

        if (response.statusCode == 200) {
          final contentLength = response.contentLength;
          final directory = await getApplicationDocumentsDirectory();

          String extension = path.extension(fileUrl);
          String fileName =
              "PinkGossip-${now.year}${now.month}${now.day}${now.second}${now.millisecond}${now.microsecond}$extension";
          String filePath = "${directory.path}/${fileName}";
          print("File savePath: $filePath");

          await Dio().download(
            fileUrl,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                currentProgressStep = (received / total * 100).toInt();
                setStateSS?.call(() {
                  currentProgressStep = (received / total * 100).toInt();
                });
              }
            },
          );
          final result = await ImageGallerySaverPlus.saveFile(filePath);
          print(result);
        } else {
          throw 'Failed to download file: ${response.statusCode}';
        }
      }
    } catch (e) {
      print('Error downloading file: $e');
      throw 'Failed to download file: $e';
    } finally {
      // Ensure dialog is closed

      if (dialogContext != null) Navigator.pop(dialogContext!);
    }
  }
}

checkStoragePermission() async {
  print("checkStoragePermission");

  bool storageGranted = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print("sdkInt = ${androidInfo.version.sdkInt}");

  if (androidInfo.version.sdkInt >= 33) {
    // storageGranted = await Permission.manageExternalStorage.isGranted;
    // if (!storageGranted) {
    //   PermissionStatus status =
    //       await Permission.manageExternalStorage.request();
    //   storageGranted = status.isGranted;
    //   print("Storage permission status after request: $storageGranted");
    // }
    storageGranted = true;
  } else {
    storageGranted = await Permission.storage.isGranted;
    if (!storageGranted) {
      PermissionStatus status = await Permission.storage.request();
      storageGranted = status.isGranted;
      print("Storage permission status after request: $storageGranted");
    }
  }
  print("storageGranted = ${storageGranted}");
  return storageGranted;
}

Future<int?> _getAndroidVersion() async {
  try {
    final info = await File('/system/build.prop').readAsString();
    final match = RegExp(r'ro.build.version.sdk=(\d+)').firstMatch(info);
    if (match != null) return int.tryParse(match.group(1)!);
  } catch (_) {}
  return null;
}

class CommonWidget {
  getSmallButton(String title, Function()? onButtonTap) {
    return Container(
      height: 30,
      width: 180,
      decoration: Pallete.getButtonDecoration(),
      child: InkWell(
        onTap: onButtonTap,
        child: Center(child: Text(title, style: Pallete.buttonTextStyle)),
      ),
    );
  }
}
