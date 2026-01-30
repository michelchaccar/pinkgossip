// To parse this JSON data, do
//
//     final postDeleteModel = postDeleteModelFromJson(jsonString);

import 'dart:convert';

PostDeleteModel postDeleteModelFromJson(String str) =>
    PostDeleteModel.fromJson(json.decode(str));

String postDeleteModelToJson(PostDeleteModel data) =>
    json.encode(data.toJson());

class PostDeleteModel {
  bool? success;
  String? message;

  PostDeleteModel({
    this.success,
    this.message,
  });

  factory PostDeleteModel.fromJson(Map<String, dynamic> json) =>
      PostDeleteModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
