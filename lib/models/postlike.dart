// To parse this JSON data, do
//
//     final postLikeModel = postLikeModelFromJson(jsonString);

import 'dart:convert';

PostLikeModel postLikeModelFromJson(String str) =>
    PostLikeModel.fromJson(json.decode(str));

String postLikeModelToJson(PostLikeModel data) => json.encode(data.toJson());

class PostLikeModel {
  bool? success;
  int? likeCount;
  String? message;

  PostLikeModel({
    this.success,
    this.likeCount,
    this.message,
  });

  factory PostLikeModel.fromJson(Map<String, dynamic> json) => PostLikeModel(
        success: json["success"],
        likeCount: json["like_count"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "like_count": likeCount,
        "message": message,
      };
}
