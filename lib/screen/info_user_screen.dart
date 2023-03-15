import 'dart:io';
import 'package:chat_app/screen/setting_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat_app/api_services.dart';
import 'package:chat_app/authentication/auth_page.dart';
import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/chatdata/handle.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserInformation extends StatefulWidget {
  final UserCustom user;
  const UserInformation({Key? key, required this.user}) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _userInformationState();
  }
}

class _userInformationState extends State<UserInformation> {
  late UserCustom userCustom;
  final fullNameController = TextEditingController();
  final sexController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final picker = ImagePicker();
  File? _imageFile;
  bool changeImage = false;

  @override
  void initState() {
    super.initState();
    userCustom = widget.user;
    getUserInfo(userCustom.email);
  }

  Future<void> getUserInfo(String email) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(email);
    final documentSnapshot = await userRef.get();
    final data = documentSnapshot.data();
    final dataConvert = data as Map;
    if (documentSnapshot.exists) {
      print('Tài liệu đã tồn tại!');
      userCustom = UserCustom.fromJson(dataConvert);
      // await _loadImageFromNetwork(userCustom.photoURL);
    } else {
      print('Tài liệu không tồn tại.');
    }
    setState(() {

    });
  }

  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Future<void> _loadImageFromNetwork(String Url) async {
  //   try {
  //     final response = await http.get(Uri.parse(Url));
  //     final dir = await getApplicationDocumentsDirectory();
  //     final file = File('${dir.path}/image.jpg');
  //     await file.writeAsBytes(response.bodyBytes);
  //     setState(() {
  //       _imageFile = file;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (userCustom == null) {
      return const CircularProgressIndicator();
    }

    fullNameController.text = userCustom.name;
    sexController.text = userCustom.sex;
    birthController.text = userCustom.birth;
    phoneController.text = userCustom.phoneNumber;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black54),
        backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
        title: const Text('Thông tin tài khoản', style: TextStyle(color: Colors.black54, fontSize: 18),),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
            ),
            onPressed: () {

            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size(200, 200),
                        child: changeImage
                            ? Image.file(_imageFile!, fit: BoxFit.fitWidth)
                            : Image.network(userCustom.photoURL ?? 'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg', fit: BoxFit.fitWidth),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: GestureDetector(
                        onTap: () async {
                          await _chooseImage();
                          setState(() {
                            changeImage = true;
                          });
                        },
                        child: const Icon(
                          IconData(0xe0fa, fontFamily: 'MaterialIcons'),
                          color: Colors.blueAccent,
                        ),
                      ),
                    )
                  ]
              ),
              const SizedBox(height: 10,),
              Text(userCustom.name ?? 'Chatbot', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10,),
              Text(userCustom.email ?? 'chatbot@gmail.com', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20,),
              const Divider(color: Colors.grey,),
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fullNameController,
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          // initialValue: userCustom.name,
                          decoration: const InputDecoration(
                            hintText: 'Họ và tên',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: sexController,
                          keyboardType: TextInputType.text,
                          // initialValue: userCustom.sex,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Giới tính',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: birthController,
                          keyboardType: TextInputType.datetime,
                          // initialValue: userCustom.birth,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Ngày sinh',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          // initialValue: userCustom.phoneNumber,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Số điện thoại',
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            filled: true,
                            fillColor: Color.fromRGBO(1, 1, 1, 0.05),
                            enabledBorder: InputBorder.none,
                          ),
                        )
                      ],
                    ),
                  )
              ),
              ElevatedButton(
                onPressed: () async {
                  await Handle().addInfoUser(fullNameController.text, userCustom.email, _imageFile!, userCustom.id, phoneController.text, sexController.text, birthController.text);
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Setting(user: userCustom)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Icon(Icons.logout_outlined),
                    ),
                    Text('Cập nhật', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}