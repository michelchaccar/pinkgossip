// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class UpdatePofilePhotoViewModel extends ChangeNotifier {
  late Success _updateprofilephotoresponse;
  Success get updateprofilephotoresponse => _updateprofilephotoresponse;
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

  setUpdateProfilePhotoModel(Success updateprofilephotoresponse) async {
    _updateprofilephotoresponse = updateprofilephotoresponse;
    notifyListeners();
  }

  ProfilePhotoUpdate(String profile_image, String id) async {
    setLoading(true);
    var response = await APIService.ProfilePhotoUpdate(profile_image, id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setUpdateProfilePhotoModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setUpdateProfilePhotoModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
