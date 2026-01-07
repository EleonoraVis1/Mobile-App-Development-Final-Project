
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static String _mapToIana(String tzName) {
    const windowsToIana = {
      "Pacific Standard Time": "America/Los_Angeles",
      "Mountain Standard Time": "America/Denver",
      "Central Standard Time": "America/Chicago",
      "Eastern Standard Time": "America/New_York",
      "GMT Standard Time": "Europe/London",
      "W. Europe Standard Time": "Europe/Berlin",
      "Tokyo Standard Time": "Asia/Tokyo",
      "India Standard Time": "Asia/Kolkata",
    };

    return windowsToIana[tzName] ?? tzName; 
  }

  static Future<void> init() async {
    tz.initializeTimeZones();
    String timezone = '';
    final deviceTz = await FlutterTimezone.getLocalTimezone();
    if (deviceTz.localizedName != null)
      timezone = deviceTz.localizedName!.name;

    final String ianaTz = _mapToIana(timezone);
    
    tz.setLocalLocation(tz.getLocation(ianaTz));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> requestPermissions() async {
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      hour * 100 + minute, // unique ID
      'Daily Reminder 🏃‍♂️',
      'Time for your run!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Workout Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
