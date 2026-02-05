// To parse this JSON data, do
//
//     final getSalonListModel = getSalonListModelFromJson(jsonString);

import 'dart:convert';

GetSalonListModel getSalonListModelFromJson(String str) =>
    GetSalonListModel.fromJson(json.decode(str));

String getSalonListModelToJson(GetSalonListModel data) =>
    json.encode(data.toJson());

class GetSalonListModel {
  bool? success;
  List<SalonList>? salonList;

  GetSalonListModel({
    this.success,
    this.salonList,
  });

  factory GetSalonListModel.fromJson(Map<String, dynamic> json) =>
      GetSalonListModel(
        success: json["success"],
        salonList: List<SalonList>.from(
            json["salon_list"].map((x) => SalonList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "salon_list": List<dynamic>.from(salonList!.map((x) => x.toJson())),
      };
}

class SalonList {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? salonName;
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
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? ratingCount;
  double? averageRating;
  String? category;

  SalonList({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.salonName,
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
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.ratingCount,
    this.averageRating,
    this.category,
  });

  factory SalonList.fromJson(Map<String, dynamic> json) => SalonList(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        password: json["password"] ?? "",
        salonName: json["salon_name"] ?? "",
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
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        ratingCount: json["rating_count"] ?? 0,
        averageRating: json["average_rating"].toDouble() ?? 0.0,
        category: json["category"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "salon_name": salonName,
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
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "rating_count": ratingCount,
        "average_rating": averageRating,
        "category": category,
      };
}
