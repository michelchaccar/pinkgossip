// To parse this JSON data, do
//
//     final deviceTokenUpdateModel = deviceTokenUpdateModelFromJson(jsonString);

import 'dart:convert';

DeviceTokenUpdateModel deviceTokenUpdateModelFromJson(String str) =>
    DeviceTokenUpdateModel.fromJson(json.decode(str));

String deviceTokenUpdateModelToJson(DeviceTokenUpdateModel data) =>
    json.encode(data.toJson());

class DeviceTokenUpdateModel {
  bool? success;
  String? message;

  DeviceTokenUpdateModel({
    this.success,
    this.message,
  });

  factory DeviceTokenUpdateModel.fromJson(Map<String, dynamic> json) =>
      DeviceTokenUpdateModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
