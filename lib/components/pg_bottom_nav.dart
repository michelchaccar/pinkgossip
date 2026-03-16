import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinkGossip/theme/theme.dart';

class PgBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final GlobalKey? key;

  const PgBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.key,
  });
}

class PgBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PgBottomNavItem> items;

  const PgBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static List<PgBottomNavItem> defaultItems({
    GlobalKey? homeKey,
    GlobalKey? makeupKey,
    GlobalKey? postKey,
    GlobalKey? messageKey,
    GlobalKey? profileKey,
  }) {
    return [
      PgBottomNavItem(
        icon: PhosphorIconsRegular.house,
        activeIcon: PhosphorIconsFill.house,
        label: 'Home',
        key: homeKey,
      ),
      PgBottomNavItem(
        icon: PhosphorIconsRegular.mapTrifold,
        activeIcon: PhosphorIconsFill.mapTrifold,
        label: 'Makeup',
        key: makeupKey,
      ),
      PgBottomNavItem(
        icon: PhosphorIconsRegular.plusCircle,
        activeIcon: PhosphorIconsFill.plusCircle,
        label: 'Post',
        key: postKey,
      ),
      PgBottomNavItem(
        icon: PhosphorIconsRegular.chatCircle,
        activeIcon: PhosphorIconsFill.chatCircle,
        label: 'Message',
        key: messageKey,
      ),
      PgBottomNavItem(
        icon: PhosphorIconsRegular.user,
        activeIcon: PhosphorIconsFill.user,
        label: 'Profile',
        key: profileKey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.actionPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          Widget iconWidget = Icon(
            isActive ? (item.activeIcon ?? item.icon) : item.icon,
            color: Colors.white,
            size: AppIconSize.lg,
          );

          if (item.key != null) {
            iconWidget = KeyedSubtree(
              key: item.key,
              child: iconWidget,
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  const SizedBox(height: 6),
                  if (isActive)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
