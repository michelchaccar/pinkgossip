// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? success;
  Response? response;
  String? message;

  LoginModel({
    this.success,
    this.response,
    this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        success: json["success"],
        response: Response.fromJson(json["response"]),
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
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  dynamic socialId;
  dynamic socialType;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deleted;
  String? salonName;
  String? profileImage;
  String? openDays;
  String? openTime;
  String? contactNo;
  String? siteName;
  String? address;
  String? latitude;
  String? longitude;
  int? userType;
  dynamic deletedAt;
  String? bio;
  String? firebaseId;
  String? fcmToken;

  Response({
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
    this.bio,
    this.firebaseId,
    this.fcmToken,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        password: json["password"],
        salonName: json["salon_name"],
        profileImage: json["profile_image"],
        openDays: json["open_days"],
        openTime: json["open_time"],
        contactNo: json["contact_no"],
        siteName: json["site_name"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        socialId: json["social_id"],
        socialType: json["social_type"],
        userType: json["user_type"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        bio: json["bio"],
        firebaseId: json["firebase_id"],
        fcmToken: json["fcm_token"],
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
        "bio": bio,
        "firebase_id": firebaseId,
        "fcm_token": fcmToken,
      };
}
