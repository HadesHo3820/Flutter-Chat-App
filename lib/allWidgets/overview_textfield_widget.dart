import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/color_constants.dart';

class OverviewTextField extends StatelessWidget {
  String hintText;
  OverviewTextField({Key? key, required this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: ColorConstants.primaryColor),
          child: TextField(
            enabled: false,
            style: const TextStyle(color: Colors.grey),
            decoration: InputDecoration(
                hintText: hintText.isNotEmpty ? hintText : "N/A",
                contentPadding: const EdgeInsets.all(5),
                hintStyle: const TextStyle(color: Colors.grey)),
          )),
    );
  }
}
