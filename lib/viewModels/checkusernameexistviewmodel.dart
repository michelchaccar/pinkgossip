// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class CheckUserNameExistViewModel extends ChangeNotifier {
  late Success _checkusernameexistresponse;
  Success get checkusernameexistresponse => _checkusernameexistresponse;

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

  setcheckusernameexistModel(Success checkusernameexistresponse) async {
    _checkusernameexistresponse = checkusernameexistresponse;
    notifyListeners();
  }

  getcheckUsernameExist(String user_name) async {
    setLoading(true);
    var response = await APIService.getcheckUsernameExist(user_name);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setcheckusernameexistModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setcheckusernameexistModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
