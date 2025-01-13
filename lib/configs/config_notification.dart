import 'dart:async';
import 'dart:developer';

import 'package:bigbox/configs/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class ConfigNotification {
  get onDidReceiveLocalNotification => null;

  Future initialise() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
      criticalAlert: false,
      provisional: false,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // await FirebaseMessaging.instance.subscribeToTopic("all");

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        log('TERMINATED');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // log("onMessage: ${message.toMap()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String id =
          message.data['id'] == null ? '0' : '${(message.data['id'] ?? 0)}';
      if (int.parse(id) > 0) {
        Get.toNamed(
          '/order-detail',
          arguments: [
            int.parse(id),
            null,
          ],
        );
      } else {
        Get.toNamed('/notifications');
      }
    });
    await Future.delayed(const Duration(seconds: 1));
    try {
      deviceId = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (err) {}
  }
}
