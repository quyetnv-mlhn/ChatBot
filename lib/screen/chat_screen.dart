import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/api_services.dart';
import 'package:chat_app/screen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chatdata/handle.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Chat extends StatefulWidget {
  final String title;
  final String user_id;
  const Chat({Key? key, required this.title, required this.user_id}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _textEditingController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool checkSetState = true;
  int backButtonPressedCount = 0;
  final Handle _handle = Handle();
  late stt.SpeechToText _speechToText;
  TextToSpeech _textToSpeech = TextToSpeech();
  bool _isListening = false;
  String? _textSpeech;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _textToSpeech.setLanguage('vi-VN');
  }

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

  Future<void> waitData() async {
    List<ChatMessage> _messages2 = await _handle.readData(widget.user_id);
    await Future.delayed(const Duration(seconds: 1), () {
      _messages.addAll(_messages2);
    });
    setState(() {
      checkSetState = false;
    });
  }

  _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hãy nói gì đó',
          textAlign: TextAlign.center,
        ),
        content: AvatarGlow(
          glowColor: Colors.blue,
          endRadius: 90.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: Material(     // Replace this child with your own
            elevation: 8.0,
            shape: CircleBorder(),
            child: CircleAvatar(
              child: Icon(
                Icons.mic,
                color: Theme.of(context).colorScheme.secondary,
              ),
              radius: 40.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkSetState) {
      waitData();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.black54),
          backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/logo.jpg'),
              ),
              Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.black54, fontSize: 18), textAlign: TextAlign.center,))
            ]
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
              ),
              onPressed: () {
                Handle().readData(widget.user_id);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Setting()));
              },
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      reverse: true,
                      itemBuilder: (_, int index) => _messages[index],
                      itemCount: _messages.length,
                    )),
                _buildTextComposer()
              ],
            ),
            checkSetState
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : const Center(child: null),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color.fromRGBO(242, 248, 248, 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                    icon: Icon(Icons.mic_none),
                    onPressed: () async {
                      _showDialog(context);
                      if (!_isListening) {
                        bool available = await _speechToText.initialize(
                          onStatus: (result) {
                            print('onStatus: $result');
                            if (result == 'done') {
                              Navigator.of(context).pop();
                              _textEditingController.text = _textSpeech!;
                              setState(() {
                                _isListening = false;
                                _speechToText.stop();
                              });
                            }
                          },
                          onError: (result) => print('onError: $result'),
                        );
                        if (available) {
                          setState(() {
                            _isListening = true;
                          });
                          _speechToText.listen(
                            listenMode: ListenMode.confirmation,
                            onResult: (result) => setState(() {
                              _textSpeech = result.recognizedWords;
                            })
                          );
                        }
                      }
                    },
                ),
              ),
              Flexible(
                  child: TextField(
                    style: const TextStyle(fontSize: 18),
                    controller: _textEditingController,
                    onSubmitted: _handleSubmitted,
                    decoration: const InputDecoration.collapsed(hintText: "Send a message"),
                  )),
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if(_textEditingController.text != "") {
                        _handleSubmitted(_textEditingController.text);
                      }
                    }
                ),
              )
            ],
          ),
        ));
  }

  Future<void> _handleSubmitted(String text) async {
    _textEditingController.clear();
    ChatMessage chatMessage = ChatMessage(
      text: text,
      isUser: true,
    );
    setState(() {
      _messages.insert(0, chatMessage);
    });

    // String msg2 = Handle().handleUserInput(chatMessage.text);

    String msg = await ApiServices.sendMessage(text);
    String msg1 = msg.replaceFirst("\n", "");
    String msg2 = msg1.replaceFirst("\n", "");

    if (msg2 == '') {
      msg2 = _handle.handleUserInput(text);
    }

    ChatMessage reply = ChatMessage(
      text: msg2,
      isUser: false,
    );

    setState(() {
      _messages.insert(0, reply);
      _textToSpeech.speak(reply.text);
      _handle.addData(widget.user_id, chatMessage.text, reply.text);
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Quyết",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color.fromRGBO(255, 153, 141, 1.0)),
                  constraints: const BoxConstraints(maxWidth: 250),
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/anhthe.png')
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 10),
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/logo.jpg"),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mimi",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Color.fromRGBO(255, 211, 202, 1.0),
                  ),
                  constraints: const BoxConstraints(maxWidth: 250),
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(text,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                )
              ],
            )
          ],
        ),
      );
    }
  }
}