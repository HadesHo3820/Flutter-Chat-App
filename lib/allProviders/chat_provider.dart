import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allModels/message_chat.dart';
import 'package:ichat_app/allService/fcm_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.prefs,
      required this.firebaseFirestore,
      required this.firebaseStorage});

  UploadTask uploadFile(File imageFile, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.index, descending: true)
        .limit(limit)
        .snapshots();
  }

  //        .limit(limit)

  String? getPref(String key) {
    return prefs.getString(key);
  }

  void sendMessage(
      String content,
      int type,
      String groupChatId,
      String currentUserId,
      String peerId,
      String peerPushToken,
      String currentUserNickname,
      {int index = 0}) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().microsecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        type: type,
        index: index);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, messageChat.toJson());
    });

    FCMNotificationService fcmNotificationService = FCMNotificationService();
    String typeSend = "";
    switch (type) {
      case 0:
        typeSend = content;
        break;
      case 1:
        typeSend = "$currentUserNickname sends you an image";
        break;
      case 2:
        typeSend = "$currentUserNickname sends you a sticker";
        break;
    }
    fcmNotificationService.sendNotificationToUser(
        fcmToken: peerPushToken,
        title: "You have a message from $currentUserNickname",
        body: typeSend);
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
