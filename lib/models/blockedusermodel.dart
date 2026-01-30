// To parse this JSON data, do
//
//     final blockedUserResponseModel = blockedUserResponseModelFromJson(jsonString);

import 'dart:convert';

BlockedUserResponseModel blockedUserResponseModelFromJson(String str) =>
    BlockedUserResponseModel.fromJson(json.decode(str));

String blockedUserResponseModelToJson(BlockedUserResponseModel data) =>
    json.encode(data.toJson());

class BlockedUserResponseModel {
  bool? success;
  List<BlockedUserDatum>? notifications;

  BlockedUserResponseModel({
    this.success,
    this.notifications,
  });

  factory BlockedUserResponseModel.fromJson(Map<String, dynamic> json) =>
      BlockedUserResponseModel(
        success: json["success"],
        notifications: List<BlockedUserDatum>.from(
            json["notifications"].map((x) => BlockedUserDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "notifications":
            List<dynamic>.from(notifications!.map((x) => x.toJson())),
      };
}

class BlockedUserDatum {
  int? id;
  int? userId;
  int? blockUserId;
  DateTime? createdAt;
  String? profileImage;
  String? firstName;
  String? lastName;

  BlockedUserDatum({
    this.id,
    this.userId,
    this.blockUserId,
    this.createdAt,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  factory BlockedUserDatum.fromJson(Map<String, dynamic> json) => BlockedUserDatum(
        id: json["id"],
        userId: json["user_id"],
        blockUserId: json["block_user_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        profileImage: json["profile_image"],
        firstName: json["first_name"],
        lastName: json["last_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "block_user_id": blockUserId,
        "created_at": createdAt?.toIso8601String(),
        "profile_image": profileImage,
        "first_name": firstName,
        "last_name": lastName,
      };
}
