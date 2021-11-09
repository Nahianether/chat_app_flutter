import 'package:chat_app/chat/chatscreen.dart';
import 'package:chat_app/registration/datastore.dart';
import 'package:chat_app/registration/signIN.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Datastore datastore = new Datastore();
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  getchatroomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () {
          SystemNavigator.pop();
        },
        child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[600], Colors.white]),
                ),
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 45,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.email,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                logout();
                              })
                        ],
                      ),
                    ),
                  ],
                )),
            Positioned(
                top: 120,
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.green[300]]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.green[900],
                              ),
                            );
                          }
                          return ListView(
                            children: snapshot.data.docs.map((Document) {
                              var str = Document["userEmail"];
                              var parts = str.split('@');
                              var prefix = parts[0].trim();
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        var chatroomID = getchatroomID(
                                            user.email, Document["userEmail"]);
                                        Map<String, dynamic> chatRoomInfo = {
                                          "users": [
                                            user.email,
                                            Document["userEmail"]
                                          ]
                                        };
                                        Datastore().createChatRoom(
                                            chatroomID, chatRoomInfo);

                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) => ChatFinal(
                                                    Document["userEmail"])));
                                      },
                                      child: Container(
                                          height: 70,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [
                                                Colors.grey[300],
                                                Colors.green[400]
                                              ]),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 25.0,
                                                      backgroundImage: NetworkImage(
                                                          "https://i.ytimg.com/vi/R2YErtEOE6s/maxresdefault.jpg"),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      prefix,
                                                      style: TextStyle(
                                                          letterSpacing: 2,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.message,
                                                  color: Colors.green[900],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        })))
          ],
        ),
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    await auth.signOut();
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
  }
}
