// ignore_for_file: non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:pinkGossip/models/addstorymodel.dart';
import 'package:pinkGossip/models/allfollowersorfollowingmodel.dart';
import 'package:pinkGossip/models/blockedusermodel.dart';
import 'package:pinkGossip/models/checkuserexistmodel.dart';
import 'package:pinkGossip/models/checkusernameexistmodel.dart';
import 'package:pinkGossip/models/commentpostmodel.dart';
import 'package:pinkGossip/models/createpostmodel.dart';
import 'package:pinkGossip/models/deletepostmodel.dart';
import 'package:pinkGossip/models/followingmodel.dart';
import 'package:pinkGossip/models/forgotpasswordmodel.dart';
import 'package:pinkGossip/models/getnotificationmodel.dart';
import 'package:pinkGossip/models/getqrcodemodel.dart';
import 'package:pinkGossip/models/getstorylistmodel.dart';
import 'package:pinkGossip/models/homepagepostmodel.dart';
import 'package:pinkGossip/models/loginmodel.dart';
import 'package:pinkGossip/models/postlike.dart';
import 'package:pinkGossip/models/removestorycronmodel.dart';
import 'package:pinkGossip/models/salondetailmodel.dart';
import 'package:pinkGossip/models/salonlistmodel.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';
import 'package:pinkGossip/models/signupmodel.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/models/unfollwmodel.dart';
import 'package:pinkGossip/models/updatefirebasemodel.dart';
import 'package:pinkGossip/models/updateprofilemodel.dart';
import 'package:pinkGossip/models/updateprofilephoto.dart';
import 'package:pinkGossip/models/referralmodel.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:video_compress/video_compress.dart';

class APIService {
  static Future<Object> doSignup(
    String first_name,
    String last_name,
    String email,
    String password,
    String user_type,
    String user_name,
    String category,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "first_name": first_name,
      "last_name": last_name,
      "email": email,
      "password": password,
      "user_type": user_type,
      "user_name": user_name,
      "category": category,
    };

    try {
      var url = Uri.parse(API.dosignup);

      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: signUpModelFromJson(response.body),
          msg: "Login Successfullly",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> doLogin(
    String social_type,
    String email,
    String password, {
    first_name,
    last_name,
    social_id,
    user_type,
  }) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "social_type": social_type,
      "email": email,
      "password": password,
      "first_name": first_name,
      "last_name": last_name,
      "social_id": social_id,
      "user_type": user_type,
    };

