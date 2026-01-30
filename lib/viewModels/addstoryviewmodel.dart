// // ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class AddStoryViewModel extends ChangeNotifier {
  late Success _addstoryresponse;
  Success get addstoryresponse => _addstoryresponse;

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

  setaddstoryModel(Success addstoryresponse) async {
    _addstoryresponse = addstoryresponse;
    notifyListeners();
  }

  doAddStory(String id, File story_data) async {
    setLoading(true);
    var response = await APIService.doAddStory(id, story_data);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setaddstoryModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setaddstoryModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
