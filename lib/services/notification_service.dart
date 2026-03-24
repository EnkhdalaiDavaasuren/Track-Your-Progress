import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(settings);
    
    // Request permission for Android 13+
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  }

  // Inside NotificationService class in lib/services/notification_service.dart

  static Future<void> scheduleExpirationAlert(String trackId, String name, DateTime endDate) async {
  // Use a different ID offset so it doesn't overwrite the daily reminders
  int id = trackId.hashCode.abs() + 1000; 

  // We schedule it for the morning (e.g., 9:00 AM) of the day AFTER it ends
  // so the user wakes up to the news.
  DateTime notifyTime = endDate.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0);
  
  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notifyTime, tz.local);

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
}
}