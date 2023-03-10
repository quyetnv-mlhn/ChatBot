import 'dart:async';
import 'dart:math';

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
import 'package:video_player/video_player.dart';

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
  bool switchType = true;

  late VideoPlayerController _controller;
  int _currentVideoIndex = 1;
  bool suggestTopic = false;
  bool questionsTopic = false;
  late String topic;
  late int indexTopic;
  int countSuggest = 0;
  List<String> listKeywords = [];

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _textToSpeech.setLanguage('vi-VN');
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller =
        VideoPlayerController.asset('assets/robot_girl_$_currentVideoIndex.mp4')
          ..initialize().then((_) {
            setState(() {});
          });
    _controller.play();
    _controller.setLooping(true);
  }

  void _switchVideo() async {
    _controller.pause();
    _currentVideoIndex = _currentVideoIndex == 1 ? 2 : 1;
    final newController = VideoPlayerController.asset(
        'assets/robot_girl_$_currentVideoIndex.mp4');
    await newController.initialize();
    setState(() {
      _controller.dispose();
      _controller = newController;
    });
    _controller.setLooping(true);
    _controller.play();
  }

  //build c??c c??u h???i g???i ?? khi b???m v??o ch??? ?????
  Container buildQuestionsTopic(String topic) {
    listKeywords.clear();
    print('countSuggest: $countSuggest');
    if (countSuggest > 2) {
      setState(() {
        questionsTopic = false;
        countSuggest = 0;
      });
    }

    Random random = new Random();

    String? chooseTopic = _handle.keywords[topic];
    List<String> listQuestions = _handle.questions[chooseTopic]!;

    int index1 = random.nextInt(listQuestions.length);
    int index2;
    do {
      index2 = random.nextInt(listQuestions.length);
    } while (index2 == index1);
    print('index1: $index1, index2: $index2');

    String firstQuestion = listQuestions[index1];
    String secondQuestion = listQuestions[index2];

    return Container(
      width: MediaQuery.of(context).size.width * 80 / 100,
      child: Column(
        children: [
          OutlinedButton(
              onPressed: () {
                setState(() {
                  countSuggest++;
                  suggestTopic = false;
                  _handleSubmitted(firstQuestion);
                });
              },
              child: Text(
                firstQuestion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
          ),
          OutlinedButton(
              onPressed: () {
                setState(() {
                  countSuggest++;
                  suggestTopic = false;
                  _handleSubmitted(secondQuestion);
                });
              },
              child: Text(
                  secondQuestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
              )
          ),
        ],
      ),
    );
  }

  //build c??c ch??? ????? ???????c g???i ??
  Container buildOutlinedButtons(List<String> keywords) {
    return Container(
      width: MediaQuery.of(context).size.width * 80 / 100,
      child: Center(
        child: Wrap(
          spacing: 8.0, // Kho???ng c??ch gi???a c??c button trong c??ng m???t d??ng
          runSpacing: 8.0, // Kho???ng c??ch gi???a c??c d??ng
          children: keywords.map((keyword) {
            return OutlinedButton(
              onPressed: () {
                setState(() {
                  suggestTopic = false;
                  questionsTopic = true;
                  topic = keyword;
                });
              },
              child: Text(keyword),
            );
          }).toList(),
        ),
      ),
    );
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
              'H??y n??i g?? ????',
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
          _switchVideo();
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    switchType = !switchType;
                  });
                },
                child: switchType
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/logochatbot.png'),
                        backgroundColor: Colors.transparent,
                      )
                    : Icon(Icons.chat_outlined),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Setting(
                                user: widget.userCustom,
                              )));
                },
              )
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Flexible(
                      child: !switchType
                          ? Stack(children: [
                              Opacity(
                                opacity:
                                    0.8, // ?????t gi?? tr??? opacity th??nh 0.5 ????? l??m m??? ???nh
                                child: Image.asset(
                                  'assets/lab.png',
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                ),
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: _controller.value.isInitialized
                                          ? AspectRatio(
                                              aspectRatio:
                                                  _controller.value.aspectRatio,
                                              child: VideoPlayer(_controller),
                                            )
                                          : CircularProgressIndicator(),
                                    ),
                                  ),
                                  _buildTextComposer()
                                ],
                              ),
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              reverse: true,
                              itemBuilder: (context, index) => _messages[index],
                              itemCount: _messages.length,
                            )),
                  if (_messages.isNotEmpty &&
                      _messages.first.isUser &&
                      switchType)
                    const ThreeDots(),
                  if (suggestTopic && !questionsTopic && switchType) buildOutlinedButtons(listKeywords),
                  if (questionsTopic && switchType) buildQuestionsTopic(topic),
                  if (switchType) _buildTextComposer()
                ],
              ),
              //t???o animation loading
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
      //Ki???m tra reply c?? keyword hay kh??ng
      List<String> topics = _handle.keywords.keys.toList();
      for (int i = 0; i < topics.length; i++) {
        if (reply.text.toLowerCase().contains(topics[i])) {
          suggestTopic = true;
          listKeywords.add(topics[i]);
        }
      }

      setState(() {
        _messages.insert(0, reply);
      });

      String chooseVoiceGG =
          (await storage.read(key: 'chooseVoiceGG')) ?? 'false';

      if (chooseVoiceGG == 'true') {
        _switchVideo();
        _textToSpeech.speak(reply.text);
        Future.delayed(Duration(milliseconds: reply.text.length * 60), () {
          _switchVideo();
        });
      } else {
        bool sv = true;
        String audioUrl = await ApiChatBotServices.getAudioUrl(reply.text);
        await audioPlayer.play(UrlSource(audioUrl));
        _switchVideo();

        // 3 cho AudioPlayerState.completed.
        audioPlayer.onPlayerStateChanged.listen((playerState) {
          if (playerState.index == 3 && sv) {
            _switchVideo();
            sv = false;
          }
        });
      }

      _handle.addData(widget.userCustom.id, '${widget.section}?${widget.title}',
          widget.title, chatMessage.text, reply.text);
    } catch (e) {
      print('Error: $e');
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  bool isNewMessage;

  ChatMessage(
      {required this.text, required this.isUser, required this.isNewMessage});

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
                  "Quy???t",
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
                  backgroundImage: NetworkImage(MyData._userCustom!.photoURL ??
                      'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg'),
                )),
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
                  child: isNewMessage
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
                      : Text(text,
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
