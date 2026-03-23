import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinkGossip/components/pg_story_circle.dart';
import 'package:pinkGossip/theme/theme.dart';

class PgPostHeader extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final String? subtitle;
  final double? rating;
  final int? ratingCount;
  final bool hasStory;
  final VoidCallback? onTap;
  final VoidCallback? onStoryTap;
  final PopupMenuButton? moreMenu;

  const PgPostHeader({
    super.key,
    this.imageUrl,
    required this.username,
    this.subtitle,
    this.rating,
    this.ratingCount,
    this.hasStory = false,
    this.onTap,
    this.onStoryTap,
    this.moreMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        GestureDetector(
          onTap: onStoryTap ?? onTap,
          child: PgStoryCircle(
            state: hasStory ? StoryCircleState.unseen : StoryCircleState.seen,
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            label: '',
            size: 40,
          ),
        ),
        const SizedBox(width: 5),
        // Text content
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  username,
                  style: AppTypography.bodySemiBold.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  Text(
                    subtitle!,
                    style: AppTypography.captionMedium.copyWith(
                      color: const Color(0xFF4A5565),
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(height: 3),
                  _buildRatingRow(),
                ],
              ],
            ),
          ),
        ),
        // More button
        if (moreMenu != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: moreMenu!,
          ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final filledCount = (rating ?? 0).round();
          return Icon(
            PhosphorIconsRegular.star,
            size: 13,
            color: index < filledCount
                ? AppColors.actionPrimary
                : const Color(0xFFD1D5DB),
          );
        }),
        if (ratingCount != null)
          Text(
            ' ($ratingCount)',
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.actionPrimary,
            ),
          ),
      ],
    );
  }
}
