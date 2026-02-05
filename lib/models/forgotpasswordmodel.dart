// To parse this JSON data, do
//
//     final forgotpasswordmodel = forgotpasswordmodelFromJson(jsonString);

import 'dart:convert';

Forgotpasswordmodel forgotpasswordmodelFromJson(String str) =>
    Forgotpasswordmodel.fromJson(json.decode(str));

String forgotpasswordmodelToJson(Forgotpasswordmodel data) =>
    json.encode(data.toJson());

class Forgotpasswordmodel {
  bool? success;
  String? message;

  Forgotpasswordmodel({
    required this.success,
    required this.message,
  });

  factory Forgotpasswordmodel.fromJson(Map<String, dynamic> json) =>
      Forgotpasswordmodel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
