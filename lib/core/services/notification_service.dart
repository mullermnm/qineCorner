import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  Future<void> scheduleReadingGoalReminder({
    required String time,
    required int dailyMinutes,
  }) async {
    try {
      int hour = 20;
      int minute = 0;

      try {
        final timeParts = time.split(':');
        if (timeParts.length == 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
        }
      } catch (e) {
        print('Error parsing notification time: $e');
        // Default to 8 PM if parsing fails
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'reading_goals',
        'Reading Goals',
        channelDescription: 'Notifications for daily reading goals',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // First cancel any existing notifications
      await _notifications.cancel(0);

      try {
        // Try exact scheduling first
        await _notifications.zonedSchedule(
          0,
          'Time to Read! 📚',
          'Your goal is to read for $dailyMinutes minutes today.',
          tz.TZDateTime.from(scheduledDate, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        print('Scheduled exact notification for $scheduledDate');
      } catch (e) {
        print('Failed to schedule exact notification: $e');
        print('Falling back to inexact scheduling');
        
        // Fallback to inexact scheduling
        await _notifications.zonedSchedule(
          0,
          'Time to Read! 📚',
          'Your goal is to read for $dailyMinutes minutes today.',
          tz.TZDateTime.from(scheduledDate, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      print('Error in scheduleReadingGoalReminder: $e');
      // Don't rethrow to prevent breaking the goal saving flow
    }
  }

  Future<void> showGoalCompletedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'reading_goals',
      'Reading Goals',
      channelDescription: 'Notifications for daily reading goals',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Congratulations! 🎉',
      'You\'ve reached your daily reading goal!',
      details,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
