// To parse this JSON data, do
//
//     final getNotificationModel = getNotificationModelFromJson(jsonString);

import 'dart:convert';

GetNotificationModel getNotificationModelFromJson(String str) =>
    GetNotificationModel.fromJson(json.decode(str));

String getNotificationModelToJson(GetNotificationModel data) =>
    json.encode(data.toJson());

class GetNotificationModel {
  bool? success;
  List<GetNotification>? notifications;

  GetNotificationModel({
    this.success,
    this.notifications,
  });

  factory GetNotificationModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationModel(
        success: json["success"],
        notifications: json["notifications"].isNotEmpty
            ? List<GetNotification>.from(
                json["notifications"].map((x) => GetNotification.fromJson(x)))
            : json["notifications"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "notifications":
            List<dynamic>.from(notifications!.map((x) => x.toJson())),
      };
}

class GetNotification {
  int? id;
  int? fromUserId;
  int? toUserId;
  int? salonPostId;
  String? text;
  String? textFr;
  int? isPush;
  int? isRead;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  String? profileImage;
  String? firstName;
  String? lastName;

  GetNotification({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.salonPostId,
    this.text,
    this.textFr,
    this.isPush,
    this.isRead,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  factory GetNotification.fromJson(Map<String, dynamic> json) =>
      GetNotification(
        id: json["id"] ?? 0,
        fromUserId: json["from_user_id"] ?? 0,
        toUserId: json["to_user_id"] ?? 0,
        salonPostId: json["salon_post_id"] ?? 0,
        text: json["text"] ?? "",
        textFr: json["text_fr"] ?? "",
        isPush: json["is_push"] ?? 0,
        isRead: json["is_read"] ?? 0,
        type: json["type"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        profileImage: json["profile_image"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "from_user_id": fromUserId,
        "to_user_id": toUserId,
        "salon_post_id": salonPostId,
        "text": text,
        "text_fr": textFr,
        "is_push": isPush,
        "is_read": isRead,
        "type": type,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "profile_image": profileImage,
        "first_name": firstName,
        "last_name": lastName,
      };
}
