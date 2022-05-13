import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/color_constants.dart';

class OverviewImage extends StatelessWidget {
  String photoUrl;
  IconData demoIcon;
  double width;
  double height;

  OverviewImage(
      {Key? key,
      required this.photoUrl,
      required this.demoIcon,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return photoUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: Image.network(
              photoUrl,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  demoIcon,
                  size: width,
                  color: ColorConstants.greyColor,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: width,
                  height: height,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Colors.grey,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null),
                  ),
                );
              },
            ))
        : Icon(
            demoIcon,
            size: width,
            color: ColorConstants.greyColor,
          );
  }
}
