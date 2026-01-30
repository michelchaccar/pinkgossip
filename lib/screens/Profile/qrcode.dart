// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:pinkGossip/localization/language/languages.dart';

import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

class QRCodeScreen extends StatefulWidget {
  String userid, usertype, userName;

  QRCodeScreen({
    super.key,
    required this.userid,
    required this.usertype,
    required this.userName,
  });

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool isLoading = false;
  String qrimage = "";
  String profileUrl = "";
  @override
  void initState() {
    super.initState();
    profileUrl = '${API.baseUrl}/profile/${widget.userid}';
  }

  GlobalKey globalKey = GlobalKey();

  Future<void> _downloadQRCode() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (status.isGranted) {
          Directory? downloadsDirectory = Directory(
            '/storage/emulated/0/Download',
          );
          if (!downloadsDirectory.existsSync()) {
            downloadsDirectory.createSync(recursive: true);
          }
          final imagePath = File('${downloadsDirectory.path}/qr_code.png');
          await imagePath.writeAsBytes(pngBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Languages.of(context)!.qrcodesavedatText)),
          );
        } else {
          _showSnackbar(Languages.of(context)!.permissiondeniedText);
        }
      } else if (Platform.isIOS) {
        final result = await PhotoManager.requestPermissionExtend();
        if (result.isAuth) {
          final asset = await PhotoManager.editor.saveImage(
            pngBytes,
            filename: 'qr_code.png',
          );
          if (asset != null) {
            _showSnackbar(Languages.of(context)!.qrcodesavedatText);
          } else {
            _showSnackbar(Languages.of(context)!.errortosavedqrText);
          }
        } else {
          _showSnackbar(Languages.of(context)!.permissiondeniedText);
        }
      }
    } catch (e) {
      print('${Languages.of(context)!.errortosavedqrText}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Languages.of(context)!.errortosavedqrText)),
      );
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Pallete.Quicksand18drkBlackbold.copyWith(
            color: AppColors.kWhiteColor,
          ),
        ),
        backgroundColor: AppColors.kPinkColor,
      ),
    );
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
                  Languages.of(context)!.QRCodeText,
                  style: Pallete.Quicksand16drkBlackBold,
                ),
              ],
            ),
            IconButton(
              onPressed: _downloadQRCode,
              icon: SizedBox(
                height: 30,
                child: Image.asset("lib/assets/images/downloadicon.png"),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              //https://pinkmapdemo.com/profile/testuser

              showShareOptions(context, widget.userName, widget.userid);
            },
            icon: const Icon(Icons.share_sharp, size: 25),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          RepaintBoundary(
            key: globalKey,
            child: Container(
              alignment: Alignment.topCenter,
              // height: kSize.height / 2,
              width: kSize.width,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 12.0),
                ],
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: QrImageView(
                      foregroundColor: AppColors.kPinkColor,
                      data: "${API.baseUrl}/profile/${widget.userid}",
                      // data:
                      //     "pinkgossipQRCode=${widget.usertype} ${widget.userid}",
                      version: QrVersions.auto,
                    ),
                  ),
                  Container(
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: Image.asset("lib/assets/images/logo@3x.png"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // getQRCode() async {
  //   print("getQRCode function call");
  //   setState(() {
  //     isLoading = true;
  //   });
  //   isInternetAvailable().then((isConnected) async {
  //     if (isConnected) {
  //       await Provider.of<GetQRCodeViewModel>(context, listen: false)
  //           .getQRCode(widget.userid);
  //       if (Provider.of<GetQRCodeViewModel>(context, listen: false).isLoading ==
  //           false) {
  //         if (Provider.of<GetQRCodeViewModel>(context, listen: false)
  //                 .isSuccess ==
  //             true) {
  //           setState(() {
  //             isLoading = false;
  //             print("Success");
  //             GetQrCodemodel model =
  //                 Provider.of<GetQRCodeViewModel>(context, listen: false)
  //                     .getqrcoderesponse
  //                     .response as GetQrCodemodel;

  //             qrimage = model.qrCode ?? "";
  //             // print("QRimg === ${qrimage}");
  //           });
  //         }
  //       }
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       kToast("No Internet connection");
  //     }
  //   });
  // }
}
