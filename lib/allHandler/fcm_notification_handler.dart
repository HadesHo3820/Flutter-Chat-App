import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allHandler/local_notification_handler.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:ichat_app/allService/fcm_notification_service.dart';
import 'package:provider/provider.dart';

class FcmNotification {
  late final FirebaseMessaging _firebaseMessaging;
  final FCMNotificationService _fcmNotificationService =
      FCMNotificationService();
  AuthProvider authProvider;
  HomeProvider homeProvider;

  FcmNotification({required this.authProvider, required this.homeProvider});

  void setupFCM() {
    _firebaseMessaging = FirebaseMessaging.instance;
    LocalNotificationHandler.initLocalNotification();
    fcmListener();
  }

  Future<void> fcmListener() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //Fetch the fcm token for this device
      _firebaseMessaging.getToken().then((token) {
        if (token != null) {
          //Save user fcm token to Firestore DB
          String currentUserId = authProvider.getUserFirebaseId()!;
          homeProvider.updateDataFirestore(
              FirestoreConstants.pathUserCollection,
              currentUserId,
              {'pushToken': token});
        }
      }).catchError((error) {
        Fluttertoast.showToast(msg: error.toString());
      });
    }

    //Subscribe to Topic
    _fcmNotificationService.subscribeToTopic(topic: 'NEWS');

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      if (Platform.isAndroid) {
        LocalNotificationHandler.showNotification(
            title: remoteMessage.data['title'],
            body: remoteMessage.data['body'],
            payload: 'OnMessage Android ${remoteMessage.data['payload']}');
      } else if (Platform.isIOS) {
        LocalNotificationHandler.showNotification(
            title: remoteMessage.notification!.title,
            body: remoteMessage.notification!.body,
            payload: "OnMessage IOS ${remoteMessage.data['payload']}");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      if (Platform.isAndroid) {
        LocalNotificationHandler.showNotification(
            title: remoteMessage.data['title'],
            body: remoteMessage.data['body'],
            payload:
                'OnMessageOpenApp Android ${remoteMessage.data['payload']}');
      } else if (Platform.isIOS) {
        LocalNotificationHandler.showNotification(
            title: remoteMessage.notification!.title,
            body: remoteMessage.notification!.body,
            payload: "OnMessageOpenApp IOS ${remoteMessage.data['payload']}");
      }
    });
  }
}
