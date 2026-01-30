// getActivityList

// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:pinkGossip/utils/apiservice.dart';
import 'package:flutter/material.dart';

import '../models/successmodel.dart';

class UpdateDeviceTokenViewModel extends ChangeNotifier {
  late Success _updatedevicetokenresponse;
  Success get updatedevicetokenresponse => _updatedevicetokenresponse;
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

  setUpdateDeviceTokenModel(Success updatedevicetokenresponse) async {
    _updatedevicetokenresponse = updatedevicetokenresponse;
    notifyListeners();
  }

  updateFirebaseId(String u_id, String firebase_id, String fcm_token) async {
    setLoading(true);
    var response = await APIService.updateFirebaseId(
      u_id,
      firebase_id,
      fcm_token,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setUpdateDeviceTokenModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setUpdateDeviceTokenModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
