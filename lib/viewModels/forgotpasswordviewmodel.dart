// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class ForgotPassViewModel extends ChangeNotifier {
  late Success _forgotpasswordresponse;
  Success get forgotpasswordresponse => _forgotpasswordresponse;

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

  setForgotPasswordModel(Success forgotpasswordresponse) async {
    _forgotpasswordresponse = forgotpasswordresponse;
    notifyListeners();
  }

  forgotPassword(String email) async {
    setLoading(true);
    var response = await APIService.forgotPassword(email);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setForgotPasswordModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setForgotPasswordModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
