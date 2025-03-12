import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings
    );
  }

  Future<void> scheduleNotification(DateTime selectedTime) async {

   bool isNotificationPermissionEnabled = await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
   bool isExactAlarmPermissionEnabled = await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission() ?? false;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(selectedTime, tz.local);

    bool shouldScheduleNotification = false;

    if(Platform.isAndroid) {
      shouldScheduleNotification = isNotificationPermissionEnabled && isExactAlarmPermissionEnabled;
    } else if(Platform.isIOS) {
      shouldScheduleNotification = true;
    }

    if(shouldScheduleNotification) {
      try {
        await _notificationsPlugin.zonedSchedule(
          0,
          "notification title",
          "notification body",
          scheduledTime,
          _notificationDetails(),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
              .absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exact,
        );

        debugPrint('Notification scheduled successfully');
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
    }
  }

  Future<void> cancelNotification(int notificationId) async {

    try {
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('Notification Canceled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription : 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

}