import 'package:flutter/material.dart';

class OverviewImageChat extends StatelessWidget {
  String photoUrl;
  String demoImage;
  double width;
  double height;

  OverviewImageChat(
      {Key? key,
      required this.photoUrl,
      required this.demoImage,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Material(
          child: Image.asset(
            demoImage,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          clipBehavior: Clip.hardEdge,
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
    );
  }
}
