import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// INIT – call once from main()
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(settings);
  }

  /// 🔐 ANDROID 13+ PERMISSION (CORRECT METHOD)
  static Future<void> requestAndroidPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.requestNotificationsPermission();
  }

  /// 🔔 SCHEDULE NOTIFICATION
  static Future<void> scheduleNotification({
    required int id,
    required Duration delay,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'after_image_channel',
          'After Image Reminder',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      "Hey 👀",
      "Share your final photo and a short video of your transformation with us\nand win 100 points more 💄✨",
      tz.TZDateTime.now(tz.local).add(delay),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// ❌ CANCEL BOTH REMINDERS
  static Future<void> cancelAfterImageNotifications() async {
    await _notifications.cancel(1001);
    await _notifications.cancel(1002);
  }
}
