// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class UnfollowViewModel extends ChangeNotifier {
  late Success _unfollowresponse;
  Success get unfollowresponse => _unfollowresponse;

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

  setUnfollowModel(Success unfollowresponse) async {
    _unfollowresponse = unfollowresponse;
    notifyListeners();
  }

  userUnfollow(String following_id, String follower_id) async {
    setLoading(true);
    var response = await APIService.userUnfollow(following_id, follower_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setUnfollowModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setUnfollowModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
