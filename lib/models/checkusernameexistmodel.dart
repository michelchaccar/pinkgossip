// To parse this JSON data, do
//
//     final checkUsernameExistModel = checkUsernameExistModelFromJson(jsonString);

import 'dart:convert';

CheckUsernameExistModel checkUsernameExistModelFromJson(String str) =>
    CheckUsernameExistModel.fromJson(json.decode(str));

String checkUsernameExistModelToJson(CheckUsernameExistModel data) =>
    json.encode(data.toJson());

class CheckUsernameExistModel {
  bool? success;

  CheckUsernameExistModel({
    this.success,
  });

  factory CheckUsernameExistModel.fromJson(Map<String, dynamic> json) =>
      CheckUsernameExistModel(
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
      };
}
