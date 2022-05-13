import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotificationHandler {
  static final _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future initLocalNotification() async {
    var initAndroid =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initIOS = const IOSInitializationSettings();
    final initSettings =
        InitializationSettings(android: initAndroid, iOS: initIOS);

    //when app is closed
    final details =
        await _flutterLocalNotificationPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(details.payload);
    }

    await _flutterLocalNotificationPlugin.initialize(
      initSettings,
      onSelectNotification: (payload) {
        if (payload != null) onNotification.add(payload);
      },
    );
  }

  static Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails("com.example.ichat_app", "iChat_App",
            channelDescription: 'channel description',
            playSound: true,
            enableVibration: true,
            ongoing: true,
            priority: Priority.high,
            importance: Importance.max);
    IOSNotificationDetails iosNotificationDetails =
        const IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await _flutterLocalNotificationPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }
}
