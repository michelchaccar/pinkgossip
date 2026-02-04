import 'dart:convert';

ReferralCodeModel referralCodeModelFromJson(String str) =>
    ReferralCodeModel.fromJson(json.decode(str));

String referralCodeModelToJson(ReferralCodeModel data) =>
    json.encode(data.toJson());

class ReferralCodeModel {
  bool? success;
  String? referralCode;
  String? referralLink;

  ReferralCodeModel({
    this.success,
    this.referralCode,
    this.referralLink,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) =>
      ReferralCodeModel(
        success: json["success"],
        referralCode: json["referral_code"],
        referralLink: json["referral_link"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "referral_code": referralCode,
        "referral_link": referralLink,
      };
}

ReferralStatsModel referralStatsModelFromJson(String str) =>
    ReferralStatsModel.fromJson(json.decode(str));

String referralStatsModelToJson(ReferralStatsModel data) =>
    json.encode(data.toJson());

class ReferralStatsModel {
  bool? success;
  int? totalInvites;
  int? completedInvites;
  int? pendingInvites;
  int? totalPointsEarned;

  ReferralStatsModel({
    this.success,
    this.totalInvites,
    this.completedInvites,
    this.pendingInvites,
    this.totalPointsEarned,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) =>
      ReferralStatsModel(
        success: json["success"],
        totalInvites: json["total_invites"],
        completedInvites: json["completed_invites"],
        pendingInvites: json["pending_invites"],
        totalPointsEarned: json["total_points_earned"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "total_invites": totalInvites,
        "completed_invites": completedInvites,
        "pending_invites": pendingInvites,
        "total_points_earned": totalPointsEarned,
      };
}

ReferralClaimModel referralClaimModelFromJson(String str) =>
    ReferralClaimModel.fromJson(json.decode(str));

String referralClaimModelToJson(ReferralClaimModel data) =>
    json.encode(data.toJson());

class ReferralClaimModel {
  bool? success;
  String? msg;

  ReferralClaimModel({
    this.success,
    this.msg,
  });

  factory ReferralClaimModel.fromJson(Map<String, dynamic> json) =>
      ReferralClaimModel(
        success: json["success"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "msg": msg,
      };
}
