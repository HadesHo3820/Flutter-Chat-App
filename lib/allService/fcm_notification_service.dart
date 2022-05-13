import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

abstract class IFCMNotificationService {
  Future<void> sendNotificationToUser(
      {required String fcmToken, required String title, required String body});

  Future<void> sendNotificationToTopic(
      {required String group, required String title, required String body});

  Future<void> unsubscribeFromTopic({required String topic});

  Future<void> subscribeToTopic({required String topic});
}

class FCMNotificationService extends IFCMNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _endPoint = "https://fcm.googleapis.com/fcm/send";
  final String _contentType = "application/json";

  //authorization with key is Server key
  final String _authorization =
      "key=AAAAHBHflTo:APA91bEDvUDrnwh4059uoL8er7R6j15cEBOdDkn4WHA-amk-ff9cQWRtCxXRHdnA6-FSMSLy7cHyVxRytlaXiVmoiKEJp3O2m8kt6fp9xtybFRIOLKEvRUXnv0lkvI_KeRtqBgY-yX9U";

  Future<http.Response> _sendNotification(
      String to, String title, String body) async {
    try {
      final dynamic data = json.encode({
        'to': to,
        'priority': 'high',
        'notification': {'title': title, 'body': body},
        'data': {'title': title, 'body': body, 'payload': 'this is payload'},
        'content_available': true
      });

      http.Response response = await http.post(Uri.parse(_endPoint),
          body: data,
          headers: {
            'Content-Type': _contentType,
            'Authorization': _authorization
          });

      return response;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<void> sendNotificationToTopic(
      {required String group, required String title, required String body}) {
    return _sendNotification('/topics/' + group, title, body);
  }

  @override
  Future<void> sendNotificationToUser(
      {required String fcmToken, required String title, required String body}) {
    return _sendNotification(fcmToken, title, body);
  }

  @override
  Future<void> subscribeToTopic({required String topic}) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic({required String topic}) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
