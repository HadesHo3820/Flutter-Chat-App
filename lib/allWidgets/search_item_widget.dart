import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:ichat_app/allScreens/chat_page.dart';
import 'package:ichat_app/allWidgets/overview_image_widget.dart';
import 'package:ichat_app/utilities/utilities.dart';

Widget SearchItems(BuildContext context, DocumentSnapshot documentSnapshot,
    String currentUserId) {
  if (documentSnapshot != null) {
    UserChat userChat = UserChat.fromDocument(documentSnapshot);
    if (userChat.id == currentUserId) {
      return const SizedBox.shrink();
    } else {
      String peerPushToken =
          documentSnapshot.get(FirestoreConstants.pushToken) ?? "";
      return Container(
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey.withOpacity(0.3)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))))),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            peerId: userChat.id,
                            peerAvatar: userChat.photoUrl,
                            peerNickname: userChat.nickname,
                            peerPushToken: peerPushToken,
                          )));
            },
            child: Row(
              children: [
                OverviewImage(
                    photoUrl: userChat.photoUrl,
                    demoIcon: Icons.account_circle,
                    width: 50,
                    height: 50),
                Flexible(
                    child: Container(
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          userChat.nickname,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          userChat.aboutMe,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  margin: const EdgeInsets.only(left: 20),
                ))
              ],
            )),
      );
    }
  } else {
    return const SizedBox.shrink();
  }
}
