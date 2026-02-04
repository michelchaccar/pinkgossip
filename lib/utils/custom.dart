// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/ProfileShareWidget.dart';
import 'package:pinkGossip/utils/common_functions.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

// Json body SignUp {first_name: pinkgossip, last_name: pinkgossip, email: pinkgossip@gmail.com, password: 123456}
//

class API {
  // static String baseUrl = "http://192.168.1.47:8000";
  // static String baseUrl = "http://192.168.1.34:8000";
  // static String baseUrl = "http://192.168.1.36:8000";
  // static String baseUrl = "http://192.168.1.63:8000";
  // static String baseUrl = "http://192.168.31.179:8000";
  // static String baseUrl = "http://192.168.1.40:8000";
  // static String baseUrl = "http://192.168.1.67:8000";
  // static String baseUrl = "http://192.168.1.44:8000";
  //
  //
  // Live URL
  // static String baseUrl = "http://52.201.213.202:8000";
  // new url
  // static String baseUrl = "http://34.229.177.199:8000";
  static String baseUrl = "https://pinkgossipapp.com";

  static String dosignup = "${baseUrl}/api/signup";
  static String dologin = "${baseUrl}/api/login";
  static String forgotpassword = "${baseUrl}/api/forgot-password";
  static String salonList = "${baseUrl}/api/salon-list";
  static String salonDetails = "${baseUrl}/api/salon-details";
  static String postCreate = "${baseUrl}/api/salon-review-store";
  static String homepagePost = "${baseUrl}/api/other-user-post";
  static String postLike = "${baseUrl}/api/post-like";
  static String commentPost = "${baseUrl}/api/post-comment";
  static String userFollowing = "${baseUrl}/api/user-following";
  static String userUnfollow = "${baseUrl}/api/user-unfollowing";
  static String userProfileUpdate = "${baseUrl}/api/update-profile";
  static String updateProfilePhoto = "${baseUrl}/api/update-profile-photo";
  static String searchUserList = "${baseUrl}/api/user-list";
  static String checkAccountExist = "${baseUrl}/api/social-account-exist";
  static String updateFirebasedata = "${baseUrl}/api/update-firebase-data";
  static String getFollowersorFollow = "${baseUrl}/api/user-follow-data";
  static String getQRCode = "${baseUrl}/api/qr-code-generate";
  static String postDelete = "${baseUrl}/api/post-delete";
  static String getNotification = "${baseUrl}/api/get-notification";
  static String addStory = "${baseUrl}/api/add-story";
  static String getStory = "${baseUrl}/api/get-following-user-story";
  static String removeStoryCron = "${baseUrl}/api/remove-story-cron";
  static String checkUsernameExist = "${baseUrl}/api/check-user-name-exist";
  static String reportPost = "${baseUrl}/api/report-post";
  static String userBlock = "${baseUrl}/api/user-block";
  static String userUnBlock = "${baseUrl}/api/user-unblock";
  static String deleteAccount = "${baseUrl}/api/delete-account";
  static String getblockData = "${baseUrl}/api/blockdata/";
  static String getUserId_Type = "${baseUrl}/api/salon-id/";

  // remove-story-cron

  // Referral
  static String referralCode = "${baseUrl}/api/referral-code";
  static String referralClaim = "${baseUrl}/api/referral-claim";
  static String referralStats = "${baseUrl}/api/referral-stats";
}

kToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}

// internet check validation :
Future<bool> isInternetAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    return true;
  }
}

Future showShareOptions(BuildContext context, String username, String userId) {
  //https://pinkmapdemo.com/profile/testuser
  final String profileUrl = 'https://pinkgossipapp.com/profile/$userId';
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext builder) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text('Show QR Code', style: Pallete.Quicksand15blackwe600),
              onTap: () {
                Navigator.pop(context);
                _showQrCode(context, userId, username);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                'Share Profile Link',
                style: Pallete.Quicksand15blackwe600,
              ),
              onTap: () {
                Share.share(
                  'Check out $username\'s profile on PinkGossip: $profileUrl',
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showQrCode(BuildContext context, String userId, String username) {
  final String profileUrl = '${API.baseUrl}/profile/${userId}';
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true, // allows full height if needed
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // height: (MediaQuery.of(context).size.height * 0.4),
              width: MediaQuery.of(context).size.width,
              child: ProfileShareWidget(qrCodeDataString: profileUrl),
            ),
            const SizedBox(height: 16),
            CommonWidget().getSmallButton(Languages.of(context)!.close, () {
              Navigator.pop(context);
            }),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

class ValidationChecks {
  static bool validateEmail(String value) {
    Pattern pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }
}
