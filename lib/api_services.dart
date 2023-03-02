import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
          'max_tokens': 1000,
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
}

class ApiPlayht {
  static String apiKey = '1995a630f147437db1c67491dcd1b66d';
  static String text = 'Hello, this is a sample text.';
  static String url = 'https://play.ht/api/v1/convert';
  static String user_id = 'rtDLtHJ2bWgXrhOJwqHf9OpOBTj1';

  static void voice() async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $apiKey",
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: {
        'voice': 'vi-VN-Standard-A',
        'content':'$text',
        'speed': 1,
        'preset': 'real-time',
      },
    );
    print("voice ${response.statusCode}");
    if (response.statusCode == 200) {
      // Phản hồi trả về là một URL đến tệp âm thanh MP3 được tạo ra bởi Play.ht.
      final String audioUrl = response.body;
      print(audioUrl);
      // Sử dụng URL này để phát lại âm thanh trong ứng dụng của bạn.
    } else {
      // Xử lý lỗi nếu có.
    }
  }
}