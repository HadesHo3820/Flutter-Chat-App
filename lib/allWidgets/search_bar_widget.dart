import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController searchBarController = TextEditingController();
  String textSearch = "";
  bool isSearching = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Icon(
          Icons.search,
          color: ColorConstants.greyColor,
          size: 20,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
            child: TextFormField(
          textInputAction: TextInputAction.search,
          controller: searchBarController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                isSearching = true;
                textSearch = value;
                Provider.of<HomeProvider>(context, listen: false)
                    .setTextSearch(textSearch);
              });
            } else {
              setState(() {
                isSearching = false;
                textSearch = "";
                Provider.of<HomeProvider>(context, listen: false)
                    .setTextSearch(textSearch);
              });
            }
          },
          decoration: const InputDecoration.collapsed(
              hintText: "Search here...",
              hintStyle:
                  TextStyle(fontSize: 13, color: ColorConstants.greyColor)),
          style: const TextStyle(fontSize: 13),
        )),
        isSearching
            ? GestureDetector(
                onTap: () {
                  searchBarController.clear();
                  setState(() {
                    isSearching = false;
                    textSearch = "";
                    Provider.of<HomeProvider>(context, listen: false)
                        .setTextSearch(textSearch);
                  });
                },
                child: const Icon(
                  Icons.clear_rounded,
                  color: ColorConstants.greyColor,
                  size: 20,
                ),
              )
            : const SizedBox.shrink()
        //})
      ]),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ColorConstants.greyColor2),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    );
  }
}
