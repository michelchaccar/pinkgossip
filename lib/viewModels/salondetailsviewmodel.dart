// // ignore_for_file: avoid_print

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class SalonDetailsViewModel extends ChangeNotifier {
  late Success _salondetailsresponse;
  Success get salondetailsresponse => _salondetailsresponse;
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

  setSalonDetailsModel(Success salondetailsresponse) async {
    _salondetailsresponse = salondetailsresponse;
    notifyListeners();
  }

  getSalonDetails(
    String id,
    String user_id,
    int offset,
    String user_type,
  ) async {
    setLoading(true);
    var response = await APIService.getSalonDetails(
      id,
      user_id,
      offset,
      user_type,
    );
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setSalonDetailsModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setSalonDetailsModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
