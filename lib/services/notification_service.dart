import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart'; // For kIsWeb check

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; // Notifications don't work this way on Web

    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    
    await _notifications.initialize(settings);
    
    // Request permissions for Android 13+
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  // 1. RECURRING REMINDERS: Handles "Every day", "3 days", "Week", "Month"
  static Future<void> scheduleNotification(String trackId, String name, String frequency) async {
    if (kIsWeb) return;

    int id = trackId.hashCode.abs();
    await _notifications.cancel(id); // Clear old schedule

    if (frequency == "None" || frequency == "Turn off") return;

    // Logic: Map your UI strings to actual intervals
    RepeatInterval? interval;
    if (frequency == "Every day") interval = RepeatInterval.daily;
    if (frequency == "Every week") interval = RepeatInterval.weekly;

    if (interval != null) {
      // Use standard periodic logic for Daily/Weekly
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      // For "Every 3 days", "Month", etc., we schedule a single Zoned notification
      // because standard 'periodic' doesn't support these intervals.
      DateTime now = DateTime.now();
      DateTime scheduledDate;

      if (frequency == "Every 3 days") scheduledDate = now.add(const Duration(days: 3));
      else if (frequency == "Every 5 days") scheduledDate = now.add(const Duration(days: 5));
      else if (frequency == "Every month") scheduledDate = DateTime(now.year, now.month + 1, now.day);
      else if (frequency == "Every year") scheduledDate = DateTime(now.year + 1, now.month, now.day);
      else scheduledDate = now.add(const Duration(days: 1));

      await _notifications.zonedSchedule(
        id,
        name,
        "Reminder: How is your progress today?",
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('track_reminders', 'Track Reminders'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 2. EXPIRATION ALERT: Logic to prevent "Past Date" crashes
  static Future<void> scheduleExpirationAlert(String trackId, String name, DateTime endDate) async {
    if (kIsWeb) return;

    try {
      int id = trackId.hashCode.abs() + 1000;
      await _notifications.cancel(id);

      // Notify at 9:00 AM the day after it ends
      DateTime notifyTime = endDate.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0, second: 0);
      
      final scheduledDate = tz.TZDateTime.from(notifyTime, tz.local);

      // --- CRITICAL FIX: DO NOT SCHEDULE IF DATE IS IN THE PAST ---
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print("Notification skipped: $name is already finished.");
        return;
      }

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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print("Schedule Error: $e");
    }
  }

  // 3. CANCEL Logic
  static Future<void> cancelAllForTrack(String trackId) async {
    if (kIsWeb) return;
    await _notifications.cancel(trackId.hashCode.abs());
    await _notifications.cancel(trackId.hashCode.abs() + 1000);
  }
}