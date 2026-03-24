import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Initialization: Call this in main()
  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    
    await _notifications.initialize(settings);
    
    // Request permission for Android 13+
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  // 1. RECURRING REMINDERS: "Every day", "Every week", etc.
  static Future<void> scheduleNotification(String trackId, String name, String frequency) async {
    int id = trackId.hashCode.abs();

    // Cancel old one first
    await _notifications.cancel(id);

    if (frequency == "None") return;

    RepeatInterval interval = RepeatInterval.daily;
    if (frequency == "Every week") interval = RepeatInterval.weekly;
    // Note: Local notifications usually support Daily/Weekly natively. 
    // "Every 3 days" would require custom logic, so we default to Daily for simplicity.

    await _notifications.periodicallyShow(
      id,
      name,
      "Check Your days",
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
  }

  // 2. EXPIRATION ALERT: Sent once the range is finished
  static Future<void> scheduleExpirationAlert(String trackId, String name, DateTime endDate) async {
    try {
      int id = trackId.hashCode.abs() + 1000;

      // Schedule for 9:00 AM the day after it ends
      DateTime notifyTime = endDate.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0);
      
      // SAFETY: If timezone fails, we fallback to a simpler notification or just skip
      final scheduledDate = tz.TZDateTime.from(notifyTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        "$name Finished!",
        "Your tracking period has ended. Check your accomplishments!",
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
      print("Could not schedule notification: $e");
    }
  }
}