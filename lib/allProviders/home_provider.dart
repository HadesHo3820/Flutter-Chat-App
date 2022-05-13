import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ichat_app/allConstants/constants.dart';

class HomeProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;
  String _textSearch = "";

  HomeProvider({required this.firebaseFirestore});

  String get textSearch => _textSearch;

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  void setTextSearch(String textSearch) {
    _textSearch = textSearch;
    notifyListeners();
  }

  Stream<QuerySnapshot> getStreamFirestore(
      String pathCollection, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .snapshots();
    }
  }
}
