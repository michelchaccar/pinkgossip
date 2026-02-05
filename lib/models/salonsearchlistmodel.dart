// To parse this JSON data, do
//
//     final salonSearchListModel = salonSearchListModelFromJson(jsonString);

import 'dart:convert';

SalonSearchListModel salonSearchListModelFromJson(String str) =>
    SalonSearchListModel.fromJson(json.decode(str));

String salonSearchListModelToJson(SalonSearchListModel data) =>
    json.encode(data.toJson());

class SalonSearchListModel {
  bool? success;
  List<UserList>? userList;

  SalonSearchListModel({
    this.success,
    this.userList,
  });

  factory SalonSearchListModel.fromJson(Map<String, dynamic> json) =>
      SalonSearchListModel(
        success: json["success"],
        userList: List<UserList>.from(
            json["user_list"].map((x) => UserList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "user_list": List<dynamic>.from(userList!.map((x) => x.toJson())),
      };
}

class UserList {
  int? id;
  String? firstName;
  String? lastName;
  String? salonName;
  String? profileImage;
  int? followerCount;
  List<StoryDatumUserList>? storyData;
  String? userName;

  UserList({
    this.id,
    this.firstName,
    this.lastName,
    this.salonName,
    this.profileImage,
    this.followerCount,
    this.storyData,
    this.userName,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        salonName: json["salon_name"] ?? "",
        profileImage: json["profile_image"] ?? "",
        followerCount: json["follower_count"] ?? 0,
        storyData: List<StoryDatumUserList>.from(
            json["storyData"].map((x) => StoryDatumUserList.fromJson(x))),
        userName: json["user_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "salon_name": salonName,
        "profile_image": profileImage,
        "follower_count": followerCount,
        "storyData": List<dynamic>.from(storyData!.map((x) => x.toJson())),
        "user_name": userName,
      };
}

class StoryDatumUserList {
  int? id;
  int? userId;
  String? storyData;
  DateTime? createdAt;
  dynamic deletedAt;
  String? firstName;
  String? lastName;
  String? salonName;
  String? firebaseId;
  String? profileImage;

  StoryDatumUserList({
    this.id,
    this.userId,
    this.storyData,
    this.createdAt,
    this.deletedAt,
    this.firstName,
    this.lastName,
    this.salonName,
    this.firebaseId,
    this.profileImage,
  });

  factory StoryDatumUserList.fromJson(Map<String, dynamic> json) =>
      StoryDatumUserList(
        id: json["id"] ?? 0,
        userId: json["user_id"] ?? 0,
        storyData: json["story_data"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : json["created_at"],
        deletedAt: json["deleted_at"],
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        salonName: json["salon_name"] ?? "",
        firebaseId: json["firebase_id"] ?? "",
        profileImage: json["profile_image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "story_data": storyData,
        "created_at": createdAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "first_name": firstName,
        "last_name": lastName,
        "salon_name": salonName,
        "firebase_id": firebaseId,
        "profile_image": profileImage,
      };
}
