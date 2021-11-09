import 'package:cloud_firestore/cloud_firestore.dart';

class Datastore {
  Future addTextsFirebase(
      String chatroomID, String textID, Map textInfo) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatroomID)
        .collection("texts")
        .doc(textID)
        .set(textInfo);
  }

  updateLastSendText(String chatroomID, Map lastTextInfo) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatroomID)
        .update(lastTextInfo);
  }

  createChatRoom(String chatroomID, Map chatRoomInfo) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatroomID)
        .get();
    if (snapShot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatroomID)
          .set(chatRoomInfo);
    }
  }

  Future<Stream<QuerySnapshot>> getTexts(String chatroomID) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatroomID)
        .collection("texts")
        .orderBy("timeStand", descending: true)
        .snapshots();
  }

  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }
}
