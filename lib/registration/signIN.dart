import 'package:chat_app/chat/chatroom.dart';
import 'package:chat_app/registration/datastore.dart';
import 'package:chat_app/registration/signUP.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _emailcontroller1 = new TextEditingController();
  TextEditingController _passcontroller1 = new TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Datastore datastore = new Datastore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _key,
      child: WillPopScope(
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
                      height: 60,
                    ),
                    Text(
                      "Chat App",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Log In",
                      style: TextStyle(
                          color: Colors.green[900],
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            Positioned(
                top: 200,
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.green[600]]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35))),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        TextField(
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 2),
                          controller: _emailcontroller1,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.green[300],
                              border: InputBorder.none,
                              hintText: "Enter E-mail",
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.green[700]),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.white),
                              )),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 2),
                          obscureText: true,
                          controller: _passcontroller1,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.green[300],
                              border: InputBorder.none,
                              hintText: "Enter Password",
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.green[700]),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Container(
                            width: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green[600]),
                            child: TextButton(
                                onPressed: () async {
                                  if (_key.currentState.validate()) {
                                    login();
                                  }
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      letterSpacing: 1,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUP()));
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        )
                      ],
                    )))
          ],
        ),
      ),
    ));
  }

  void login() async {
    try {
      final User user = (await auth.signInWithEmailAndPassword(
        email: _emailcontroller1.text,
        password: _passcontroller1.text,
      ))
          .user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', _emailcontroller1.text);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
      print('Login Successful');
    } catch (e) {
      print(e);
    }
  }
}
