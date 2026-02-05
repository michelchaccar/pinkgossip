// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class SignUpViewModel extends ChangeNotifier {
  late Success _signupresponse;
  Success get signupresponse => _signupresponse;
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

  setSignupModel(Success signupresponse) async {
    _signupresponse = signupresponse;
    notifyListeners();
  }

  doSignup(
    String first_name,
    String last_name,
    String email,
    String password,
    String user_type,
    String user_name,
    String category,
  ) async {
    setLoading(true);
    var response = await APIService.doSignup(
      first_name,
      last_name,
      email,
      password,
      user_type,
      user_name,
      category,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setSignupModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setSignupModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
