import 'package:chat_app/main.dart';
import 'package:chat_app/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Greeting extends StatefulWidget {
  const Greeting({super.key});

  @override
  State<StatefulWidget> createState() =>  _GreetingState();
}

class _GreetingState extends  State<Greeting>{

  String? check;
  int count = 0;
  final List<String> hello = [
    'Chào mừng bạn tới ChatBot, một người bạn tuyệt vời để trò chuyện với bạn',
    'Nếu bạn cần hỗ trợ bất kỳ điều gì, hãy mở ChatBot',
    'ChatBot sẽ luôn luôn hỗ trợ và khiến bạn trở lên vui vẻ'
  ];

  final storage = const FlutterSecureStorage();

  void writeFirstOpenApp() async {
    await storage.write(key: 'first', value: 'false');
  }

  void readFirstOpenApp() async {
    String? checkFirst = await storage.read(key: 'first');
    if (checkFirst == 'false') {
      check = 'false';
    }
  }

  @override
  Widget build(BuildContext context) {

    // readFirstOpenApp();
    // if (check == 'false') {
    //   Navigator.pushReplacementNamed(context, 'LoginRoute');
    // }

    var logo = Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Image.asset(
        'assets/logochatbot.png',
        // fit: BoxFit.fitWidth,
      ),
    );

    var greetingText = Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Text(
          hello[count],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            wordSpacing: 10,
          ),
        ),
      ),
    );

    var continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        textStyle: const TextStyle(
            fontSize: 20
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: count == 2 ? const Text('Bắt đầu') : const Text('Tiếp tục'),
      onPressed: () {
        if (count != 2) {
          if (this.mounted) {
            setState(() {
              count++;
            });
          }
        } else {
          // await HomePageState().storage.write(key: 'key_save_first_open', value: 'check');
          count = 0;
          // writeFirstOpenApp();
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          children: [
            const Spacer(),
            logo,
            const Spacer(),
            greetingText,
            const Spacer(flex: 5),
            continueButton,
          ],
        ),
      )
    );
  }
}