import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allProviders/setting_provider.dart';
import 'package:ichat_app/allScreens/change_account_info_page.dart';
import 'package:ichat_app/allWidgets/label_info_widget.dart';
import 'package:ichat_app/allWidgets/navigation_drawer_widget.dart';
import 'package:ichat_app/allWidgets/overview_image_widget.dart';
import 'package:ichat_app/allWidgets/overview_textfield_widget.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  String phoneNumber = "";
  late SettingProvider settingProvider;

  @override
  void initState() {
    super.initState();
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "";
      nickname = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          settingProvider.getPref(FirestoreConstants.phoneNumber) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title: const Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                child: OverviewImage(
                  photoUrl: photoUrl,
                  demoIcon: Icons.account_circle,
                  height: 90,
                  width: 90,
                )),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 30),
              child: TextButton(
                onPressed: () async {
                  final isUpdated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeAccountInfoPage()));
                  if (isUpdated != null) {
                    if (isUpdated) {
                      readLocal();
                    }
                  }
                },
                child: const Text('Change Account Information',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    )),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        ColorConstants.primaryColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.fromLTRB(30, 10, 30, 10))),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabelInfo(label: "Name"),
                OverviewTextField(hintText: nickname),
                const LabelInfo(label: "About Me"),
                OverviewTextField(hintText: aboutMe),
                const LabelInfo(label: "Phone No"),
                OverviewTextField(hintText: phoneNumber),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
