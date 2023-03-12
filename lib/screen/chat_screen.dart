import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/animation/three_dot.dart';
import 'package:chat_app/api_services.dart';
import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/screen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chatdata/handle.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Chat extends StatefulWidget {
  final String title;
  final UserCustom userCustom;
  final String section;
  const Chat(
      {Key? key,
      required this.title,
      required this.userCustom,
      required this.section})
      : super(key: key);
  @override
  _ChatState createState() {
    MyData._userCustom = userCustom;
    return _ChatState();
  }

}

class _ChatState extends State<Chat> {
  final TextEditingController _textEditingController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool checkSetState = true;
  final Handle _handle = Handle();
  late stt.SpeechToText _speechToText;
  TextToSpeech _textToSpeech = TextToSpeech();
  bool _isListening = false;
  String? _textSpeech;
  bool checkPop = true; //kiem tra man hinh pop cua aleart dialog
  String chooseVoiceGG = 'false';
  final audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _textToSpeech.setLanguage('vi-VN');
  }

  Future<void> waitData() async {
    List<ChatMessage> messages2 = await _handle.readData(
        widget.userCustom.id, '${widget.section}?${widget.title}');
    setState(() {
      _messages.addAll(messages2);
      checkSetState = false;
    });
  }

  _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          _textEditingController.text = _textSpeech!;
          setState(() {
            checkPop = false;
            _isListening = false;
            _speechToText.stop();
          });
        },
        child: WillPopScope(
          onWillPop: () async {
            _textEditingController.text = _textSpeech!;
            setState(() {
              checkPop = false;
              _isListening = false;
              _speechToText.stop();
            });
            return true;
          },
          child: AlertDialog(
            title: const Text(
              'Hãy nói gì đó',
              textAlign: TextAlign.center,
            ),
            content: AvatarGlow(
              glowColor: Colors.blue,
              endRadius: 90.0,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              child: Material(
                // Replace this child with your own
                elevation: 8.0,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 40.0,
                  child: Container(
                    width: 500,
                    height: 500,
                    child: IconButton(
                      icon: const Icon(Icons.mic),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _textEditingController.text = _textSpeech!;
                        setState(() {
                          checkPop = false;
                          _isListening = false;
                          _speechToText.stop();
                        });
                      },
                    ),
                  ),
                ),
              ),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _textToSpeech.stop();
          audioPlayer.stop();
        });
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          _textToSpeech.stop();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: Colors.black54),
            backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
            title: Row(children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/logochatbot.png'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                    textAlign: TextAlign.center,
                  ))
            ]),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Setting(user: widget.userCustom,)));
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
                    itemBuilder: (context, index) => _messages[index],
                    itemCount: _messages.length,
                  )),
                  if (_messages.isNotEmpty && _messages.first.isUser)
                    const ThreeDots(),
                  _buildTextComposer()
                ],
              ),
              //tạo animation loading
              checkSetState
                  ? const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                  : const Center(child: null),
            ],
          ),
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
                  icon: const Icon(Icons.mic_none),
                  onPressed: () async {
                    _showDialog(context);
                    if (!_isListening) {
                      bool available = await _speechToText.initialize(
                        onStatus: (result) {
                          print('onStatus: $result');
                          if (result == 'done' && checkPop) {
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
                          checkPop = true;
                          _isListening = true;
                        });
                        _speechToText.listen(
                            listenMode: ListenMode.confirmation,
                            onResult: (result) => setState(() {
                                  _textSpeech = result.recognizedWords;
                                }));
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
                    decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
                  )),
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_textEditingController.text != "") {
                        _handleSubmitted(_textEditingController.text);
                        _textSpeech = '';
                      }
                    }),
              )
            ],
          ),
        ));
  }

  Future<void> _handleSubmitted(String text) async {
    _textEditingController.clear();
    final storage = const FlutterSecureStorage();

    ChatMessage chatMessage = ChatMessage(
      text: text,
      isUser: true,
      isNewMessage: true,
    );

    if (_messages.isNotEmpty && !_messages[0].isUser) {
      _messages.first.isNewMessage = false;
    }

    setState(() {
      _messages.insert(0, chatMessage);
    });

    String msg = await ApiChatBotServices.sendMessage(text);
    String msg1 = msg.replaceFirst("\n", "");
    String msg2 = msg1.replaceFirst("\n", "");

    if (msg2 == '') {
      msg2 = _handle.handleUserInput(text);
    }

    ChatMessage reply = ChatMessage(
      text: msg2,
      isUser: false,
      isNewMessage: true,
    );

    try {
      setState(() {
        _messages.insert(0, reply);
      });

      String chooseVoiceGG = (await storage.read(key: 'chooseVoiceGG')) ?? 'false';

      if (chooseVoiceGG == 'true') {
        _textToSpeech.speak(reply.text);
      } else {
        String audioUrl = await ApiChatBotServices.getAudioUrl(reply.text);
        await audioPlayer.play(UrlSource(audioUrl));
      }

      _handle.addData(widget.userCustom.id, '${widget.section}?${widget.title}', widget.title, chatMessage.text, reply.text);
    } catch (e) {
      print('Error: $e');
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  bool isNewMessage;

  ChatMessage({required this.text, required this.isUser, required this.isNewMessage});

  @override
  Widget build(BuildContext context) {

    if (isUser) {
      // print(_ChatState().widget.userCustom.photoURL);
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
              child: CircleAvatar(
                  backgroundImage: NetworkImage(MyData._userCustom!.photoURL ?? 'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg'),
              )
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
                backgroundImage: AssetImage("assets/logochatbot.png"),
                backgroundColor: Colors.transparent,
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
                  child:
                      isNewMessage
                      ? AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              text,
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                              ),
                              speed: const Duration(milliseconds: 60),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                      )
                      : Text(
                      text,
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

class MyData {
  static UserCustom? _userCustom;
}
