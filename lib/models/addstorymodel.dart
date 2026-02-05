// To parse this JSON data, do
//
//     final addStoryResponseModel = addStoryResponseModelFromJson(jsonString);

import 'dart:convert';

AddStoryResponseModel addStoryResponseModelFromJson(String str) =>
    AddStoryResponseModel.fromJson(json.decode(str));

String addStoryResponseModelToJson(AddStoryResponseModel data) =>
    json.encode(data.toJson());

class AddStoryResponseModel {
  bool? success;
  String? message;
  Data? data;

  AddStoryResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory AddStoryResponseModel.fromJson(Map<String, dynamic> json) =>
      AddStoryResponseModel(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  int? id;
  int? userId;
  String? storyData;
  dynamic createdAt;
  dynamic deletedAt;

  Data({
    this.id,
    this.userId,
    this.storyData,
    this.createdAt,
    this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? 0,
        userId: json["user_id"] ?? 0,
        storyData: json["story_data"] ?? "",
        createdAt: json["created_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "story_data": storyData,
        "created_at": createdAt,
        "deleted_at": deletedAt,
      };
}
