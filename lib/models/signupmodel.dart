// To parse this JSON data, do
//
//     final signUpModel = signUpModelFromJson(jsonString);

import 'dart:convert';

SignUpModel signUpModelFromJson(String str) =>
    SignUpModel.fromJson(json.decode(str));

String signUpModelToJson(SignUpModel data) => json.encode(data.toJson());

class SignUpModel {
  bool? success;
  Response? response;
  String? message;

  SignUpModel({
    this.success,
    this.response,
    this.message,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) => SignUpModel(
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

  Response({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.socialId,
    this.socialType,
    this.createdAt,
    this.updatedAt,
    this.deleted,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        password: json["password"],
        socialId: json["social_id"],
        socialType: json["social_type"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deleted: json["deleted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "social_id": socialId,
        "social_type": socialType,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted": deleted,
      };
}
