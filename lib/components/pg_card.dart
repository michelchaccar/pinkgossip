import 'package:flutter/material.dart';
import 'package:pinkGossip/theme/theme.dart';

class PgCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PgCard({
    super.key,
    this.title,
    this.description,
    this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: child ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(title!, style: AppTypography.heading3),
                if (title != null && description != null)
                  const SizedBox(height: AppSpacing.xs),
                if (description != null)
                  Text(
                    description!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}
