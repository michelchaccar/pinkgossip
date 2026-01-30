// To parse this JSON data, do
//
//     final checkUserExistModel = checkUserExistModelFromJson(jsonString);

import 'dart:convert';

CheckUserExistModel checkUserExistModelFromJson(String str) => CheckUserExistModel.fromJson(json.decode(str));

String checkUserExistModelToJson(CheckUserExistModel data) => json.encode(data.toJson());

class CheckUserExistModel {
    bool? success;

    CheckUserExistModel({
        this.success,
    });

    factory CheckUserExistModel.fromJson(Map<String, dynamic> json) => CheckUserExistModel(
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
    };
}
