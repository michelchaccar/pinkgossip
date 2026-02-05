// To parse this JSON data, do
//
//     final unfollowiModel = unfollowiModelFromJson(jsonString);

import 'dart:convert';

UnfollowiModel unfollowiModelFromJson(String str) =>
    UnfollowiModel.fromJson(json.decode(str));

String unfollowiModelToJson(UnfollowiModel data) => json.encode(data.toJson());

class UnfollowiModel {
  bool? success;
  String? message;

  UnfollowiModel({
    this.success,
    this.message,
  });

  factory UnfollowiModel.fromJson(Map<String, dynamic> json) => UnfollowiModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
