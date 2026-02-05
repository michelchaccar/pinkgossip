// getActivityList

// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:pinkGossip/utils/apiservice.dart';
import 'package:flutter/material.dart';

import '../models/successmodel.dart';

class NotificationListViewModel extends ChangeNotifier {
  late Success _notificationresponse;
  Success get notificationresponse => _notificationresponse;
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

  setNotificationModel(Success notificationresponse) async {
    _notificationresponse = notificationresponse;
    notifyListeners();
  }

  getNotificationList(String id) async {
    setLoading(true);
    var response = await APIService.getNotificationList(id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setNotificationModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setNotificationModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
