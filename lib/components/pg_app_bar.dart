import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinkGossip/theme/theme.dart';
import 'package:pinkGossip/utils/imagesutils.dart';

/// Reusable AppBar component for PinkGossip.
///
/// Two modes:
/// - **Logo mode**: set [useLogo] to true. Shows the app logo on the left
///   and [actions] on the right. Used by Home, Message, Makeup screens.
/// - **Title mode** (default): Shows a back button + centered [title]
///   and optional [actions] on the right.
class PgAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool useLogo;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? leading;

  const PgAppBar({
    super.key,
    this.title,
    this.useLogo = false,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
    this.leading,
  });

  /// Convenience constructor for screens with logo + action icons (Home, Message, etc.)
  const PgAppBar.logo({
    super.key,
    this.actions = const [],
  })  : title = null,
        useLogo = true,
        showBack = false,
        onBack = null,
        leading = null;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.bgPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: !useLogo,
      leading: _buildLeading(context),
      title: useLogo
          ? SizedBox(height: 50, child: Image.asset(ImageUtils.appbarlogo))
          : title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                )
              : null,
      actions: [
        ...actions,
        if (actions.isNotEmpty) const SizedBox(width: 8),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBack || useLogo) return null;
    return IconButton(
      icon: const Icon(
        LucideIcons.chevronLeft,
        color: AppColors.actionPrimary,
        size: AppIconSize.lg,
      ),
      onPressed: onBack ?? () => Navigator.of(context).pop(),
    );
  }
}

/// A pre-styled icon button for use in [PgAppBar.actions].
class PgAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final GlobalKey? iconKey;
  final double size;

  const PgAppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconKey,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(AppColors.bgPrimary),
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          key: iconKey,
          icon,
          color: AppColors.actionPrimary,
          size: size,
        ),
      ),
    );
  }
}
