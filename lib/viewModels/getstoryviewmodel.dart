// // ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class GetStoryViewModel extends ChangeNotifier {
  late Success _getstoryresponse;
  Success get getstoryresponse => _getstoryresponse;

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

  setgetstoryModel(Success getstoryresponse) async {
    _getstoryresponse = getstoryresponse;
    notifyListeners();
  }

  getStory(String id) async {
    setLoading(true);
    var response = await APIService.getStory(id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setgetstoryModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setgetstoryModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
