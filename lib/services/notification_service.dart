import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart'; 
import 'package:flutter_timezone/flutter_timezone.dart'; 

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; 

    tz.initializeTimeZones();

    try {
      // FIXED: Access the 'identifier' property or the name from the TimezoneInfo object
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

  // 2. Extract the string identifier (e.g., 'America/New_York')
      final String timeZoneName = timezoneInfo.identifier;

  // 3. Set the local location for the 'timezone' package
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint("Timezone detection failed, defaulting to UTC: $e");
    }

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/trackyourprogress');
        
    const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
    );
    
    await _notifications.initialize(settings);
    
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  // --- NEW: SCHEDULE AT SPECIFIC TIME (Repeats Daily) ---
  static Future<void> scheduleDailyTimeNotification(String trackId, String name, int hour, int minute) async {
    if (kIsWeb) return;

    int id = trackId.hashCode.abs();
    await _notifications.cancel(id); 

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      name,
      "Daily Check: How is your progress today?",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_time_reminders', 
          'Daily Time Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }

  // 1. RECURRING REMINDERS (Every 3 days, Week, etc)
  static Future<void> scheduleNotification(String trackId, String name, String frequency) async {
    if (kIsWeb) return;

    int id = trackId.hashCode.abs();
    await _notifications.cancel(id); 

    if (frequency == "None" || frequency == "Turn off") return;

    RepeatInterval? interval;
    if (frequency == "Every day") interval = RepeatInterval.daily;
    if (frequency == "Every week") interval = RepeatInterval.weekly;

    if (interval != null) {
      await _notifications.periodicallyShow(
        id,
        name,
        "Time to check your progress!",
        interval,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'track_reminders', 'Track Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      DateTime now = DateTime.now();
      DateTime scheduledDate;

      if (frequency == "Every 3 days") {
        scheduledDate = now.add(const Duration(days: 3));
      } else if (frequency == "Every 5 days") {
        scheduledDate = now.add(const Duration(days: 5));
      } else if (frequency == "Every month") {
        scheduledDate = DateTime(now.year, now.month + 1, now.day);
      } else if (frequency == "Every year") {
        scheduledDate = DateTime(now.year + 1, now.month, now.day);
      } else {
        scheduledDate = now.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id,
        name,
        "Reminder: How is your progress today?",
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('track_reminders', 'Track Reminders'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 2. EXPIRATION ALERT
  static Future<void> scheduleExpirationAlert(String trackId, String name, DateTime endDate) async {
    if (kIsWeb) return;

    try {
      int id = trackId.hashCode.abs() + 1000;
      await _notifications.cancel(id);

      DateTime notifyTime = endDate.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0, second: 0);
      final scheduledDate = tz.TZDateTime.from(notifyTime, tz.local);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _notifications.zonedSchedule(
        id,
        "$name Finished!",
        "The track period is over. See your accomplishments!",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_alerts', 'Track Expiry Alerts',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Schedule Error: $e");
    }
  }

  // 3. CANCEL Logic
  static Future<void> cancelAllForTrack(String trackId) async {
    if (kIsWeb) return;
    await _notifications.cancel(trackId.hashCode.abs());
    await _notifications.cancel(trackId.hashCode.abs() + 1000);
  }
}