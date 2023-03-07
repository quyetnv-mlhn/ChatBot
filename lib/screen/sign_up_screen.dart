import 'package:chat_app/authentication/auth_page.dart';
import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/screen/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  UserCustom? userCustom;

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );
      userCustom?.name = fullNameController.text;
      userCustom?.email = emailController.text;
      userCustom?.photoURL = 'https://i.pinimg.com/736x/c6/e5/65/c6e56503cfdd87da299f72dc416023d4.jpg';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.check_box, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Đã tạo tài khoản thành công.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.cyan,
          duration: Duration(seconds: 3),
        ),
      );
      fullNameController.clear();
      emailController.clear();
      passController.clear();
      confirmPassController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
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
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email này đã tồn tại.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Mật khẩu không đủ mạnh.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
          duration: Duration(seconds: 3),
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
          duration: Duration(seconds: 3),
        ),
      );
    } else if (confirmPassController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Vui lòng nhập lại mật khẩu.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = TextFormField(
      controller: fullNameController,
      autofocus: false,
      decoration: InputDecoration(
          hintText: "Họ và tên",
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Mật khẩu',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    final confirmPassword = TextFormField(
      controller: confirmPassController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
          hintText: 'Nhập lại mật khẩu',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
    );

    var SignUpButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 40),
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      onPressed: () {
        checkLogin();
        if (confirmPassController.text == passController.text) {
          createUserWithEmailAndPassword();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text(
                    'Các mật khẩu đã nhập không khớp. Hãy thử lại.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text('Đăng ký',
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
    );

    final loginFB = InkWell(
      child: ClipOval(
        child: SizedBox.fromSize(
            size: const Size(40, 40),
            child: Image.asset(
              'assets/facebook.png',
              fit: BoxFit.fill,
            )),
      ),
      onTap: () {},
    );

    final loginGoogle = InkWell(
      child: ClipOval(
        child: SizedBox.fromSize(
            size: const Size(40, 40),
            child: Image.asset(
              'assets/google.png',
              fit: BoxFit.fill,
            )),
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
            )),
      ),
      onTap: () {},
    );

    final signIn = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
        ),
        TextButton(
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: Colors.cyan,
            ),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          },
        )
      ],
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Tạo tài khoản của bạn',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 45,
                ),
                fullName,
                const SizedBox(
                  height: 10,
                ),
                email,
                const SizedBox(
                  height: 10,
                ),
                password,
                const SizedBox(
                  height: 10,
                ),
                confirmPassword,
                const SizedBox(
                  height: 25,
                ),
                SignUpButton,
                const SizedBox(
                  height: 50,
                ),
                const Text('Hoặc tiếp tục với'),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [loginFB, loginGoogle, loginGithub],
                ),
                const SizedBox(
                  height: 25,
                ),
                signIn
              ],
            ),
          ),
        ),
      ),
    );
  }
}