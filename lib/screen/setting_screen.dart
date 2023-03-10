import 'package:chat_app/api_services.dart';
import 'package:chat_app/authentication/auth_page.dart';
import 'package:chat_app/authentication/user.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/info_user_screen.dart';
import 'package:chat_app/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Setting extends StatefulWidget {
  UserCustom user;
  Setting({super.key, required this.user});

  @override
  State<StatefulWidget> createState() {
    return _settingState();
  }
}

class _settingState extends State<Setting> {
  final storage = const FlutterSecureStorage();
  bool _isExpandedVoice = true;
  String? _selectedVoice = ApiChatBotServices.voice;

  void readData() async {
    String? check = await storage.read(key: 'chooseVoiceGG');
    if (check == 'true') {
      _selectedVoice = 'Google';
    }
  }

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    UserCustom userCustom = widget.user;
    final containerChangeVoice = Stack(
        alignment: Alignment.topRight,
        children: [
          SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ListTile(
                      title: Text('Google'),
                      leading: Radio(
                        value: 'Google',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'true');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Linh San'),
                      leading: Radio(
                        value: 'linhsan',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Ban Mai'),
                      leading: Radio(
                        value: 'banmai',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Lan Nhi'),
                      leading: Radio(
                        value: 'lannhi',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('L?? Minh'),
                      leading: Radio(
                        value: 'leminh',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('M??? An'),
                      leading: Radio(
                        value: 'myan',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Thu Minh'),
                      leading: Radio(
                        value: 'thuminh',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Gia Huy'),
                      leading: Radio(
                        value: 'giahuy',
                        groupValue: _selectedVoice,
                        onChanged: (String? value) async {
                          setState(() {
                            _selectedVoice = value;
                            ApiChatBotServices.voice = value!;
                          });
                          await storage.write(
                              key: 'chooseVoiceGG', value: 'false');
                        },
                      ),
                    ),
                  ]
              )
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExpandedVoice = !_isExpandedVoice;
                });
              },
              child: Icon(Icons.close_rounded, size: 25)
          ),
        ]
    );

    final containerSetting = Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserInformation(user: userCustom)));
                },
                child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                        child: Icon(Icons.people_outline),
                      ),
                      Expanded(child: Text('Th??ng tin t??i kho???n')),
                      Icon(Icons.arrow_circle_right_outlined),
                    ]
                ),
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.lock_clock_outlined),
                  ),
                  Expanded(child: Text('B???o m???t')),
                  Icon(Icons.arrow_circle_right_outlined)
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.remove_red_eye_rounded),
                  ),
                  Expanded(child: Text('Ch??? ????? t???i')),
                  Icon(Icons.arrow_circle_right_outlined)
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedVoice = !_isExpandedVoice;
                  });
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Icon(Icons.switch_account_outlined),
                    ),
                    Expanded(child: Text('Gi???ng ?????c')),
                    Icon(Icons.arrow_circle_right_outlined),
                  ],
                ),
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.more_vert_outlined),
                  ),
                  Expanded(child: Text('Ng??n ng???')),
                  Icon(Icons.arrow_circle_right_outlined),
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.list_alt_rounded),
                  ),
                  Expanded(child: Text('Th???ng k??')),
                  Icon(Icons.arrow_circle_right_outlined)
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.warning_rounded),
                  ),
                  Expanded(child: Text('Trung t??m tr??? gi??p')),
                  Icon(Icons.arrow_circle_right_outlined)
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Auth().signOut(context: context);
            await storage.write(key: 'key_save_email', value: '');
            await storage.write(key: 'key_save_password', value: '');
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: Icon(Icons.logout_outlined),
              ),
              Text('????ng xu???t', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );

    expandedScreen() {
      if (!_isExpandedVoice) {
        return containerChangeVoice;
      } else {
        return containerSetting;
    }
  }


    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black54),
        backgroundColor: const Color.fromRGBO(242, 248, 248, 1),
        title: const Text('C??i ?????t', style: TextStyle(color: Colors.black54, fontSize: 18),),
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
                      child: Image.network(userCustom.photoURL ?? 'https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg', fit: BoxFit.fitWidth),
                    ),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(0),
                  //   child: const Icon(IconData(0xe0fa, fontFamily: 'MaterialIcons'), color: Colors.blueAccent,),
                  // )
                ]
              ),
              const SizedBox(height: 10,),
              Text(widget.user.name ?? 'Chatbot', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10,),
              Text(widget.user.email ?? 'chatbot@gmail.com', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 20,),
              const Divider(color: Colors.grey,),
              Expanded(
                child: expandedScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}