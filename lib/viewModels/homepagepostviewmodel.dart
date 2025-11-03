// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class HomePagePostViewModel extends ChangeNotifier {
  late Success _homepagepostresponse;
  Success get homepagepostresponse => _homepagepostresponse;
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

  setHomePagePostModel(Success homepagepostresponse) async {
    _homepagepostresponse = homepagepostresponse;
    notifyListeners();
  }

  HomePagePost(String id, int offset) async {
    setLoading(true);
    var response = await APIService.HomePagePost(id, offset);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setHomePagePostModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setHomePagePostModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
