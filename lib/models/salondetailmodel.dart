// To parse this JSON data, do
//
//     final salonDetailModel = salonDetailModelFromJson(jsonString);

import 'dart:convert';

SalonDetailModel salonDetailModelFromJson(String str) =>
    SalonDetailModel.fromJson(json.decode(str));

String salonDetailModelToJson(SalonDetailModel data) =>
    json.encode(data.toJson());

class SalonDetailModel {
  bool? success;
  UserProfile? userProfile;
  List<Post>? posts;
  int? postCount;
  List<SalonOpenDay>? salonOpenDays;
  List<StoryUserDetails>? story;
  List<TagPost>? tagPosts;
  int? points;
  int? postCountReview;

  SalonDetailModel({
    this.success,
    this.userProfile,
    this.posts,
    this.postCount,
    this.salonOpenDays,
    this.story,
    this.tagPosts,
    this.points,
    this.postCountReview,
  });

  factory SalonDetailModel.fromJson(Map<String, dynamic> json) =>
      SalonDetailModel(
        success: json["success"],
        userProfile: UserProfile.fromJson(json["user_profile"]),
        posts:
            json["posts"] != []
                ? List<Post>.from(json["posts"].map((x) => Post.fromJson(x)))
                : [],
        postCount: json["post_count"] ?? 0,
        salonOpenDays:
            json["salon_open_days"] != []
                ? List<SalonOpenDay>.from(
                  json["salon_open_days"].map((x) => SalonOpenDay.fromJson(x)),
                )
                : [],
        story:
            json["story"] != []
                ? List<StoryUserDetails>.from(
                  json["story"].map((x) => StoryUserDetails.fromJson(x)),
                )
                : [],
        tagPosts:
            json["tag_posts"] != []
                ? List<TagPost>.from(
                  json["tag_posts"].map((x) => TagPost.fromJson(x)),
                )
                : [],
        points: json["points"] ?? 0,
        postCountReview: json["post_count_review"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "user_profile": userProfile!.toJson(),
    "posts": List<dynamic>.from(posts!.map((x) => x.toJson())),
    "post_count": postCount,
    "salon_open_days": List<dynamic>.from(
      salonOpenDays!.map((x) => x.toJson()),
    ),
    "story": List<dynamic>.from(story!.map((x) => x.toJson())),
    "tag_posts": List<dynamic>.from(tagPosts!.map((x) => x.toJson())),
    "points": points,
    "post_count_review": postCountReview,
  };
}

class Post {
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
  String? salonName;
  int? ratingCount;
  double? averageRating;
  int? likeCount;
  int? commentCount;
  List<Comment>? comments;
  List<OtherMultiPost>? otherMultiPost;
  String? userTags;
  String? userName;
  String? postType;

  Post({
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
    this.salonName,
    this.ratingCount,
    this.averageRating,
    this.likeCount,
    this.commentCount,
    this.comments,
    this.otherMultiPost,
    this.userTags,
    this.userName,
    this.postType,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
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
    salonName: json["salon_name"] ?? "",
    ratingCount: json["rating_count"] ?? 0,
    averageRating: json["average_rating"].toDouble(),
    likeCount: json["like_count"] ?? 0,
    commentCount: json["comment_count"] ?? 0,
    comments: List<Comment>.from(
      json["comments"].map((x) => Comment.fromJson(x)),
    ),
    otherMultiPost: List<OtherMultiPost>.from(
      json["other_multi_Post"].map((x) => OtherMultiPost.fromJson(x)),
    ),
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
    "salon_name": salonName,
    "rating_count": ratingCount,
    "average_rating": averageRating,
    "like_count": likeCount,
    "comment_count": commentCount,
    "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
    "other_multi_Post": List<dynamic>.from(
      otherMultiPost!.map((x) => x.toJson()),
    ),
    "user_tags": userTags,
    "user_name": userName,
    "post_type": postType,
  };
}

class TagPost {
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
  String? salonName;
  int? ratingCount;
  int? likeCount;
  int? commentCount;
  List<Comment>? comments;
  List<OtherMultiPost>? otherMultiPost;
  String? userTags;
  String? userName;
  String? postType;
  int? userType;
  double? averageRating;

