import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinkGossip/theme/theme.dart';

class PgInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool showSearchIcon;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const PgInput({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.showSearchIcon = false,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  });

  const PgInput.search({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  }) : showSearchIcon = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.input,
        filled: true,
        fillColor: AppColors.bgPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        prefixIcon: showSearchIcon
            ? const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  LucideIcons.search,
                  size: AppIconSize.md,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        prefixIconConstraints: showSearchIcon
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(
            color: AppColors.actionPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
