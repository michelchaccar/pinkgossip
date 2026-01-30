class RewardTemplateModel {
  final int id;
  final String rewardType;
  final String rewardDesc;
  final String rewardImage;
  final String createdAt;
  final String? deletedAt;

  RewardTemplateModel({
    required this.id,
    required this.rewardType,
    required this.rewardDesc,
    required this.rewardImage,
    required this.createdAt,
    this.deletedAt,
  });

  factory RewardTemplateModel.fromJson(Map<String, dynamic> json) {
    return RewardTemplateModel(
      id: json['id'],
      rewardType: json['reward_type'] ?? '',
      rewardDesc: json['reward_desc'] ?? '',
      rewardImage: json['reward_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}
