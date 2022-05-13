import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:ichat_app/allProviders/setting_provider.dart';
import 'package:ichat_app/allWidgets/label_info_widget.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/allWidgets/overview_image_widget.dart';
import 'package:ichat_app/allWidgets/overview_textfield_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChangeAccountInfoPage extends StatefulWidget {
  const ChangeAccountInfoPage({Key? key}) : super(key: key);

  @override
  _ChangeAccountInfoPageState createState() => _ChangeAccountInfoPageState();
}

class _ChangeAccountInfoPageState extends State<ChangeAccountInfoPage> {
  bool isLoading = false;

  late TextEditingController _nickNameController;
  late TextEditingController _aboutMeController;
  final TextEditingController _phoneNumController = TextEditingController();

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  String phoneNumber = "";
  String dialCodeDigits = "+84";

  bool isEditedPage = false;
  bool isImageUpdated = false;

  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusNodeNickName = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  final FocusNode focusNodePhoneNum = FocusNode();

  void readLocal() {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "";
      nickname = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          settingProvider.getPref(FirestoreConstants.phoneNumber) ?? "";
    });

    _nickNameController = TextEditingController(text: nickname);
    _aboutMeController = TextEditingController(text: aboutMe);
  }

  Future<bool?> showWarning(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Do you want discard changes?'),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard')),
            ],
          ));

  @override
  void initState() {
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    readLocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isEditedPage) {
          final shouldPop = await showWarning(context);

          return shouldPop ?? false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: const Text('Change Account Information',
              style: TextStyle(color: ColorConstants.primaryColor)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 5, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CupertinoButton(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: avatarImageFile == null
                            ? OverviewImage(
                                photoUrl: photoUrl,
                                demoIcon: Icons.account_circle,
                                width: 90,
                                height: 90,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: Image.file(
                                  avatarImageFile!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      onPressed: getImage),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabelInfo(label: "Name"),
                      Container(
                        margin: const EdgeInsets.only(left: 30, right: 30),
                        child: Theme(
                            data: Theme.of(context).copyWith(
                                primaryColor: ColorConstants.primaryColor),
                            child: TextField(
                              controller: _nickNameController,
                              onChanged: (value) {
                                isEditedPage = true;
                                nickname = value;
                              },
                              focusNode: focusNodeNickName,
                              style: const TextStyle(color: Colors.grey),
                              decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorConstants.greyColor2)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorConstants.primaryColor)),
                                  hintText: "Write your name...",
                                  contentPadding: EdgeInsets.all(5),
                                  hintStyle: TextStyle(
                                      color: ColorConstants.greyColor)),
                            )),
                      ),
                      const LabelInfo(label: "About Me"),
                      Container(
                        margin: const EdgeInsets.only(left: 30, right: 30),
                        child: Theme(
                            data: Theme.of(context).copyWith(
                                primaryColor: ColorConstants.primaryColor),
                            child: TextField(
                              controller: _aboutMeController,
                              onChanged: (value) {
                                isEditedPage = true;
                                aboutMe = value;
                              },
                              focusNode: focusNodeAboutMe,
                              style: const TextStyle(color: Colors.grey),
                              decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorConstants.greyColor2)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorConstants.primaryColor)),
                                  hintText: "Write something about yourself...",
                                  contentPadding: EdgeInsets.all(5),
                                  hintStyle: TextStyle(
                                      color: ColorConstants.greyColor)),
                            )),
                      ),
                      const LabelInfo(label: "Phone No"),
                      OverviewTextField(hintText: phoneNumber),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 60,
                          child: CountryCodePicker(
                            onChanged: (country) {
                              setState(() {
                                dialCodeDigits = country.dialCode!;
                              });
                            },
                            initialSelection: "VN",
                            showCountryOnly: false,
                            showDropDownButton: true,
                            showOnlyCountryWhenClosed: false,
                            favorite: const ["+1", "US", "+84", "VN"],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10, left: 30),
                        child: TextField(
                            maxLength: 12,
                            keyboardType: TextInputType.number,
                            controller: _phoneNumController,
                            onChanged: (value) {
                              isEditedPage = true;
                            },
                            style: const TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                                hintText: "Write Your New Phone Number...",
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefix: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    dialCodeDigits,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorConstants.greyColor2)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorConstants.primaryColor)))),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    child: TextButton(
                      onPressed: handleUpdateData,
                      child: const Text('Update Data',
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
                  )
                ],
              ),
            ),
            Positioned(
                child: isLoading ? LoadingView() : const SizedBox.shrink())
          ],
        ),
      ),
    );
  }

  Future<void> getImage() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });

    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      isEditedPage = true;
      setState(() {
        avatarImageFile = image;
        isImageUpdated = true;
      });
    }
  }

  Future<void> handleUpdateData() async {
    focusNodeNickName.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;

      if (dialCodeDigits != "+00" && _phoneNumController.text != "") {
        phoneNumber = dialCodeDigits + _phoneNumController.text.toString();
      }
    });

    if (isImageUpdated) {
      String fileName = id;

      //Upload file image to FirebaseStorage
      UploadTask uploadTask =
          settingProvider.uploadFile(avatarImageFile!, fileName);

      try {
        // After upload file to FirebaseStorage
        // FirebaseStorage will generate a public link for that file
        TaskSnapshot snapshot = await uploadTask;
        photoUrl = await snapshot.ref.getDownloadURL();
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? e.toString());
      }
    }

    UserChat updateInfo = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickname,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber);

    settingProvider
        .updateDataFirestore(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {
      await settingProvider.setPref(FirestoreConstants.nickname, nickname);
      await settingProvider.setPref(FirestoreConstants.aboutMe, aboutMe);
      await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
      await settingProvider.setPref(
          FirestoreConstants.phoneNumber, phoneNumber);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update Success");
      Navigator.of(context).pop(true);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }
}
