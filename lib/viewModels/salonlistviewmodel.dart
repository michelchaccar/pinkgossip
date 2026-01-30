// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';

import '../Utils/apiservice.dart';

class SalonListViewModel extends ChangeNotifier {
  late Success _salonlistresponse;
  Success get salonlistresponse => _salonlistresponse;
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

  setSalonistModel(Success salonlistresponse) async {
    _salonlistresponse = salonlistresponse;
    notifyListeners();
  }

  getSalonList(String user_id) async {
    setLoading(true);
    var response = await APIService.getSalonList(user_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setSalonistModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setSalonistModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
