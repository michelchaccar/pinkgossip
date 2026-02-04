// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/referralmodel.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class ReferralViewModel extends ChangeNotifier {
  ReferralCodeModel? _referralCodeModel;
  ReferralCodeModel? get referralCodeModel => _referralCodeModel;

  ReferralStatsModel? _referralStatsModel;
  ReferralStatsModel? get referralStatsModel => _referralStatsModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String _errorMsg = "";
  String get errorMsg => _errorMsg;

  setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchReferralCode(String userId) async {
    setLoading(true);
    var response = await APIService.getReferralCode(userId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        _referralCodeModel = result.response as ReferralCodeModel;
        _isSuccess = true;
      } else {
        _isSuccess = false;
        _errorMsg = result.msg;
      }
    }
    setLoading(false);
  }

  Future<void> fetchReferralStats(String userId) async {
    var response = await APIService.getReferralStats(userId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        _referralStatsModel = result.response as ReferralStatsModel;
      }
    }
    notifyListeners();
  }

  Future<bool> claimReferral(String userId, String referralCode) async {
    var response = await APIService.claimReferral(userId, referralCode);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        return true;
      } else {
        _errorMsg = result.msg;
        return false;
      }
    }
    return false;
  }

  String getShareMessage(String code, String link) {
    return link;
  }
}
