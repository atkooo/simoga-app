// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class NotificationWidget extends StatelessWidget {
  final String title;
  final String message;

  const NotificationWidget(
      {super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
      ),
    );
  }
}

void showNotification(BuildContext context, String title, String message) {
  showOverlayNotification(
    (context) {
      return NotificationWidget(
        title: title,
        message: message,
      );
    },
    duration: Duration(seconds: 3),
  );
}

int _notificationId = 0;

Future<void> setupNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {},
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id',
    'your_channel_name',
    description: 'your_channel_description',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await requestNotificationPermissions();

  await scheduleDailyNotification(flutterLocalNotificationsPlugin,
      'Breakfast Time', 'It\'s time for breakfast!', 3, 18);
  await scheduleDailyNotification(flutterLocalNotificationsPlugin, 'Lunch Time',
      'It\'s time for lunch!', 3, 18);
  await scheduleDailyNotification(flutterLocalNotificationsPlugin,
      'Dinner Time', 'It\'s time for dinner!', 18, 0);

  await scheduleNearFutureNotification();
  await showImmediateNotification();
  await checkPendingNotifications();
}

Future<void> requestNotificationPermissions() async {
  if (await Permission.notification.status.isDenied) {
    final status = await Permission.notification.request();
  }

  if (Platform.isAndroid &&
      (await Permission.scheduleExactAlarm.status.isDenied)) {
    final status = await Permission.scheduleExactAlarm.request();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    final bool? granted =
        await androidImplementation.requestNotificationsPermission();
  }
}

Future<void> scheduleNearFutureNotification() async {
  if (Platform.isAndroid && !await Permission.scheduleExactAlarm.isGranted) {
    return;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  final scheduledDate = now.add(const Duration(minutes: 1));

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,
      'Near-future Notification',
      'This should appear in 2 minutes',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notif'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  } catch (e) {}
}

Future<void> scheduleDailyNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String title,
    String body,
    int hour,
    int minute) async {
  if (Platform.isAndroid && !await Permission.scheduleExactAlarm.isGranted) {
    return;
  }

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notif'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (e) {}
}

Future<void> showImmediateNotification() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '_id',
    '_name',
    channelDescription: 'description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  try {
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      'Waktu Makan Siang',
      'waktunya mencatat makanan siang anak',
      platformChannelSpecifics,
    );
  } catch (e) {}
}

Future<void> checkPendingNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<PendingNotificationRequest> pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  for (var notification in pendingNotifications) {}
}
