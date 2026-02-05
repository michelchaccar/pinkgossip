// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class AllFollowerorFollowViewModel extends ChangeNotifier {
  late Success _allfollowerorfollowresponse;
  Success get allfollowerorfollowresponse => _allfollowerorfollowresponse;

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

  seAllFollowerorFollowModel(Success allfollowerorfollowresponse) async {
    _allfollowerorfollowresponse = allfollowerorfollowresponse;
    notifyListeners();
  }

  getFollowersorFollow(
    String id,
    String follow_type,
    String login_user_id,
  ) async {
    setLoading(true);
    var response = await APIService.getFollowersorFollow(
      id,
      follow_type,
      login_user_id,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        seAllFollowerorFollowModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        seAllFollowerorFollowModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
