// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class CheckUserExistViewModel extends ChangeNotifier {
  late Success _checkuserexistresponse;
  Success get checkuserexistresponse => _checkuserexistresponse;
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

  setCheckUserExistModel(Success checkuserexistresponse) async {
    _checkuserexistresponse = checkuserexistresponse;
    notifyListeners();
  }

  getCheckAccountExist(String social_id) async {
    setLoading(true);
    var response = await APIService.getCheckAccountExist(social_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setCheckUserExistModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setCheckUserExistModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
