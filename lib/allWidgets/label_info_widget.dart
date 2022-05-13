import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/color_constants.dart';

class LabelInfo extends StatelessWidget {
  final String label;

  const LabelInfo({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(label,
          style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor)),
      margin: const EdgeInsets.only(left: 10, top: 20, bottom: 5),
    );
  }
}
