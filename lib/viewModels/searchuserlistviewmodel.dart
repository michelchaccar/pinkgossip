// // ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinkGossip/models/successmodel.dart';
import 'package:pinkGossip/utils/apiservice.dart';

class SearchUserListViewModelViewModel extends ChangeNotifier {
  late Success _searchuserlistresponse;
  Success get searchuserlistresponse => _searchuserlistresponse;

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

  setSearchUserListModel(Success searchuserlistresponse) async {
    _searchuserlistresponse = searchuserlistresponse;
    notifyListeners();
  }

  getsearchUserList(String type, String u_id) async {
    setLoading(true);
    var response = await APIService.getsearchUserList(type, u_id);
    if (response is Success) {
      Success result = response;
      if (result.success == true) {
        setSearchUserListModel(response);
        setSuccess(true);
        setLoading(false);
      } else {
        setSuccess(false);
        setSearchUserListModel(response);
        setLoading(false);
      }
      notifyListeners();
    }
  }
}
