// To parse this JSON data, do
//
//     final removeStoryCronModel = removeStoryCronModelFromJson(jsonString);

import 'dart:convert';

RemoveStoryCronModel removeStoryCronModelFromJson(String str) =>
    RemoveStoryCronModel.fromJson(json.decode(str));

String removeStoryCronModelToJson(RemoveStoryCronModel data) =>
    json.encode(data.toJson());

class RemoveStoryCronModel {
  String? message;

  RemoveStoryCronModel({
    this.message,
  });

  factory RemoveStoryCronModel.fromJson(Map<String, dynamic> json) =>
      RemoveStoryCronModel(
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