    try {
      var url = Uri.parse(API.dologin);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: loginModelFromJson(response.body),
          msg: "Login Successfullly",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> forgotPassword(String email) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {"email": email};

    try {
      var url = Uri.parse(API.forgotpassword);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: forgotpasswordmodelFromJson(response.body),
          msg: "Login Successfullly",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getSalonList(String user_id) async {
    print("getSalonList called in api service");

    // Map<String, String> Jsonbody = {
    //   "email": email,
    // };

    try {
      var url = Uri.parse("${API.salonList}?user_id=$user_id");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: getSalonListModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getSalonDetails(
    String id,
    String user_id,
    int offset,
    String user_type,
  ) async {
    print("do login called in api service");

    // Map<String, String> Jsonbody = {
    //   "email": email,
    // };

    try {
      var url = Uri.parse(
        "${API.salonDetails}/$id?user_id=$user_id&offset=$offset&user_type=$user_type",
      );
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: salonDetailModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> CreatePost(
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
    print("CreatePost called in api service");
    // print("rating == ${rating}");
    try {
      var url = Uri.parse(API.postCreate);
      // File beforecheckFile = File(before_image.path);
      // File aftercheckFile = File(after_image.path);

      // List<File> othercheckFileList = [];

      // other.forEach((element) {
      //   othercheckFileList.add(File(element.path));
      // });
      // var beforestream;
      // var afterstream;
      // var otherstream;

      // var beforelength;
      // var afterlength;
      // var otherlength;

      // List<dynamic> otherstreamlist = [];

      // if (beforecheckFile.path != "") {
      //   beforestream = http.ByteStream(beforecheckFile.openRead());

      //   beforestream.cast();
      //   beforelength = await beforecheckFile.length();
      // }
      // if (aftercheckFile.path != "") {
      //   afterstream = http.ByteStream(aftercheckFile.openRead());

      //   afterstream.cast();
      //   afterlength = await aftercheckFile.length();
      // }

      // var request = http.MultipartRequest("POST", url);
      // request.fields['salon_id'] = salon_id;
      // request.fields['user_id'] = user_id;
      // request.fields['rating'] = double.parse(rating.toString()).toString();
      // request.fields['review'] = review;
      // request.fields['tag_users'] = tag_users.toString();
      // request.fields['post_type'] = post_type.toString();

      // if (beforecheckFile.path != "") {
      //   var beforemultiport = http.MultipartFile(
      //     'before_image',
      //     beforestream,
      //     beforelength,
      //     filename: beforecheckFile.path,
      //   );
      //   request.files.add(beforemultiport);
      // }
      // if (aftercheckFile.path != "") {
      //   var aftermultiport = http.MultipartFile(
      //     'after_image',
      //     afterstream,
      //     afterlength,
      //     filename: aftercheckFile.path,
      //   );
      //   request.files.add(aftermultiport);
      // }

      // List<MultipartFile> uploadotherFiles = [];
      // for (int a = 0; a < other.length; a++) {
      //   // print("other[a].path = ${other[a].path}");
      //   String fileextension = other[a].path.split('.').last.toLowerCase();
      //   print("fileextension = ${fileextension}");

      //   if (fileextension == "mp4" || fileextension == "mov") {
      //     uploadotherFiles.add(
      //       await http.MultipartFile.fromPath(
      //         'other',
      //         other[a].path,
      //         contentType: MediaType('video', "mp4"),
      //       ),
      //     );
      //   } else {
      //     uploadotherFiles.add(
      //       await http.MultipartFile.fromPath('other', other[a].path),
      //     );
      //   }
      // }
      // request.files.addAll(uploadotherFiles);

      // print("request ==== ${request}");
      // print("request ==== ${request.fields}");
      // print("request ==== ${request.files}");

      // // print(
      // //     "request============= ${request.fields['user_id']} == ${request.files[0].filename}");

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields['salon_id'] = salon_id.toString();
      request.fields['user_id'] = user_id.toString();
      request.fields['rating'] = rating.toString();
      request.fields['review'] = review;
      request.fields['post_type'] = post_type;

      // Encode tag_users array as JSON
      request.fields['tag_users'] = jsonEncode(tag_users);

      // Add files
      // Conditionally add images if provided
      if (before_image != null && await before_image.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('before_image', before_image.path),
        );
      }

      if (after_image != null && await after_image.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('after_image', after_image.path),
        );
      }

      String fileextension = other[0].path.split('.').last.toLowerCase();
      print("fileextension = ${fileextension}");

      if (fileextension == "mp4" || fileextension == "mov") {
        final info = await VideoCompress.getMediaInfo(other[0].path);
        print("API CALLING::::::::::::::::${info}");
        print("API CALLING:::::::::::::::${info.filesize}");
        print("API CALLING::::::::::::::${info.toJson()}");
        request.files.add(
          await http.MultipartFile.fromPath(
            'other',
            other[0].path,
            contentType: MediaType('video', "mp4"),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('other', other[0].path),
        );
      }

      var response = await request.send();
      print("url $url");
      print("response ${response}");
      print("response ${response.statusCode}");
      String resjsonData = await response.stream.transform(utf8.decoder).join();
      print("resjsonData ${resjsonData}");
      if (response.statusCode == 200) {
        Map<String, dynamic> valueMap = json.decode(resjsonData);
        print("resjsonData ${resjsonData}");
        var message = valueMap['message'];
        return Success(
          code: 200,
          response: createPostModelFromJson(resjsonData),
          msg: message,
          success: true,
        );
      }

      if (response.statusCode == 400) {
        String resjsonData =
            await response.stream.transform(utf8.decoder).join();
        print("resjsonData ${resjsonData}");
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        print("resjsonData ${resjsonData}");
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 413) {
        return Success(
          code: 413,
          response: false,
          msg: "Your provided attachment is too big...",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        print("resjsonData ${resjsonData}");
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> HomePagePost(String id, int offset) async {
    print("do login called in api service");

    try {
      var url = Uri.parse("${API.homepagePost}/$id?offset=$offset");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: homePostRsponseModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> updateFirebaseId(
    String u_id,
    String firebase_id,
    String fcm_token,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "u_id": u_id,
      "firebase_id": firebase_id,
      "fcm_token": fcm_token,
    };

    try {
      var url = Uri.parse("${API.updateFirebasedata}/$u_id");

      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: deviceTokenUpdateModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> doPostLike(
    String user_id,
    String post_id,
    String like,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "user_id": user_id,
      "post_id": post_id,
      "like": like,
    };
    try {
      var url = Uri.parse(API.postLike);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("url $url");
      print("Jsonbody $Jsonbody");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postLikeModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> doCommentPost(
    String app_user_id,
    String salon_post_id,
    String comment,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "app_user_id": app_user_id,
      "salon_post_id": salon_post_id,
      "comment": comment,
    };
    try {
      var url = Uri.parse(API.commentPost);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: commentPostModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> userFollowing(
    String following_id,
    String follower_id,
    String status,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "following_id": following_id,
      "follower_id": follower_id,
      "status": status,
    };
    try {
      var url = Uri.parse(API.userFollowing);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: followingModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getCheckAccountExist(String social_id) async {
    print("do login called in api service");

    try {
      var url = Uri.parse("${API.checkAccountExist}/${social_id}");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: checkUserExistModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> userUnfollow(
    String following_id,
    String follower_id,
  ) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {
      "following_id": following_id,
      "follower_id": follower_id,
    };
    try {
      var url = Uri.parse(API.userUnfollow);
      var response = await http.post(
        url,
        body: Jsonbody,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: unfollowiModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getsearchUserList(String type, String u_id) async {
    print("do login called in api service");

    try {
      var url = Uri.parse("${API.searchUserList}/$type/$u_id");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: salonSearchListModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getQRCode(String u_id) async {
    print("getQRCode called in api service");

    try {
      var url = Uri.parse("${API.getQRCode}/$u_id");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: getQrCodemodelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> userProfileUpdate(
    String id,
    String first_name,
    String last_name,
    String email,
    String salon_name,
    String contact_no,
    String address,
    String user_name,
    // String open_days,
    // String open_time,
    int type,
    String bio,
    String websitecontroller,
    String latitude,
    String longitude,
    List<Map<String, dynamic>> open_weekdays,
  ) async {
    print("do userProfileUpdate called in api service");
    Map<String, dynamic> jsonBody = {};
    if (type == 1) {
      // For user type 1
      jsonBody = {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "bio": bio,
        "user_name": user_name,
      };
    } else {
      // For user type 2 (Salon)
      jsonBody = {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "salon_name": salon_name,
        "bio": bio,
        "site_name": websitecontroller,
        "contact_no": contact_no,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "open_weekdays": open_weekdays,
        "user_name": user_name,
      };
    }

    try {
      var url = Uri.parse("${API.userProfileUpdate}/$id");
      print("Json body: $jsonBody");
      print("URL: $url");

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );
      print("response.statusCode: ${response.statusCode}");
      print("response.body: ${response.body}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: profileUpdateModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getFollowersorFollow(
    String id,
    String follow_type,
    String login_user_id,
  ) async {
    print("getFollowersorFollow called in api service");

    try {
      var url = Uri.parse(
        "${API.getFollowersorFollow}/$id?follow_type=$follow_type&login_user_id=$login_user_id",
      );
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: allfollowingorfollowersmodelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getPostDelete(String post_id) async {
    print("getPostDelete called in api service");

    try {
      var url = Uri.parse("${API.postDelete}/$post_id");
      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postDeleteModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> ProfilePhotoUpdate(
    String profile_image,
    String id,
  ) async {
    print("do login called in api service");

    try {
      var postUri = Uri.parse("${API.updateProfilePhoto}/$id");
      File profilecheckFile = File(profile_image);
      var stream;
      var length;
      if (profilecheckFile.path != "") {
        stream = http.ByteStream(profilecheckFile.openRead());

        stream.cast();
        length = await profilecheckFile.length();
      }

      var request = http.MultipartRequest("POST", postUri);
      request.fields['id'] = id;

      if (profilecheckFile.path != "") {
        var multiport = http.MultipartFile(
          'profile_image',
          stream,
          length,
          filename: profilecheckFile.path,
        );
        request.files.add(multiport);
      }
      print("request ==== ${request}");

      print(
        "request============= ${request.fields['u_id']} == ${request.files[0].filename}",
      );

      var response = await request.send();

      String resjsonData = await response.stream.transform(utf8.decoder).join();
      Map<String, dynamic> valueMap = json.decode(resjsonData);

      // AttachmentImageModel responsedata = AttachmentImageModel.fromJson(valueMap);

      // var response = await http.post(postUri, body: Jsonbody
      // headers: headers,
      // );
      // print("Json body  $Jsonbody");
      // print("url $url");
      print("response ${response.request}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(resjsonData);
        var message = valueMap['message'];
        return Success(
          code: 200,
          response: updateProfileModelFromJson(resjsonData),
          msg: message,
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(resjsonData);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getNotificationList(String id) async {
    print("do login called in api service");

    Map<String, String> Jsonbody = {"id": id};

    try {
      var url = Uri.parse("${API.getNotification}/$id");

      var response = await http.get(
        url,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: getNotificationModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getStory(String id) async {
    print("do getStory called in api service");

    Map<String, String> Jsonbody = {"id": id};

    try {
      var url = Uri.parse("${API.getStory}/$id");

      var response = await http.get(
        url,
        // headers: headers,
      );
      print("Json body  $Jsonbody");
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: getStoryResponseModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  // static Future<Object> doAddStory(String id, File story_data) async {
  //   print("do AddStory called in api service");

  //   try {
  //     var url = Uri.parse(
  //       "${API.addStory}/$id",
  //     );

  //     File storydataFile = File(story_data.path);

  //     var storydatastream;
  //     var storydatalength;

  //     if (storydataFile.path != "") {
  //       storydatastream = http.ByteStream(storydataFile.openRead());

  //       storydatastream.cast();
  //       storydatalength = await storydataFile.length();
  //     }

  //     var request = http.MultipartRequest("POST", url);

  //     if (storydataFile.path != "") {
  //       var beforemultiport = http.MultipartFile(
  //           'story_data', storydatastream, storydatalength,
  //           filename: storydataFile.path);
  //       request.files.add(beforemultiport);
  //     }
  //     // var response = await http.post(
  //     //   url, body: Jsonbody,
  //     //   // headers: headers,
  //     // );
  //     print("request ==== ${request}");
  //     print("request ==== ${request.fields}");
  //     var response = await request.send();

  //     String resjsonData = await response.stream.transform(utf8.decoder).join();
  //     Map<String, dynamic> valueMap = json.decode(resjsonData);

  //     // var response = await http.post(
  //     //   url,
  //     //   // headers: headers,
  //     // );
  //     // print("Json body  $Jsonbody");

  //     print("url $url");
  //     if (response.statusCode == 200) {
  //       return Success(
  //         code: 200,
  //         response: addStoryResponseModelFromJson(resjsonData),
  //         msg: "",
  //         success: true,
  //       );
  //     }

  //     if (response.statusCode == 400) {
  //       var jsonData = jsonDecode(resjsonData);
  //       var detail = jsonData['msg'];
  //       print("JSON DATA STRING +++ $detail");
  //       return Success(
  //         code: 400,
  //         response: false,
  //         msg: detail.toString(),
  //         success: false,
  //       );
  //     }
  //     if (response.statusCode == 422) {
  //       var jsonData = jsonDecode(resjsonData);
  //       var detail = jsonData['message'];
  //       print("JSON DATA STRING +++ $detail");
  //       return Success(
  //         code: 422,
  //         response: false,
  //         msg: detail.toString(),
  //         success: false,
  //       );
  //     }
  //     if (response.statusCode == 500) {
  //       return Success(
  //         code: 500,
  //         response: false,
  //         msg: "Somthing went wrong",
  //         success: false,
  //       );
  //     }
  //     if (response.statusCode == 401) {
  //       var jsonData = jsonDecode(resjsonData);
  //       var detail = jsonData['detail'];
  //       return Success(
  //         code: 100,
  //         response: false,
  //         msg: detail,
  //         success: false,
  //       );
  //     } else {
  //       return Success(
  //         code: 100,
  //         response: false,
  //         msg: "",
  //         success: false,
  //       );
  //     }
  //   } on HttpException {
  //     return Success(
  //       code: 101,
  //       response: false,
  //       msg: "",
  //       success: false,
  //     );
  //   }
  // }

  static Future<Object> doAddStory(String id, File story_data) async {
    print("do AddStory called in api service");

    try {
      var url = Uri.parse("${API.addStory}/$id");

      // Ensure the file exists and is not empty
      if (!await story_data.exists() || story_data.lengthSync() == 0) {
        return Success(
          code: 400,
          response: false,
          msg: "File does not exist or is empty.",
          success: false,
        );
      }

      // Create the ByteStream and determine file length
      var storydatastream = http.ByteStream(story_data.openRead());
      var storydatalength = await story_data.length();

      var request = http.MultipartRequest("POST", url);

      // Determine the file extension to set the correct content type
      String fileExtension = story_data.path.split('.').last.toLowerCase();
      MediaType mediaType;

      if (fileExtension == "mp4" || fileExtension == "mov") {
        mediaType = MediaType('video', fileExtension);
      } else if (fileExtension == "jpg" ||
          fileExtension == "jpeg" ||
          fileExtension == "png") {
        mediaType = MediaType('image', fileExtension);
      } else {
        return Success(
          code: 415,
          response: false,
          msg:
              "Unsupported file type. Only MP4, MOV, JPG, and PNG are allowed.",
          success: false,
        );
      }

      // Create the MultipartFile and add it to the request
      var storydataport = http.MultipartFile(
        'story_data',
        storydatastream,
        storydatalength,
        filename: story_data.path.split('/').last, // Just the file name
        contentType: mediaType,
      );

      request.files.add(storydataport);

      print("Request: ${request}");
      print("Request fields: ${request.fields}");

      // Send the request
      var response = await request.send();

      // Decode the response
      String resjsonData = await response.stream.transform(utf8.decoder).join();
      Map<String, dynamic> valueMap = json.decode(resjsonData);

      print("URL: $url");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: addStoryResponseModelFromJson(resjsonData),
          msg: "",
          success: true,
        );
      } else {
        var jsonData = jsonDecode(resjsonData);
        String detail =
            jsonData['msg'] ?? jsonData['message'] ?? "Unknown error occurred";
        return Success(
          code: response.statusCode,
          response: false,
          msg: detail,
          success: false,
        );
      }
    } on HttpException {
      return Success(
        code: 101,
        response: false,
        msg: "Network error occurred.",
        success: false,
      );
    } catch (e) {
      return Success(
        code: 500,
        response: false,
        msg: "An unexpected error occurred: $e",
        success: false,
      );
    }
  }

  static Future<Object> getRemoveStoryCron() async {
    print("do getStory called in api service");

    try {
      var url = Uri.parse(API.removeStoryCron);

      var response = await http.get(
        url,
        // headers: headers,
      );
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: removeStoryCronModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getcheckUsernameExist(String user_name) async {
    print("getcheckUsernameExist called in api service");

    Map<String, String> Jsonbody = {"user_name": user_name};
    try {
      var url = Uri.parse(API.checkUsernameExist);

      var response = await http.post(url, body: Jsonbody);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: checkUsernameExistModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> reportPost(String userId, String postId) async {
    print("reportPost called in api service");

    Map<String, String> Jsonbody = {"user_id": userId, "post_id": postId};
    try {
      var url = Uri.parse(API.reportPost);

      var response = await http.post(url, body: Jsonbody);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postDeleteModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> blockUser(String userId, String blockUserId) async {
    print("blockUser called in api service");

    Map<String, String> Jsonbody = {
      "user_id": userId,
      "block_user_id": blockUserId,
    };
    try {
      var url = Uri.parse(API.userBlock);

      var response = await http.post(url, body: Jsonbody);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postDeleteModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> unblockUser(String userId, String blockUserId) async {
    print("unblockUser called in api service");

    Map<String, String> Jsonbody = {
      "user_id": userId,
      "block_user_id": blockUserId,
    };
    try {
      var url = Uri.parse(API.userUnBlock);

      var response = await http.post(url, body: Jsonbody);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postDeleteModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> deleteAccount(String userId) async {
    print("deleteAccount called in api service");

    Map<String, String> Jsonbody = {"user_id": userId};
    try {
      var url = Uri.parse(API.deleteAccount);

      var response = await http.post(url, body: Jsonbody);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: postDeleteModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getBlockedUser(String userId) async {
    print("getBlockedUser called in api service");

    try {
      var url = Uri.parse("${API.getblockData}$userId");

      var response = await http.get(url);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: blockedUserResponseModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getUserID_and_Type(String userName) async {
    print("getBlockedUser called in api service");

    try {
      var url = Uri.parse("${API.getUserId_Type}$userName");

      var response = await http.get(url);
      print("url $url");
      print("response ${response.body}");
      print("response ${response.statusCode}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: response.body,
          msg: "",
          success: true,
        );
      }

      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 422) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['message'];
        print("JSON DATA STRING +++ $detail");
        return Success(
          code: 422,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Somthing went wrong",
          success: false,
        );
      }
      if (response.statusCode == 401) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['detail'];
        return Success(code: 100, response: false, msg: detail, success: false);
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  // Referral System

  static Future<Object> getReferralCode(String userId) async {
    try {
      var url = Uri.parse("${API.referralCode}/$userId");
      var response = await http.get(url);
      print("getReferralCode url $url");
      print("getReferralCode response ${response.body}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: referralCodeModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }
      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Something went wrong",
          success: false,
        );
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> claimReferral(
      String userId, String referralCode) async {
    try {
      var url = Uri.parse(API.referralClaim);
      var response = await http.post(
        url,
        body: {
          "user_id": userId,
          "referral_code": referralCode,
        },
      );
      print("claimReferral url $url");
      print("claimReferral response ${response.body}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: referralClaimModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }
      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Something went wrong",
          success: false,
        );
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }

  static Future<Object> getReferralStats(String userId) async {
    try {
      var url = Uri.parse("${API.referralStats}/$userId");
      var response = await http.get(url);
      print("getReferralStats url $url");
      print("getReferralStats response ${response.body}");
      if (response.statusCode == 200) {
        return Success(
          code: 200,
          response: referralStatsModelFromJson(response.body),
          msg: "",
          success: true,
        );
      }
      if (response.statusCode == 400) {
        var jsonData = jsonDecode(response.body);
        var detail = jsonData['msg'];
        return Success(
          code: 400,
          response: false,
          msg: detail.toString(),
          success: false,
        );
      }
      if (response.statusCode == 500) {
        return Success(
          code: 500,
          response: false,
          msg: "Something went wrong",
          success: false,
        );
      } else {
        return Success(code: 100, response: false, msg: "", success: false);
      }
    } on HttpException {
      return Success(code: 101, response: false, msg: "", success: false);
    }
  }
}
