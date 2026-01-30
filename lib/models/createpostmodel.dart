// To parse this JSON data, do
//
//     final createPostModel = createPostModelFromJson(jsonString);

import 'dart:convert';

CreatePostModel createPostModelFromJson(String str) =>
    CreatePostModel.fromJson(json.decode(str));

String createPostModelToJson(CreatePostModel data) =>
    json.encode(data.toJson());

class CreatePostModel {
  bool? success;
  Response? response;
  String? message;

  CreatePostModel({
    this.success,
    this.response,
    this.message,
  });

  factory CreatePostModel.fromJson(Map<String, dynamic> json) =>
      CreatePostModel(
        success: json["success"],
        response: json["response"] != null
            ? Response.fromJson(json["response"])
            : Response(),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "response": response!.toJson(),
        "message": message,
      };
}

class Response {
  int? id;
  int? userId;
  dynamic userSalonId;
  String? beforeImage;
  String? afterImage;
  String? other;
  String? rating;
  String? review;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Response({
    this.id,
    this.userId,
    this.userSalonId,
    this.beforeImage,
    this.afterImage,
    this.other,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        userId: json["user_id"],
        userSalonId: json["user_salon_id"],
        beforeImage: json["before_image"],
        afterImage: json["after_image"],
        other: json["other"],
        rating: json["rating"],
        review: json["review"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_salon_id": userSalonId,
        "before_image": beforeImage,
        "after_image": afterImage,
        "other": other,
        "rating": rating,
        "review": review,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
