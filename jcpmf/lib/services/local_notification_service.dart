import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNotificationService {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    // #1
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSetting = IOSInitializationSettings();

    // #2
    const initSettings = InitializationSettings(
        android: androidSetting, iOS: /* iosSetting */ null);

    // #3
    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  Future<void> addNotification(
    String title,
    String body,
    int endTime, {
    String sound = '',
    String channel = 'default',
  }) async {
    // #1
    tzData.initializeTimeZones();
    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);

// #2
    final androidDetail = AndroidNotificationDetails(
        channel, // channel Id
        channel // channel Name
        );

    // final iosDetail = IOSNotificationDetails();

    final noticeDetail = NotificationDetails(
      // iOS: iosDetail,
      android: androidDetail,
    );

// #3
    final id = 0;

// #4
    await _localNotificationsPlugin.show(id, title, body, noticeDetail);

    // await _localNotificationsPlugin.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   scheduleTime,
    //   noticeDetail,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   androidAllowWhileIdle: true,
    // );
  }
}
