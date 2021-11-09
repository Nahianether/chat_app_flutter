import 'dart:io';

import 'package:chat_app/chat/chatroom.dart';
import 'package:chat_app/registration/datastore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class ChatFinal extends StatefulWidget {
  final String barMail;
  ChatFinal(this.barMail);
  @override
  _ChatFinalState createState() => _ChatFinalState();
}

class _ChatFinalState extends State<ChatFinal> {
  File _image;
  File image;
  final picker = ImagePicker();
  //String image;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    //image = pickedFile.toString();

    setState(() {
      if (pickedFile != null) {
        //_image = File(pickedFile.path);
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  final user = FirebaseAuth.instance.currentUser;
  TextEditingController textController = new TextEditingController();

  String chatroomID, textID;
  Stream textStream;
  String textType = "";

  //for emoji methods
  bool emojiPicker = false;
  bool isSelected = false;
  keyboardVisible() {
    final textFocus = FocusScope.of(context);
    if (!textFocus.hasPrimaryFocus) textFocus.requestFocus();
  }

  keyboardHide() {
    final textFocus = FocusScope.of(context);
    if (!textFocus.hasPrimaryFocus) textFocus.unfocus();
  }

  hideEmoji() {
    setState(() {
      emojiPicker = false;
    });
  }

  viewEmoji() {
    setState(() {
      emojiPicker = true;
    });
  }

  getInfo() async {
    chatroomID = getchatroomID(widget.barMail, user.email);
  }

  getchatroomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addText(bool sendClicked) {
    if (textController.text != "") {
      String texts = textController.text;
      var lastTexttime = DateTime.now();

      Map<String, dynamic> textInfo = {
        "texts": texts,
        "image": image,
        "sender": user.email,
        "timeStand": lastTexttime
      };
      if (textID == "") {
        textID = randomAlphaNumeric(12);
      }
      Datastore().addTextsFirebase(chatroomID, textID, textInfo).then((value) {
        Map<String, dynamic> lastTextInfo = {
          "lastText": texts,
          "lastTextTime": lastTexttime,
          "lastTextSender": user.email
        };
        Datastore().updateLastSendText(chatroomID, lastTextInfo);
        if (sendClicked) {
          textController.text = "";
          textID = "";
        }
      });
    }
  }

  getsetTexts() async {
    textStream = await Datastore().getTexts(chatroomID);
    setState(() {});
  }

  appStarts() async {
    await getInfo();
    getsetTexts();
  }

  @override
  void initState() {
    appStarts();
    super.initState();
  }

  Widget textTile(String texts, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: 200,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
              color: sendByMe ? Colors.green[300] : Colors.grey[400],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft:
                      sendByMe ? Radius.circular(25) : Radius.circular(0),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(25))),
          padding: EdgeInsets.all(10),
          child: Text(
            texts,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget showTexts() {
    return StreamBuilder(
        stream: textStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70, top: 15),
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Column(
                      children: [
                        ds["texts"], 
                        ds["image"], 
                        //user.email == ds["sender"]
                      ],
                    );
                    //textTile(ds["texts"], user.email == ds["sender"]);
                  })
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green[900],
                  ),
                );
        });
  }

  Widget typeChat() {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.green, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                getImage();
                //textController.text = image.toString();
              },
              child: Icon(
                Icons.image,
                color: Colors.white,
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.emoji_emotions,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (!emojiPicker) {
                    viewEmoji();
                    keyboardHide();
                  } else {
                    hideEmoji();
                    keyboardVisible();
                  }
                }),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(25)),
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: textController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "type your text",
                      hintStyle: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  addText(true);
                })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      },
      child: Stack(
        children: [
          Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green[600], Colors.white]),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatRoom()));
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      Text(widget.barMail,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              width: double.infinity,
              height: 640,
              child: Container(
                child: Stack(
                  children: [
                    showTexts(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(child: typeChat()),
                        emojiPicker
                            ? EmojiPicker(
                                bgColor: Colors.green[400],
                                indicatorColor: Colors.green[900],
                                rows: 3,
                                columns: 7,
                                onEmojiSelected: (emoji, category) {
                                  setState(() {
                                    isSelected = true;
                                  });
                                  textController.text =
                                      textController.text + emoji.emoji;
                                },
                              )
                            : Container()
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
