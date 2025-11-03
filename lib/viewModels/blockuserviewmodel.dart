// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class BlockUserViewModel extends ChangeNotifier {
  late Success _reportresponse;
  Success get reportresponse => _reportresponse;
  late Success _blockuserresponse;
  Success get blockuserresponse => _blockuserresponse;
  late Success _unblockuserresponse;
  Success get unblockuserresponse => _unblockuserresponse;
  late Success _deleteaccountresponse;
  Success get deleteaccountresponse => _deleteaccountresponse;
  late Success _allblockeduserresponse;
  Success get allblockeduserresponse => _allblockeduserresponse;

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

  setReportModel(Success reportresponse) async {
    _reportresponse = reportresponse;
    notifyListeners();
  }

  setBlockUserModel(Success blockuserresponse) async {
    _blockuserresponse = blockuserresponse;
    notifyListeners();
  }

  setUnBlockUserModel(Success unblockuserresponse) async {
    _unblockuserresponse = unblockuserresponse;
    notifyListeners();
  }

  setDeleteAccountModel(Success deleteaccountresponse) async {
    _deleteaccountresponse = deleteaccountresponse;
    notifyListeners();
  }

  setAllBlockedUserModel(Success allblockeduserresponse) async {
    _allblockeduserresponse = allblockeduserresponse;
    notifyListeners();
  }

  reportPost(String userId, String postId) async {
    setLoading(true);
    var response = await APIService.reportPost(userId, postId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setReportModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setReportModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }

  blockPost(String userId, String blockUserId) async {
    setLoading(true);
    var response = await APIService.blockUser(userId, blockUserId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setBlockUserModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setBlockUserModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }

  unBlockUser(String userId, String blockUserId) async {
    setLoading(true);
    var response = await APIService.unblockUser(userId, blockUserId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setUnBlockUserModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setUnBlockUserModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }

  deleteAccount(String userId) async {
    setLoading(true);
    var response = await APIService.deleteAccount(userId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setDeleteAccountModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setDeleteAccountModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }

  getBlockedUser(String userId) async {
    setLoading(true);
    var response = await APIService.getBlockedUser(userId);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setAllBlockedUserModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setAllBlockedUserModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
