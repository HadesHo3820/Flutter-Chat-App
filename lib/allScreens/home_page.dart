import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allHandler/fcm_notification_handler.dart';
import 'package:ichat_app/allHandler/local_notification_handler.dart';
import 'package:ichat_app/allModels/popup_choices.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:ichat_app/allProviders/theme_provider.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/allScreens/second_page.dart';
import 'package:ichat_app/allWidgets/change_theme_button_widget.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/allWidgets/navigation_drawer_widget.dart';
import 'package:ichat_app/allWidgets/search_bar_widget.dart';
import 'package:ichat_app/allWidgets/search_item_widget.dart';
import 'package:ichat_app/utilities/debouncer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late AuthProvider authProvider;
  late ThemeProvider themeProvider;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(miliseconds: 300);

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: "Settings", icon: Icons.settings),
    PopupChoices(title: "Sign out", icon: Icons.exit_to_app)
  ];

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if (authProvider.getUserFirebaseId()!.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
    listScrollController.addListener(scrollListener);

    FcmNotification fcmNotification =
        FcmNotification(authProvider: authProvider, homeProvider: homeProvider);
    fcmNotification.setupFCM();

    LocalNotificationHandler.onNotification.stream.listen((String? payload) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SecondPage(payload: payload)));
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage remoteMessage) async {
      await Firebase.initializeApp();
      LocalNotificationHandler.showNotification(
          title: remoteMessage.data['title'],
          body: remoteMessage.data['body'],
          payload: "onBackgroundMessage ${remoteMessage.data['payload']}");
    });
  }

  @override
  Widget build(BuildContext context) {
    _textSearch = Provider.of<HomeProvider>(context, listen: true).textSearch;
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        actions: const [
          ChangeThemeButtonWidget(),
          //buildPopupMenu()
        ],
        title: const Text(
          'Home Page',
        ),
      ),
      body: WillPopScope(
          child: Stack(
            children: [
              Column(
                children: [
                  const SearchBar(),
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: homeProvider.getStreamFirestore(
                        FirestoreConstants.pathUserCollection,
                        _limit,
                        _textSearch),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemBuilder: (context, index) => SearchItems(
                                context,
                                snapshot.data!.docs[index],
                                currentUserId),
                            itemCount: snapshot.data?.docs.length,
                            controller: listScrollController,
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No user found...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  ))
                ],
              ),
              Positioned(
                  child: isLoading ? LoadingView() : const SizedBox.shrink())
            ],
          ),
          onWillPop: onBackPress),
    );
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: [
              Container(
                color: ColorConstants.themeColor,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: const Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    const Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: [
                    Container(
                      child: const Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text(
                      'Cancel',
                      style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: [
                    Container(
                      child: const Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text(
                      'Yes',
                      style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  // void onItemMenuPress(PopupChoices choice) {
  //   if (choice.title == "Sign out") {
  //     handleSignOut();
  //   } else {
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => SettingsPage()));
  //   }
  // }

  // Widget buildPopupMenu() {
  //   return PopupMenuButton<PopupChoices>(
  //       color: Theme.of(context).colorScheme.primaryVariant,
  //       icon: const Icon(Icons.more_vert),
  //       onSelected: onItemMenuPress,
  //       itemBuilder: (BuildContext context) {
  //         return choices.map((PopupChoices choice) {
  //           return PopupMenuItem<PopupChoices>(
  //               value: choice,
  //               child: Row(
  //                 children: [
  //                   Icon(
  //                     choice.icon,
  //                     color: Theme.of(context).iconTheme.color,
  //                   ),
  //                   const SizedBox(
  //                     width: 10,
  //                   ),
  //                   Text(
  //                     choice.title,
  //                     style:
  //                         TextStyle(color: Theme.of(context).iconTheme.color),
  //                   )
  //                 ],
  //               ));
  //         }).toList();
  //       });
  // }
}
