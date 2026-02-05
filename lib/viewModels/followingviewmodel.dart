// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class FollowingViewModel extends ChangeNotifier {
  late Success _followingresponse;
  Success get followingresponse => _followingresponse;

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

  setFollowingModel(Success followingresponse) async {
    _followingresponse = followingresponse;
    notifyListeners();
  }

  userFollowing(String following_id, String follower_id, String status) async {
    setLoading(true);
    var response = await APIService.userFollowing(
      following_id,
      follower_id,
      status,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setFollowingModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setFollowingModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
