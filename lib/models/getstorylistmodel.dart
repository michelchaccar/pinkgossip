// To parse this JSON data, do
//
//     final getStoryResponseModel = getStoryResponseModelFromJson(jsonString);

import 'dart:convert';

GetStoryResponseModel getStoryResponseModelFromJson(String str) =>
    GetStoryResponseModel.fromJson(json.decode(str));

String getStoryResponseModelToJson(GetStoryResponseModel data) =>
    json.encode(data.toJson());

class GetStoryResponseModel {
  bool? success;
  String? message;
  List<Stories>? data;

  GetStoryResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetStoryResponseModel.fromJson(Map<String, dynamic> json) =>
      GetStoryResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? List<Stories>.from(json["data"].map((x) => Stories.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Stories {
  int? id;
  int? userId;
  String? storyData;
  DateTime? createdAt;
  dynamic deletedAt;
  String? firstName;
  String? lastName;
  String? salonName;
  String? profileImage;
  String? firebaseId;

  Stories({
    this.id,
    this.userId,
    this.storyData,
    this.createdAt,
    this.deletedAt,
    this.firstName,
    this.lastName,
    this.salonName,
    this.profileImage,
    this.firebaseId,
  });

  factory Stories.fromJson(Map<String, dynamic> json) => Stories(
        id: json["id"],
        userId: json["user_id"],
        storyData: json["story_data"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        deletedAt: json["deleted_at"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        salonName: json["salon_name"],
        profileImage: json["profile_image"],
        firebaseId: json["firebase_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "story_data": storyData,
        "created_at": createdAt,
        "deleted_at": deletedAt,
        "first_name": firstName,
        "last_name": lastName,
        "salon_name": salonName,
        "profile_image": profileImage,
        "firebase_id": firebaseId,
      };
}
