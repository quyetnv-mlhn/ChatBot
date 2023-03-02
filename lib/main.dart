import 'package:chat_app/screen/greeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screen/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const storage = FlutterSecureStorage();
  String? check = await storage.read(key: 'check');
  if (check == 'false') {
    runApp(const HomePage2());
  } else {
    await storage.write(key: 'check', value: 'false');
    runApp(const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFd1f8e5);

    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: const Greeting(),
    );
  }
}

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  HomePageState2 createState() => HomePageState2();
}

class HomePageState2 extends State<HomePage2> {

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFd1f8e5);

    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: const Login(),
    );
  }
}

