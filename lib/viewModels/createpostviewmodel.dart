// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';
import 'package:video_compress/video_compress.dart';

class CreatePostViewModel extends ChangeNotifier {
  late Success _createpostresponse;
  Success get createpostresponse => _createpostresponse;
  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(bool loading) async {
    _isLoading = loading;
    notifyListeners();
  }

  setSuccess(bool isSuccess) async {
    _isSuccess = isSuccess;
    notifyListeners();
  }

  setCreatePostModel(Success createpostresponse) async {
    _createpostresponse = createpostresponse;
    notifyListeners();
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
    String post_type,
    String rewardpoint,
  ) async {
    print("Reward Post Submit Clicked 2");
    setLoading(true);
    var response = await APIService.CreatePost(
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
    if (response is Success) {
      print(" response == ${response.code}");
      print(" response == ${response.msg}");
      print(" response == ${response.success}");
      print(" response == ${response.response}");
      Success result = response;
      if (result.success == true) {
        setCreatePostModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        // setCreatePostModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
