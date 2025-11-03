// To parse this JSON data, do
//
//     final allfollowingorfollowersmodel = allfollowingorfollowersmodelFromJson(jsonString);

import 'dart:convert';

Allfollowingorfollowersmodel allfollowingorfollowersmodelFromJson(String str) =>
    Allfollowingorfollowersmodel.fromJson(json.decode(str));

String allfollowingorfollowersmodelToJson(Allfollowingorfollowersmodel data) =>
    json.encode(data.toJson());

class Allfollowingorfollowersmodel {
  bool? success;
  List<UserList>? userList;

  Allfollowingorfollowersmodel({
    this.success,
    this.userList,
  });

  factory Allfollowingorfollowersmodel.fromJson(Map<String, dynamic> json) =>
      Allfollowingorfollowersmodel(
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
  String? email;
  String? password;
  String? salonName;
  String? bio;
  String? profileImage;
  String? openDays;
  String? openTime;
  String? contactNo;
  String? siteName;
  String? address;
  String? latitude;
  String? longitude;
  String? socialId;
  String? socialType;
  int? userType;
  String? firebaseId;
  String? fcmToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? isFollowed;
  List<StoryDatum>? storyData;

  UserList(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.salonName,
      this.bio,
      this.profileImage,
      this.openDays,
      this.openTime,
      this.contactNo,
      this.siteName,
      this.address,
      this.latitude,
      this.longitude,
      this.socialId,
      this.socialType,
      this.userType,
      this.firebaseId,
      this.fcmToken,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.isFollowed,
      this.storyData});

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        password: json["password"] ?? "",
        salonName: json["salon_name"] ?? "",
        bio: json["bio"] ?? "",
        profileImage: json["profile_image"] ?? "",
        openDays: json["open_days"] ?? "",
        openTime: json["open_time"] ?? "",
        contactNo: json["contact_no"] ?? "",
        siteName: json["site_name"] ?? "",
        address: json["address"] ?? "",
        latitude: json["latitude"] ?? "",
        longitude: json["longitude"] ?? "",
        socialId: json["social_id"] ?? "",
        socialType: json["social_type"] ?? "",
        userType: json["user_type"] ?? 0,
        firebaseId: json["firebase_id"] ?? "",
        fcmToken: json["fcm_token"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        isFollowed: json["is_followed"],
        storyData: json["storyData"] != []
            ? List<StoryDatum>.from(
                json["storyData"].map((x) => StoryDatum.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "salon_name": salonName,
        "bio": bio,
        "profile_image": profileImage,
        "open_days": openDays,
        "open_time": openTime,
        "contact_no": contactNo,
        "site_name": siteName,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "social_id": socialId,
        "social_type": socialType,
        "user_type": userType,
        "firebase_id": firebaseId,
        "fcm_token": fcmToken,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "is_followed": isFollowed,
        "storyData": List<dynamic>.from(storyData!.map((x) => x.toJson())),
      };
}

class StoryDatum {
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

  StoryDatum({
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

  factory StoryDatum.fromJson(Map<String, dynamic> json) => StoryDatum(
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
