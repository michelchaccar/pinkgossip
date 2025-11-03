// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class UpdateProfileViewModel extends ChangeNotifier {
  late Success _updateprofileresponse;
  Success get updateprofileresponse => _updateprofileresponse;

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

  setUpdateProfileModel(Success updateprofileresponse) async {
    _updateprofileresponse = updateprofileresponse;
    notifyListeners();
  }

  userProfileUpdate(
    String id,
    String first_name,
    String last_name,
    String email,
    String salon_name,
    String contact_no,
    String address,
    int type,

    // String open_days,
    // String open_time,
    String bio,
    String websitecontroller,
    String latitude,
    String longitude,
    List<Map<String, dynamic>> open_weekdays,
    String user_name,
  ) async {
    setLoading(true);
    var response = await APIService.userProfileUpdate(
      id,
      first_name,
      last_name,
      email,
      salon_name,
      contact_no,
      address,
      user_name,
      // open_days,
      // open_time,
      type,
      bio,
      websitecontroller,
      latitude,
      longitude,
      open_weekdays,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setUpdateProfileModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setUpdateProfileModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
