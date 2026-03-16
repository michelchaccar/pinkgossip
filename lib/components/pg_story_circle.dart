import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinkGossip/theme/theme.dart';

/// Story circle states matching the Figma design system.
enum StoryCircleState {
  /// "Your Story" with no existing story — gray bg + pink "+" icon
  addStory,

  /// "Your Story" with existing stories — gradient border + profile image
  myStory,

  /// Other user's unseen story — pink gradient border
  unseen,

  /// Other user's already-viewed story — gray border
  seen,
}

class PgStoryCircle extends StatelessWidget {
  final StoryCircleState state;
  final ImageProvider? image;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final GlobalKey? addKey;
  final double size;

  const PgStoryCircle({
    super.key,
    required this.state,
    this.image,
    required this.label,
    this.onTap,
    this.onAddTap,
    this.addKey,
    this.size = 58,
  });

  static const _borderWidth = 2.0;
  static const _gapWidth = 2.0;

  static const _gradientUnseen = LinearGradient(
    colors: [Color(0xFFFE2AAE), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _borderSeen = Color(0xFFE5E7EB);
  static const _addBgColor = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircle(),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A5565),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle() {
    switch (state) {
      case StoryCircleState.addStory:
        return _buildAddStory();
      case StoryCircleState.myStory:
        return _buildBorderedAvatar(hasGradient: true, showAddButton: true);
      case StoryCircleState.unseen:
        return _buildBorderedAvatar(hasGradient: true);
      case StoryCircleState.seen:
        return _buildBorderedAvatar(hasGradient: false);
    }
  }

  /// Gray circle with pink "+" icon — no profile image
  Widget _buildAddStory() {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(_borderWidth),
      child: Container(
        padding: const EdgeInsets.all(_gapWidth),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: _addBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.actionPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                key: addKey,
                LucideIcons.plus,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Avatar with gradient (unseen) or gray (seen) border
  Widget _buildBorderedAvatar({
    required bool hasGradient,
    bool showAddButton = false,
  }) {
    final imageRadius = (size - (_borderWidth + _gapWidth) * 2) / 2;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasGradient ? _gradientUnseen : null,
        color: hasGradient ? null : _borderSeen,
      ),
      padding: const EdgeInsets.all(_borderWidth),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(_gapWidth),
        child: CircleAvatar(
          radius: imageRadius,
          backgroundColor: _addBgColor,
          backgroundImage: image,
        ),
      ),
    );

    if (!showAddButton || onAddTap == null) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onAddTap,
            child: Container(
              key: addKey,
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.actionPrimary,
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
