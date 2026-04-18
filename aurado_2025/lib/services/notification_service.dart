import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);
    tz.initializeTimeZones();
  }

  // Task ke liye scheduled notification
  static Future<void> scheduleTaskNotification({
    required int id,
    required String taskTitle,
    required DateTime dueDateTime,
    required int minutesBefore,
  }) async {
    final scheduledTime = dueDateTime.subtract(Duration(minutes: minutesBefore));

    print('⏰ Scheduling notification for: $scheduledTime');
    print('⏰ Current time: ${DateTime.now()}');

    if (scheduledTime.isBefore(DateTime.now())) {
      print('❌ Scheduled time is in the past! Not scheduling.');
      return;
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      '⏰ Task Reminder',
      '$taskTitle is due in $minutesBefore minutes!',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Reminders for your tasks',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('✅ Notification scheduled successfully!');
  }

  // Missed task notification
  static Future<void> showMissedTaskNotification({
    required int id,
    required String taskTitle,
  }) async {
    await _notifications.show(
      id,
      '❌ Missed Task',
      'You missed: $taskTitle',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'missed_channel',
          'Missed Tasks',
          channelDescription: 'Notifications for missed tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Daily summary notification
  static Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
    required String summaryText,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      999,
      '📋 Daily Task Summary',
      summaryText,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'summary_channel',
          'Daily Summary',
          channelDescription: 'Your daily task overview',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact, // ✅ yeh add karo
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}