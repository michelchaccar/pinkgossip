import 'package:flutter/material.dart';
import 'package:pinkGossip/theme/theme.dart';

enum PgButtonVariant { primary, secondary }

class PgButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PgButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const PgButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PgButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  const PgButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  }) : variant = PgButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == PgButtonVariant.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionPrimary,
                foregroundColor: AppColors.bgPrimary,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _buildChild(AppColors.bgPrimary),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.actionPrimary,
                side: const BorderSide(color: AppColors.actionPrimary),
                shape: const StadiumBorder(),
              ),
              child: _buildChild(AppColors.actionPrimary),
            ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.buttonText.copyWith(color: color)),
        ],
      );
    }

    return Text(label, style: AppTypography.buttonText.copyWith(color: color));
  }
}
