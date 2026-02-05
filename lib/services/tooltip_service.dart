import 'package:shared_preferences/shared_preferences.dart';

enum TooltipType {
  search,        // AppBar - SearchKey
  notification,  // AppBar - NotificationKey
  addStory,      // AppBar - AddStoryKey
  home,          // BottomNav home
  storeLocator,  // BottomNav storeLocator
  post,          // BottomNav post
  message,       // BottomNav message
  profile        // BottomNav profile
}

class TooltipService {
  // Check if a specific tooltip has been seen by the user
  Future<bool> hasSeenTooltip(String userId, TooltipType type) async {
    if (userId.isEmpty) return false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _getTooltipKey(userId, type);
    return prefs.getBool(key) ?? false;
  }

  // Mark a specific tooltip as seen for the user
  Future<void> markTooltipAsSeen(String userId, TooltipType type) async {
    if (userId.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _getTooltipKey(userId, type);
    await prefs.setBool(key, true);
  }

  // Reset all tooltips for the user (used when Tutorial is launched from Profile)
  Future<void> resetAllTooltips(String userId) async {
    if (userId.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Reset all 8 tooltips
    for (TooltipType type in TooltipType.values) {
      String key = _getTooltipKey(userId, type);
      await prefs.setBool(key, false);
    }
  }

  // Generate SharedPreferences key for a specific tooltip
  // Pattern: tooltip_seen_{type}_{userId}
  String _getTooltipKey(String userId, TooltipType type) {
    String typeStr = type.toString().split('.').last.toLowerCase();
    return 'tooltip_seen_${typeStr}_$userId';
  }
}
