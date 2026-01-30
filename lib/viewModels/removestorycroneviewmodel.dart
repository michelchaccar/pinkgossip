// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class RemoveStoryCroneViewModel extends ChangeNotifier {
  late Success _removestorycroneresponse;
  Success get removestorycroneresponse => _removestorycroneresponse;

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

  setremovestorycroneModel(Success removestorycroneresponse) async {
    _removestorycroneresponse = removestorycroneresponse;
    notifyListeners();
  }

  getRemoveStoryCron() async {
    setLoading(true);
    var response = await APIService.getRemoveStoryCron();
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setremovestorycroneModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setremovestorycroneModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
