// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class GetQRCodeViewModel extends ChangeNotifier {
  late Success _getqrcoderesponse;
  Success get getqrcoderesponse => _getqrcoderesponse;

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

  setGetQRCodeModel(Success getqrcoderesponse) async {
    _getqrcoderesponse = getqrcoderesponse;
    notifyListeners();
  }

  getQRCode(String u_id) async {
    setLoading(true);
    var response = await APIService.getQRCode(u_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setGetQRCodeModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setGetQRCodeModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