  TagPost({
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
    this.salonName,
    this.ratingCount,
    this.likeCount,
    this.commentCount,
    this.comments,
    this.otherMultiPost,
    this.userTags,
    this.userName,
    this.postType,
    this.userType,
    this.averageRating,
  });

  factory TagPost.fromJson(Map<String, dynamic> json) => TagPost(
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
    salonName: json["salon_name"] ?? "",
    ratingCount: json["rating_count"] ?? 0,
    likeCount: json["like_count"] ?? 0,
    commentCount: json["comment_count"] ?? 0,
    comments: List<Comment>.from(
      json["comments"].map((x) => Comment.fromJson(x)),
    ),
    otherMultiPost: List<OtherMultiPost>.from(
      json["other_multi_Post"].map((x) => OtherMultiPost.fromJson(x)),
    ),
    userTags: json["user_tags"] ?? "",
    userName: json["user_name"] ?? "",
    postType: json["post_type"] ?? "",
    userType: json["user_type"] ?? 0,
    averageRating: json["average_rating"].toDouble(),
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
    "salon_name": salonName,
    "rating_count": ratingCount,
    "like_count": likeCount,
    "comment_count": commentCount,
    "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
    "other_multi_Post": List<dynamic>.from(
      otherMultiPost!.map((x) => x.toJson()),
    ),
    "user_tags": userTags,
    "user_name": userName,
    "post_type": postType,
    "user_type": userType,
    "average_rating": averageRating,
  };
}

class UserProfile {
  int? id;
  String? userName;
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
  String? deletedAt;
  int? ratingCount;
  String? averageRating;
  int? followingCount;
  int? followersCount;
  int? isFollowed;
  String? bio;
  String? firebaseId;
  String? fcmToken;

  UserProfile({
    this.id,
    this.userName,
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
    this.followingCount,
    this.followersCount,
    this.isFollowed,
    this.bio,
    this.firebaseId,
    this.fcmToken,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"] ?? 0,
    userName: json["user_name"] ?? "",
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
    deletedAt: json["deleted_at"] ?? "",
    ratingCount: json["rating_count"] ?? 0,
    averageRating: json["average_rating"].toString(),
    followingCount: json["following_count"] ?? 0,
    followersCount: json["follower_count"] ?? 0,
    isFollowed: json["is_followed"] ?? 0,
    bio: json["bio"] ?? "",
    firebaseId: json["firebase_id"] ?? "",
    fcmToken: json["fcm_token"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
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
    "following_count": followingCount,
    "followers_count": followersCount,
    "is_followed": isFollowed,
    "bio": bio,
    "firebase_id": firebaseId,
    "fcm_token": fcmToken,
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

  Comment({
    this.id,
    this.appUserId,
    this.salonPostId,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.firstName,
    this.lastName,
    this.profileImage,
  });

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
    profileImage: json["profile_image"],
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
    id: json["id"],
    salonPostId: json["salon_post_id"],
    otherData: json["other_data"],
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

class SalonOpenDay {
  int? id;
  int? appUserId;
  String? open;
  String? startTime;
  String? endTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  SalonOpenDay({
    this.id,
    this.appUserId,
    this.open,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory SalonOpenDay.fromJson(Map<String, dynamic> json) => SalonOpenDay(
    id: json["id"],
    appUserId: json["app_user_id"],
    open: json["open"],
    startTime: json["start_time"] ?? "00:00:00",
    endTime: json["end_time"] ?? "00:00:00",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "app_user_id": appUserId,
    "open": open,
    "start_time": startTime,
    "end_time": endTime,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class StoryUserDetails {
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

  StoryUserDetails({
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

  factory StoryUserDetails.fromJson(Map<String, dynamic> json) =>
      StoryUserDetails(
        id: json["id"] ?? 0,
        userId: json["user_id"] ?? 0,
        storyData: json["story_data"] ?? "",
        createdAt:
            json["created_at"] != null
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
