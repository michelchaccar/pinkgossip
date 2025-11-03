// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class PostLikeViewModel extends ChangeNotifier {
  late Success _postlikeresponse;
  Success get postlikeresponse => _postlikeresponse;

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

  setPostLikeModel(Success postlikeresponse) async {
    _postlikeresponse = postlikeresponse;
    notifyListeners();
  }

  doPostLike(String user_id, String post_id, String like) async {
    setLoading(true);
    var response = await APIService.doPostLike(user_id, post_id, like);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setPostLikeModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setPostLikeModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
