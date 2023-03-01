import 'dart:async';
import 'dart:io';

import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/chatdata/handle.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';

late UserCustom _userCustom;

class Conversation extends StatefulWidget {
  final UserCustom user;

  const Conversation({super.key, required this.user});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {

  final TextEditingController topicController = TextEditingController();
  final List<ConversationMessage> _conversations = [];
  final date = DateFormat('dd-MM-yyyy  hh:mm:ss a').format(DateTime.now());
  final _handle = Handle();
  late List<ConversationMessage> conversationMessages;
  bool checkSetState = true;
  int backButtonPressedCount = 0;


  Future<bool> _onWillPop() async {
    if (backButtonPressedCount == 1) {
      exit(0);
    } else {
      backButtonPressedCount++;
      Fluttertoast.showToast(
        msg: "Bấm back lần nữa để thoát",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromRGBO(1, 1, 1, 0.7),
        textColor: Colors.white,
        fontSize: 18.0,
      );
      Timer(const Duration(seconds: 2), () {
        backButtonPressedCount = 0;
      });
      return false;
    }
  }

  confirmTopicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Nhập chủ đề cuộc trò chuyện',
              style: TextStyle(
                color: Colors.black54,
              ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 15,),
              TextField(
                controller: topicController,
                autofocus: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // thiết lập border-radius cho OutlineInputBorder
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
                onPressed: () {
                  if (topicController.text != '') {

                    String title = topicController.text;
                    ConversationMessage conversation = ConversationMessage(
                      date,
                      topicController.text,
                    );
                    setState(() {
                      _conversations.insert(0, conversation);
                    });
                    topicController.clear();
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(title: title, userCustom: widget.user, section: date)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 8.0),
                            Text(
                              'Vui lòng nhập chủ đề.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15,)
          ],
        );
      },
    );
  }

  Widget newConversationButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width - 50, 55),
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text(
          "Tạo cuộc trò chuyện mới",
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onPressed: () async {
        confirmTopicDialog(context);
      },
    );
  }



  void processMessages() async {
    conversationMessages = await _handle.readSection(widget.user.id);
    // Here, messages is a List<ConversationMessage>
    // You can now process the messages as needed
    _conversations.insertAll(0, conversationMessages.reversed);
    setState(() {
      checkSetState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checkSetState) {
      processMessages();
    }
    _userCustom = widget.user;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.95),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.black54),
          backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/logochatbot.png"),
                backgroundColor: Colors.transparent,
              ),
              const Expanded (child: Text(
                'Cuộc trò chuyện',
                style: TextStyle(color: Colors.black54, fontSize: 18),
                textAlign: TextAlign.center,
              ))
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Setting()));
                },
                icon: const Icon(
                  Icons.settings,
                ))
          ],
        ),
        body: Column(
          children: [
            Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (_, int index) => _conversations[index],
                  itemCount: _conversations.length,
                )),
            newConversationButton(context),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}

class ConversationMessage extends StatelessWidget {
  final String date;
  final String text;
  const ConversationMessage(this.date, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(userCustom: _userCustom, section: date, title: text)));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
        ),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10, top: 10),
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size(100, 100),
                    child: Image.asset('assets/logochatbot.png'),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54
                    ),

                  ),
                  const SizedBox(height: 15,),
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2 + 40),
                    child: Text(
                      text,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black54
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}