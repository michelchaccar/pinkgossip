// To parse this JSON data, do
//
//     final profileUpdateModel = profileUpdateModelFromJson(jsonString);

import 'dart:convert';

ProfileUpdateModel profileUpdateModelFromJson(String str) =>
    ProfileUpdateModel.fromJson(json.decode(str));

String profileUpdateModelToJson(ProfileUpdateModel data) =>
    json.encode(data.toJson());

class ProfileUpdateModel {
  bool? success;
  String? message;

  ProfileUpdateModel({
    this.success,
    this.message,
  });

  factory ProfileUpdateModel.fromJson(Map<String, dynamic> json) =>
      ProfileUpdateModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
