import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // All methods in flutter_local_notifications v21 use named parameters
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> showQuestAcceptedNotification(String questTitle) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quest_creation_channel',
      'Quest Creation',
      channelDescription: 'Notifications for new quest acceptance',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      id: questTitle.hashCode,
      title: 'Quest Accepted!',
      body: 'You have embarked on: $questTitle',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> scheduleQuestDeadline(
      String questId, String questTitle, DateTime deadline) async {
    if (deadline.isBefore(DateTime.now())) return;

    final int idCode = questId.hashCode;

    // Helper for scheduling with exact alarm fallback
    Future<void> safeSchedule(int id, String title, String body, DateTime date) async {
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(date, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'quest_deadline_channel',
              'Quest Deadlines',
              channelDescription: 'Notifications for quest deadlines',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        // Fallback for Android 13+ if exact alarms are not permitted
        debugPrint('Exact alarm failed, falling back to inexact: $e');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(date, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'quest_deadline_channel',
              'Quest Deadlines',
              channelDescription: 'Notifications for quest deadlines',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    // 1. Notification at exact deadline
    await safeSchedule(idCode, 'Quest Failed: HP Damage!', 'You missed the deadline for $questTitle.', deadline);

    // 2. Notification 5 minutes before deadline
    final fiveMinBefore = deadline.subtract(const Duration(minutes: 5));
    if (fiveMinBefore.isAfter(DateTime.now())) {
      await safeSchedule(idCode + 1, 'Quest Reminder', '$questTitle expires in 5 minutes!', fiveMinBefore);
    }
  }

  Future<void> cancelQuestDeadline(String questId) async {
    final int idCode = questId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(id: idCode);
    await _flutterLocalNotificationsPlugin.cancel(id: idCode + 1);
  }
}
