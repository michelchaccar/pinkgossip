import 'package:flutter/material.dart';
import 'package:pinkGossip/theme/theme.dart';

enum PgBadgeVariant { success, info, warning, error }

class PgBadge extends StatelessWidget {
  final String label;
  final PgBadgeVariant variant;

  const PgBadge({
    super.key,
    required this.label,
    this.variant = PgBadgeVariant.info,
  });

  const PgBadge.success({super.key, required this.label})
      : variant = PgBadgeVariant.success;

  const PgBadge.info({super.key, required this.label})
      : variant = PgBadgeVariant.info;

  const PgBadge.warning({super.key, required this.label})
      : variant = PgBadgeVariant.warning;

  const PgBadge.error({super.key, required this.label})
      : variant = PgBadgeVariant.error;

  Color get _bgColor {
    switch (variant) {
      case PgBadgeVariant.success:
        return AppColors.success.withValues(alpha: 0.1);
      case PgBadgeVariant.info:
        return AppColors.info.withValues(alpha: 0.1);
      case PgBadgeVariant.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case PgBadgeVariant.error:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  Color get _textColor {
    switch (variant) {
      case PgBadgeVariant.success:
        return AppColors.success;
      case PgBadgeVariant.info:
        return AppColors.info;
      case PgBadgeVariant.warning:
        return AppColors.warning;
      case PgBadgeVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        label,
        style: AppTypography.captionMedium.copyWith(color: _textColor),
      ),
    );
  }
}
