import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

List<String> myList = [
  
];

var random = Random();
int index = random.nextInt(myList.length);
String apiKey = myList[index];

class ApiChatBotServices {
  static String baseUrl = 'https://api.openai.com/v1/completions';

  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  static sendMessage(String? message) async {
    var res = await http.post(Uri.parse(baseUrl),
        headers: header,
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': '$message',
          'temperature': 0,
          'max_tokens': 500,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
          'stop': [ 'Human:', ' AI']
        })
    );

    if(res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      print('Failed to fetch data');
      return '';
    }
  }

  static String voice = 'linhsan';

  static getAudioUrl(String text) async {
    String apiKey = 'ESSnE72dkdp11nN3XEctLNi8KKx9jJhx';
    String speed = '0';
    final response = await http.post(
      Uri.parse('https://api.fpt.ai/hmi/tts/v5'),
      headers: {
        'api-key': apiKey,
        'voice': voice,
        'speed': speed,
      },
      body: text,
    );

    if (response.statusCode == 200) {
      final data = response.body;
      print(data);
      Map<String, dynamic> dataConvert = jsonDecode(data);
      final audioUrl = dataConvert['async'];
      print(audioUrl);
      return audioUrl;
    } else {
      throw Exception('Failed to load audio');
    }
  }
}
