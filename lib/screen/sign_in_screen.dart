import 'package:chat_app/authentication/auth_page.dart';
import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/chatdata/handle.dart';
import 'package:chat_app/screen/conversation_screen.dart';
import 'package:chat_app/screen/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final storage = const FlutterSecureStorage();
  int count = 1;

  void checkLogin() {
    if (emailController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập email.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (passController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập mật khẩu.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );

      User? user = Auth().firebaseAuth.currentUser;
      final userCustom = UserCustom(user?.uid, user?.email, user?.displayName, user?.photoURL);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Conversation(user: userCustom,)));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Không tìm thấy người dùng với địa chỉ email này.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email không hợp lệ.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Mật khẩu không đúng.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> readEmailAndPassword() async {
    String? usernameValue = await storage.read(key: 'key_save_email');
    String? passwordValue = await storage.read(key: 'key_save_password');
    emailController.text = usernameValue!;
    passController.text = passwordValue!;
  }

  @override
  Widget build(BuildContext context) {
    if (count == 1) {
      readEmailAndPassword();
      count++;
    }
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 70,
        child: Image.asset('assets/logochatbot.png'),
      ),
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))
      ),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Mật khẩu',
          contentPadding:  const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))
      ),
    );

    final forgotPass = TextButton(
      child: const Text(
        'Quên mật khẩu',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.cyan,
        ),
      ),
      onPressed: () {

      },
    );

    var loginButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 40),
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        )
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text('Đăng nhập', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
      onPressed: () async {
        checkLogin();
        await storage.write(key: 'key_save_email', value: emailController.text);
        await storage.write(key: 'key_save_password', value: passController.text);
        signInWithEmailAndPassword();
      },
    );

    final loginFB = InkWell(
      child: ClipOval(
        child: SizedBox.fromSize(
            size: const Size(40, 40),
            child: Image.asset(
              'assets/facebook.png',
              fit: BoxFit.fill,
            )
        ),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Login with Facebook',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.cyan,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );

    final loginGoogle = InkWell(
      child: ClipOval(
        child: SizedBox.fromSize(
            size: const Size(40, 40),
            child: Image.asset(
              'assets/google.png',
              fit: BoxFit.fill,
            )
        ),
      ),
      onTap: () {
        Auth().signInWithGoogle(context: context);
      },
    );

    final loginGithub = InkWell(
      child: ClipOval(
        child: SizedBox.fromSize(
            size: const Size(40, 40),
            child: Image.asset(
              'assets/github.png',
              fit: BoxFit.fill,
            )
        ),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Login with Github',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.cyan,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );

    final signUp = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
        ),
        TextButton(
          child: const Text(
            'Đăng ký',
            style: TextStyle(
              color: Colors.cyan,
            ),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
          },
        )
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                logo,
                const SizedBox(height: 45,),
                email,
                const SizedBox(height: 10.0,),
                password,
                const SizedBox(height: 15,),
                forgotPass,
                const SizedBox(height: 25,),
                loginButton,
                const SizedBox(height: 40,),
                const Text('Hoặc tiếp tục với'),
                const SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    loginFB,
                    loginGoogle,
                    loginGithub
                  ],
                ),
                const SizedBox(height: 25,),
                signUp
              ],
            ),
          ),
        ),
      ),
    );
  }
}