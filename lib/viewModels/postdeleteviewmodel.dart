// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class PostDeleteViewModel extends ChangeNotifier {
  late Success _postdeleteresponse;
  Success get postdeleteresponse => _postdeleteresponse;

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

  setPostDeleteModel(Success postdeleteresponse) async {
    _postdeleteresponse = postdeleteresponse;
    notifyListeners();
  }

  getPostDelete(String post_id) async {
    setLoading(true);
    var response = await APIService.getPostDelete(post_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setPostDeleteModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setPostDeleteModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
