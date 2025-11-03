// To parse this JSON data, do
//
//     final homePostRsponseModel = homePostRsponseModelFromJson(jsonString);

import 'dart:convert';

HomePostRsponseModel homePostRsponseModelFromJson(String str) =>
    HomePostRsponseModel.fromJson(json.decode(str));

String homePostRsponseModelToJson(HomePostRsponseModel data) =>
    json.encode(data.toJson());

class HomePostRsponseModel {
  bool? success;
  int? postCount;
  List<OtherUserPost>? otherUserPost;

  HomePostRsponseModel({
    this.success,
    this.postCount,
    this.otherUserPost,
  });

  factory HomePostRsponseModel.fromJson(Map<String, dynamic> json) =>
      HomePostRsponseModel(
        success: json["success"],
        postCount: json["post_count"],
        otherUserPost: List<OtherUserPost>.from(
            json["other_user_post"].map((x) => OtherUserPost.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "post_count": postCount,
        "other_user_post":
            List<dynamic>.from(otherUserPost!.map((x) => x.toJson())),
      };
}

class OtherUserPost {
  int? id;
  int? userId;
  int? userSalonId;
  String? beforeImage;
  String? afterImage;
  String? other;
  String? rating;
  String? review;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? like;
  String? firstName;
  String? lastName;
  String? profileImage;
  int? userType;
  String? salonName;
  int? ratingCount;
  double? averageRating;
  int? likeCount;
  int? commentCount;
  List<Comment>? comments;
  List<Story>? story;
  List<OtherMultiPost>? otherMultiPost;
  String? userTags;
  String? userName;
  String? postType;

  OtherUserPost({
    this.id,
    this.userId,
    this.userSalonId,
    this.beforeImage,
    this.afterImage,
    this.other,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.like,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.userType,
    this.salonName,
    this.ratingCount,
    this.averageRating,
    this.likeCount,
    this.commentCount,
    this.comments,
    this.otherMultiPost,
    this.story,
    this.userTags,
    this.userName,
    this.postType,
  });

  factory OtherUserPost.fromJson(Map<String, dynamic> json) => OtherUserPost(
        id: json["id"] ?? 0,
        userId: json["user_id"] ?? 0,
        userSalonId: json["user_salon_id"] ?? 0,
        beforeImage: json["before_image"] ?? "",
        afterImage: json["after_image"] ?? "",
        other: json["other"] ?? "",
        rating: json["rating"] ?? "",
        review: json["review"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        like: json["like"] ?? 0,
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        profileImage: json["profile_image"] ?? "",
        userType: json["user_type"],
        salonName: json["salon_name"] ?? "",
        ratingCount: json["rating_count"],
        averageRating: json["average_rating"].toDouble(),
        likeCount: json["like_count"],
        commentCount: json["comment_count"],
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        otherMultiPost: List<OtherMultiPost>.from(
            json["other_multi_Post"].map((x) => OtherMultiPost.fromJson(x))),
        story: json["story"] != []
            ? List<Story>.from(json["story"].map((x) => Story.fromJson(x)))
            : [],
        userTags: json["user_tags"] ?? "",
        userName: json["user_name"] ?? "",
        postType: json["post_type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_salon_id": userSalonId,
        "before_image": beforeImage,
        "after_image": afterImage,
        "other": other,
        "rating": rating,
        "review": review,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "like": like,
        "first_name": firstName,
        "last_name": lastName,
        "profile_image": profileImage,
        "user_type": userType,
        "salon_name": salonName,
        "rating_count": ratingCount,
        "average_rating": averageRating,
        "like_count": likeCount,
        "comment_count": commentCount,
        "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
        "other_multi_Post":
            List<dynamic>.from(otherMultiPost!.map((x) => x.toJson())),
        "story": List<dynamic>.from(story!.map((x) => x.toJson())),
        "user_tags": userTags,
        "user_name": userName,
        "post_type": postType,
      };
}

class Comment {
  int? id;
  int? appUserId;
  int? salonPostId;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? firstName;
  String? lastName;
  String? profileImage;
  int? userType;

  Comment(
      {this.id,
      this.appUserId,
      this.salonPostId,
      this.comment,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.firstName,
      this.lastName,
      this.profileImage,
      this.userType});

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        appUserId: json["app_user_id"],
        salonPostId: json["salon_post_id"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        profileImage: json["profile_image"] ?? "",
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "app_user_id": appUserId,
        "salon_post_id": salonPostId,
        "comment": comment,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "first_name": firstName,
        "last_name": lastName,
        "profile_image": profileImage,
        "user_type": userType,
      };
}

class OtherMultiPost {
  int? id;
  int? salonPostId;
  String? otherData;
  DateTime? createdAt;
  DateTime? updatedAt;

  OtherMultiPost({
    this.id,
    this.salonPostId,
    this.otherData,
    this.createdAt,
    this.updatedAt,
  });

  factory OtherMultiPost.fromJson(Map<String, dynamic> json) => OtherMultiPost(
        id: json["id"] ?? 0,
        salonPostId: json["salon_post_id"] ?? 0,
        otherData: json["other_data"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "salon_post_id": salonPostId,
        "other_data": otherData,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

class Story {
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

  Story({
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

  factory Story.fromJson(Map<String, dynamic> json) => Story(
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
