import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allModels/message_chat.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/chat_provider.dart';
import 'package:ichat_app/allProviders/setting_provider.dart';
import 'package:ichat_app/allScreens/full_photo_page.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/allWidgets/overview_image.dart';
import 'package:ichat_app/allWidgets/overview_image_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String peerPushToken;

  const ChatPage(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.peerPushToken})
      : super(key: key);

  @override
  ChatPageState createState() => ChatPageState(
      peerId: peerId,
      peerAvatar: peerAvatar,
      peerNickname: peerNickname,
      peerPushToken: peerPushToken);
}

class ChatPageState extends State<ChatPage> {
  String peerId;
  String peerAvatar;
  String peerNickname;
  String peerPushToken;
  late String currentUserId;
  late String currentUserNickname;

  List<QueryDocumentSnapshot> listMessage = List.from([]);

  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  final Map<String, String> listSticker = {
    "mimi1": "images/mimi1.gif",
    "mimi2": "images/mimi2.gif",
    "mimi3": "images/mimi3.gif",
    "mimi4": "images/mimi4.gif",
    "mimi5": "images/mimi5.gif",
    "mimi6": "images/mimi6.gif",
    "mimi7": "images/mimi7.gif",
    "mimi8": "images/mimi8.gif",
    "mimi9": "images/mimi9.gif",
  };

  ChatPageState(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.peerPushToken});

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);

    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }
    if (currentUserId.hashCode <= peerId.hashCode) {
      groupChatId = "$currentUserId-$peerId";
    } else {
      groupChatId = "$peerId-$currentUserId";
    }
    currentUserNickname = chatProvider.getPref(FirestoreConstants.nickname)!;

    chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: peerId});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId,
          peerId, peerPushToken, currentUserNickname,
          index: listMessage.length + 1);
      listScrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Nothing to send", backgroundColor: ColorConstants.greyColor);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
          currentUserId, {FirestoreConstants.chattingWith: null});
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  void _callPhoneNumber(String callPhoneNumber) async {
    var url = 'tel://$callPhoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw ('Error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OverviewImage(
                photoUrl: peerAvatar,
                demoIcon: Icons.account_circle,
                width: 35,
                height: 35),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 175,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  peerNickname,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                SettingProvider settingProvider =
                    context.read<SettingProvider>();
                String callPhoneNumber =
                    settingProvider.getPref(FirestoreConstants.phoneNumber) ??
                        "";
                _callPhoneNumber(callPhoneNumber);
              },
              icon: const Icon(
                Icons.phone_iphone,
                size: 30,
              ))
        ],
      ),
      body: WillPopScope(
          child: Stack(
            children: [
              Column(
                children: [
                  buildListMessage(),
                  isShowSticker ? buildSticker() : const SizedBox.shrink(),
                  buildInput()
                ],
              ),
              buildLoading()
            ],
          ),
          onWillPop: onBackPress),
    );
  }

  Widget buildSticker() {
    return Expanded(
        child: Container(
      child: Scrollbar(
        isAlwaysShown: true,
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (_, index) => TextButton(
                onPressed: () => onSendMessage(
                    listSticker.entries.toList()[index].key,
                    TypeMessage.sticker),
                child: Image.asset(listSticker.entries.toList()[index].value)),
            itemCount: listSticker.entries.length),
      ),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
      padding: const EdgeInsets.all(5),
      height: 180,
    ));
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: [
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                onPressed: getImage,
                icon: const Icon(Icons.camera_enhance),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                onPressed: getSticker,
                icon: const Icon(Icons.face_retouching_natural),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
              child: SizedBox(
            child: TextField(
              controller: textEditingController,
              style: const TextStyle(
                  color: ColorConstants.primaryColor, fontSize: 15),
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor)),
              focusNode: focusNode,
            ),
          )),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () =>
                    onSendMessage(textEditingController.text, TypeMessage.text),
                icon: const Icon(Icons.send),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
        child: groupChatId.isNotEmpty
            ? StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(groupChatId, _limit),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    listMessage = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data!.docs[index]),
                      itemCount: snapshot.data!.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorConstants.themeColor,
                      ),
                    );
                  }
                },
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.themeColor,
                ),
              ));
  }

  Widget buildItem(int index, DocumentSnapshot? doc) {
    if (doc != null) {
      MessageChat messageChat = MessageChat.fromDocument(doc);
      if (messageChat.idFrom == currentUserId) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            messageChat.type == TypeMessage.text
                ? Container(
                    child: Text(
                      messageChat.content,
                      style:
                          const TextStyle(color: ColorConstants.primaryColor),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: ColorConstants.greyColor2,
                        borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                  )
                : messageChat.type == TypeMessage.image
                    ? SizedBox(
                        child: OutlinedButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(0))),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                          url: messageChat.content)));
                            },
                            child: Material(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              clipBehavior: Clip.hardEdge,
                              child: OverviewImageChat(
                                  photoUrl: messageChat.content,
                                  demoImage: "images/img_not_available.jpeg",
                                  width: 200,
                                  height: 200),
                            )),
                      )
                    : Container(
                        child: Image.asset(
                          "images/${messageChat.content}.gif",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                      )
          ],
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  isLastMessageLeft(index)
                      ? Material(
                          child: OverviewImage(
                              photoUrl: peerAvatar,
                              demoIcon: Icons.account_circle,
                              width: 35,
                              height: 35),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                        )
                      : Container(
                          width: 35,
                        ),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          width: 200,
                          decoration: BoxDecoration(
                              color: ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(left: 10),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              child: OutlinedButton(
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(0))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhotoPage(
                                                url: messageChat.content)));
                                  },
                                  child: Material(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    clipBehavior: Clip.hardEdge,
                                    child: OverviewImageChat(
                                        photoUrl: messageChat.content,
                                        demoImage:
                                            "images/img_not_available.jpeg",
                                        width: 200,
                                        height: 200),
                                  )),
                            )
                          : Container(
                              child: Image.asset(
                                "images/${messageChat.content}.gif",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                            )
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(
                            DateTime.fromMicrosecondsSinceEpoch(
                                int.parse(messageChat.timestamp))),
                        style: const TextStyle(
                          color: ColorConstants.greyColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      margin:
                          const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    )
                  : const SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildLoading() {
    return Positioned(
        child: isLoading ? LoadingView() : const SizedBox.shrink());
  }
}
