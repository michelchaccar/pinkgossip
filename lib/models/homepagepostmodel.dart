import 'dart:convert';

/// ---------------- RESPONSE MODEL ----------------

HomePostResponseModel homePostResponseModelFromJson(String str) =>
    HomePostResponseModel.fromJson(json.decode(str));

String homePostResponseModelToJson(HomePostResponseModel data) =>
    json.encode(data.toJson());

class HomePostResponseModel {
  bool success;
  int postCount;
  List<OtherUserPost> otherUserPost;

  HomePostResponseModel({
    required this.success,
    required this.postCount,
    required this.otherUserPost,
  });

  factory HomePostResponseModel.fromJson(Map<String, dynamic> json) {
    return HomePostResponseModel(
      success: json["success"] ?? false,
      postCount: json["post_count"] ?? 0,
      otherUserPost:
          json["other_user_post"] != null
              ? List<OtherUserPost>.from(
                json["other_user_post"].map((x) => OtherUserPost.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "post_count": postCount,
    "other_user_post": otherUserPost.map((x) => x.toJson()).toList(),
  };
}

/// ---------------- POST MODEL ----------------

class OtherUserPost {
  int id;
  int userId;
  int userSalonId;
  String beforeImage;
  String afterImage;
  String other;
  String rating;
  String reward_id;
  String redeem_point;
  String reward_tag;
  String review;
  int revardPoint;
  String postType;
  String userTags;
  String userName;
  String firstName;
  String lastName;
  String profileImage;
  int userType;
  String salonName;
  int ratingCount;
  double averageRating;
  int? like;
  int likeCount;
  int commentCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<Comment> comments;
  List<Story> story;
  List<OtherMultiPost> otherMultiPost;

  OtherUserPost({
    required this.id,
    required this.userId,
    required this.userSalonId,
    required this.beforeImage,
    required this.afterImage,
    required this.other,
    required this.rating,
    required this.reward_id,
    required this.redeem_point,
    required this.reward_tag,
    required this.review,
    required this.revardPoint,
    required this.postType,
    required this.userTags,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.userType,
    required this.salonName,
    required this.ratingCount,
    required this.averageRating,
    required this.like,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.comments,
    required this.story,
    required this.otherMultiPost,
  });

  factory OtherUserPost.fromJson(Map<String, dynamic> json) {
    return OtherUserPost(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      userSalonId: json["user_salon_id"] ?? 0,
      beforeImage: json["before_image"] ?? "",
      afterImage: json["after_image"] ?? "",
      other: json["other"] ?? "",
      rating: json["rating"] ?? "0",
      reward_id: json["reward_id"] ?? "",
      redeem_point: json["redeem_point"] ?? "",
      reward_tag: json["reward_tag"] ?? "",
      review: json["review"] ?? "",
      revardPoint: json["revard_point"] ?? 0,
      postType: json["post_type"] ?? "",
      userTags: json["user_tags"] ?? "",
      userName: json["user_name"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      profileImage: json["profile_image"] ?? "",
      userType: json["user_type"] ?? 0,
      salonName: json["salon_name"] ?? "",
      ratingCount: json["rating_count"] ?? 0,
      averageRating: (json["average_rating"] as num?)?.toDouble() ?? 0.0,
      like: json["like"] ?? 0,
      likeCount: json["like_count"] ?? 0,
      commentCount: json["comment_count"] ?? 0,
      createdAt:
          json["created_at"] != null
              ? DateTime.tryParse(json["created_at"])
              : null,
      updatedAt:
          json["updated_at"] != null
              ? DateTime.tryParse(json["updated_at"])
              : null,
      deletedAt: json["deleted_at"],
      comments:
          json["comments"] != null
              ? List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x)),
              )
              : [],
      story:
          json["story"] != null
              ? List<Story>.from(json["story"].map((x) => Story.fromJson(x)))
              : [],
      otherMultiPost:
          json["other_multi_Post"] != null
              ? List<OtherMultiPost>.from(
                json["other_multi_Post"].map((x) => OtherMultiPost.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "user_salon_id": userSalonId,
    "before_image": beforeImage,
    "after_image": afterImage,
    "other": other,
    "rating": rating,
    "review": review,
    "revard_point": revardPoint,
    "reward_tag": reward_tag,
    "post_type": postType,
    "user_tags": userTags,
    "user_name": userName,
    "first_name": firstName,
    "last_name": lastName,
    "profile_image": profileImage,
    "user_type": userType,
    "salon_name": salonName,
    "rating_count": ratingCount,
    "average_rating": averageRating,
    "like": like ?? 0,
    "like_count": likeCount,
    "comment_count": commentCount,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "comments": comments.map((x) => x.toJson()).toList(),
    "story": story.map((x) => x.toJson()).toList(),
    "other_multi_Post": otherMultiPost.map((x) => x.toJson()).toList(),
  };
}

/// ---------------- COMMENT ----------------

class Comment {
  int id;
  int appUserId;
  int salonPostId;
  String comment;
  String firstName;
  String lastName;
  String profileImage;
  int userType;
  DateTime? createdAt;
  DateTime? updatedAt;

  Comment({
    required this.id,
    required this.appUserId,
    required this.salonPostId,
    required this.comment,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"] ?? 0,
      appUserId: json["app_user_id"] ?? 0,
      salonPostId: json["salon_post_id"] ?? 0,
      comment: json["comment"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      profileImage: json["profile_image"] ?? "",
      userType: json["user_type"] ?? 0,
      createdAt:
          json["created_at"] != null
              ? DateTime.tryParse(json["created_at"])
              : null,
      updatedAt:
          json["updated_at"] != null
              ? DateTime.tryParse(json["updated_at"])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "app_user_id": appUserId,
    "salon_post_id": salonPostId,
    "comment": comment,
    "first_name": firstName,
    "last_name": lastName,
    "profile_image": profileImage,
    "user_type": userType,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

/// ---------------- MULTI POST ----------------

class OtherMultiPost {
  int id;
  int salonPostId;
  String otherData;

  OtherMultiPost({
    required this.id,
    required this.salonPostId,
    required this.otherData,
  });

  factory OtherMultiPost.fromJson(Map<String, dynamic> json) {
    return OtherMultiPost(
      id: json["id"] ?? 0,
      salonPostId: json["salon_post_id"] ?? 0,
      otherData: json["other_data"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "salon_post_id": salonPostId,
    "other_data": otherData,
  };
}

/// ---------------- STORY ----------------

class Story {
  int id;
  int userId;
  String storyData;
  String firstName;
  String lastName;
  String salonName;
  String firebaseId;
  String profileImage;
  DateTime? createdAt;

  Story({
    required this.id,
    required this.userId,
    required this.storyData,
    required this.firstName,
    required this.lastName,
    required this.salonName,
    required this.firebaseId,
    required this.profileImage,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      storyData: json["story_data"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      salonName: json["salon_name"] ?? "",
      firebaseId: json["firebase_id"] ?? "",
      profileImage: json["profile_image"] ?? "",
      createdAt:
          json["created_at"] != null
              ? DateTime.tryParse(json["created_at"])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "story_data": storyData,
    "first_name": firstName,
    "last_name": lastName,
    "salon_name": salonName,
    "firebase_id": firebaseId,
    "profile_image": profileImage,
    "created_at": createdAt?.toIso8601String(),
  };
}
