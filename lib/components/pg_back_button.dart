import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinkGossip/theme/theme.dart';

/// Reusable back button for PinkGossip.
///
/// Default: pink rounded-square with white caretLeft icon.
/// Light variant: plain caretLeft icon in actionPrimary color (no background).
class PgBackButton extends StatelessWidget {
  final VoidCallback? onBack;
  final bool _isLight;

  const PgBackButton({super.key, this.onBack}) : _isLight = false;

  const PgBackButton.light({super.key, this.onBack}) : _isLight = true;

  @override
  Widget build(BuildContext context) {
    if (_isLight) {
      return IconButton(
        icon: const Icon(
          PhosphorIconsRegular.caretLeft,
          color: AppColors.actionPrimary,
          size: AppIconSize.lg,
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      );
    }

    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: AppColors.actionPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          PhosphorIconsBold.caretLeft,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
