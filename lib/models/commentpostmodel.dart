// To parse this JSON data, do
//
//     final commentPostModel = commentPostModelFromJson(jsonString);

import 'dart:convert';

CommentPostModel commentPostModelFromJson(String str) =>
    CommentPostModel.fromJson(json.decode(str));

String commentPostModelToJson(CommentPostModel data) =>
    json.encode(data.toJson());

class CommentPostModel {
  bool? success;
  String? message;

  CommentPostModel({
    this.success,
    this.message,
  });

  factory CommentPostModel.fromJson(Map<String, dynamic> json) =>
      CommentPostModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
