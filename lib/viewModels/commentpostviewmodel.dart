// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class CommentPostViewModel extends ChangeNotifier {
  late Success _commentpostresponse;
  Success get commentpostresponse => _commentpostresponse;

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

  setCommentPostModel(Success commentpostresponse) async {
    _commentpostresponse = commentpostresponse;
    notifyListeners();
  }

  doCommentPost(
    String app_user_id,
    String salon_post_id,
    String comment,
  ) async {
    setLoading(true);
    var response = await APIService.doCommentPost(
      app_user_id,
      salon_post_id,
      comment,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setCommentPostModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setCommentPostModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
