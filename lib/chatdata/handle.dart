import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/screen/conversation_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Handle {
  int countWrite = 1;
  int countRead = 1;
  List<int> _list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  Future<void> addData(String user_id, String section, String title, String user_chat, String bot_chat) async {

    DocumentReference datas = FirebaseFirestore.instance.collection(user_id).doc(section);
    final dataSnapshot = await datas.get();
    final data = dataSnapshot.data();
    countWrite = dataSnapshot.exists? (data as Map)['count'] + 1 : 1;
    if (countWrite == 11) countWrite = 1;

    if (dataSnapshot.exists) {
      await datas.update({
        '${countWrite}user': user_chat,
        '${countWrite}bot': bot_chat,
        'count': countWrite,
        'title': title,
      });
    } else {
      await datas.set({
        '${countWrite}user': user_chat,
        '${countWrite}bot': bot_chat,
        'count': countWrite,
        'title': title,
      });
    }
  }

  Future<List<ChatMessage>> readData(String user_id, String section) async {
    DocumentReference datas = FirebaseFirestore.instance.collection(user_id).doc(section);

    List<ChatMessage> chatMessageReturn = [];

    final snapshot = await datas.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      countRead = (data as Map)['count'] + 1;
      if (countRead == 11) countRead = 1;
      while (_list.isNotEmpty) {
        // print('user: ${(data as Map)['${countRead}user']}');
        // print('bot: ${(data as Map)['${countRead}bot']}');

        if((data as Map)['${countRead}user'] != null) {
          ChatMessage chatMessage = ChatMessage(
            text: (data as Map)['${countRead}user'],
            isUser: true,
            isNewMessage: false,
          );
          ChatMessage chatMessageBot = ChatMessage(
            text: (data as Map)['${countRead}bot'],
            isUser: false,
            isNewMessage: false,
          );
          if (chatMessage.text != null) {
            chatMessageReturn.insert(0, chatMessage);
            chatMessageReturn.insert(0, chatMessageBot);
          }
        }

        countRead++;

        if (countRead == 11) countRead = 1;
        _list.remove(countRead);
      }
    }

    return chatMessageReturn;
  }

  // List<ConversationMessage>
  Future<List<ConversationMessage>> readSection(String user_id) async {
    List<ConversationMessage> conversationMesseges = [];

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection(user_id).get();

      querySnapshot.docs.forEach((doc) {
        conversationMesseges.add(ConversationMessage(doc.id.split('?')[0], doc.id.split('?')[1]));
      });
    } catch (e) {
      print('Error getting all documents: $e');
    }

    return conversationMesseges;
  }

  Future<void> addInfoUser(String fullName, String email, File imageFile, String id, String phoneNumber, String sex, String birthDay) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(email);
    final Reference storageReference = FirebaseStorage.instance.ref().child('images/${id}.jpg');

    if (imageFile != null) {
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
    } else {
      final http.Response response = await http.get(Uri.parse('https://phongreviews.com/wp-content/uploads/2022/11/avatar-facebook-mac-dinh-15.jpg'));
      final Uint8List imageData = response.bodyBytes;
      final UploadTask uploadTask = storageReference.putData(imageData);
      await uploadTask;
    }

    final String downloadURL = await storageReference.getDownloadURL();

    // Lưu trữ thông tin người dùng vào Firestore
    await userRef.set({
      'fullName': fullName,
      'email': email,
      'imagePath': downloadURL,
      'id': id,
      'phoneNumber': phoneNumber,
      'sex': sex,
      'birthDay': birthDay,
      // 'update': update,
    });
  }

  String handleUserInput(String user_input) {
    if (user_input.toLowerCase().contains("xin chào")) {
      return("Xin chào! Tôi là chatbot, bạn cần tôi giúp gì?");
    } else if (user_input.toLowerCase().contains("tạm biệt")) {
      return("Tạm biệt! Hãy quay lại nếu bạn cần sự trợ giúp của tôi.");
    } else if (user_input.toLowerCase().contains("cảm ơn")) {
      return("Không có gì! Hãy nói với tôi nếu bạn cần sự trợ giúp.");
    } else if (user_input.toLowerCase().contains("hôm nay là ngày mấy")) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      return("Hôm nay là ngày $formattedDate.");
    } else if (user_input.toLowerCase().contains("tổng")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 3) {
        return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tổng 2 và 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int sum = num1 + num2;
          return("Tổng của $num1 và $num2 là $sum.");
        } catch (FormatException) {
          return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tổng 2 và 3'.");
        }
      }
    } else if (user_input.toLowerCase().contains("tính hiệu")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 3) {
        return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính hiệu 5 trừ đi 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int diff = num1 - num2;
          return("Hiệu của $num1 trừ đi $num2 là $diff.");
        } catch (FormatException) {
          return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính hiệu 5 trừ đi 3'.");
        }
      }
    } else if (user_input.toLowerCase().contains("tính tích")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 3) {
        return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tích 2 và 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int product = num1 * num2;
          return ("Tích của $num1 và $num2 là $product.");
        } catch (FormatException) {
          return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tích 5 nhân 3'.");
        }
      }
    } else if (user_input.toLowerCase().contains("đổi mật khẩu")) {
      return("Để đổi mật khẩu, vui lòng truy cập trang đổi mật khẩu trên ứng dụng của chúng tôi.");
    } else if (user_input.toLowerCase().contains("cập nhật thông tin")) {
      return("Để cập nhật thông tin, vui lòng truy cập trang cập nhật thông tin trên ứng dụng của chúng tôi.");
    } else if (user_input.toLowerCase().contains("tìm kiếm")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 2) {
        return("Vui lòng nhập từ khóa tìm kiếm. Ví dụ: 'Tìm kiếm sản phẩm A'.");
      } else {
        String keyword = user_input.substring(18).trim();
        return("Đang tìm kiếm với từ khóa: $keyword");
      }
    } else if (user_input.toLowerCase().contains("đặt hàng")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 2) {
        return("Vui lòng nhập thông tin đặt hàng. Ví dụ: 'Đặt hàng sản phẩm A số lượng 2'.");
      } else {
        try {
          String product = words[2];
          int quantity = int.parse(words[4]);
          return("Đã đặt hàng $quantity $product.");
        } catch (FormatException) {
          return("Vui lòng nhập đúng cú pháp. Ví dụ: 'Đặt hàng sản phẩm A số lượng 2'.");
        }
      }
    } else if (user_input.toLowerCase().contains("hướng dẫn sử dụng")) {
      return("Vui lòng truy cập trang hướng dẫn sử dụng trên ứng dụng của chúng tôi để biết thêm chi tiết.");
    } else if (user_input.toLowerCase().contains("đánh giá sản phẩm")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 2) {
        return("Vui lòng nhập tên sản phẩm để đánh giá. Ví dụ: 'Đánh giá sản phẩm A'.");
      } else {
        String product = user_input.substring(17).trim();
        return("Vui lòng truy cập trang đánh giá sản phẩm $product trên ứng dụng của chúng tôi.");
      }
    } else if (user_input.toLowerCase().contains("thông tin sản phẩm")) {
      List<String> words = user_input.split(' ');
      if (words.length <= 2) {
        return("Vui lòng nhập tên sản phẩm để xem thông tin chi tiết. Ví dụ: 'Thông tin sản phẩm A'.");
      } else {
        String product = user_input.substring(19).trim();
        return("Đang tìm kiếm thông tin sản phẩm $product.");
      }
    }
    else {
      return("Xin lỗi, tôi không hiểu câu hỏi của bạn. Hãy thử lại với câu hỏi khác.");
    }
  }

  Map<String, String> keywords = {
    'bóng đá': 'football',
    'thời trang': 'fashion',
    'tài chính': 'finance',
    'thể thao điện tử': 'esport',
  };

  Map<String, List<String>> questions = {
    'football': [
      'Ai là người thắng giải Quả bóng Vàng năm nay?',
      'Ai là cầu thủ đang giữ kỷ lục ghi bàn nhiều nhất trong một mùa giải tại giải Ngoại hạng Anh?',
      'Đội bóng nào đã giành chức vô địch World Cup 2018?',
      'Ai là cầu thủ đang giữ kỷ lục số lần giành giải Cầu thủ xuất sắc nhất FIFA?',
      'Trong môn bóng đá, tại sao thủ môn được phép dùng tay ở khu vực cấm địa?',
      'Giải bóng đá nào được xem là giải đấu hàng đầu thế giới?',
      'Cầu thủ nào đã giành giải Cầu thủ xuất sắc nhất World Cup 2018?',
      'Ai là người sáng lập ra giải Ngoại hạng Anh?',
      'Đội bóng nào là đội vô địch EURO 2020?',
      'Trong bóng đá, giải pháp VAR được sử dụng để làm gì?'
    ],
    'fashion' : [
      "Tại sao màu đen là màu thường được sử dụng trong thời trang?",
      "Có bao nhiêu loại quần áo dành cho phụ nữ?",
      "Lịch sử của giày cao gót?",
      "Phụ kiện nào được sử dụng phổ biến nhất trong thời trang nữ?",
      "Tên gọi của loại vải được làm từ sợi tơ tằm?",
      "Nguồn gốc của áo sơ mi?",
      "Những kiểu dáng giày sneakers phổ biến nhất hiện nay?",
      "Tên gọi của loại đồng hồ mỏng nhất trên thị trường?",
      "Phụ kiện nào được sử dụng phổ biến nhất trong thời trang nam?",
      "Lịch sử của áo khoác da?"
    ],
    'finance' : [
      "Tại sao nên đầu tư vào thị trường chứng khoán?",
      "Điều gì ảnh hưởng đến giá cổ phiếu?",
      "Làm thế nào để tìm hiểu về các công ty trên thị trường chứng khoán?",
      "Đầu tư vào địa ốc có lợi hay không?",
      "Ngân hàng thương mại và ngân hàng đầu tư khác nhau như thế nào?",
      "Lợi ích và rủi ro của việc mua cổ phiếu trả cổ tức?",
      "Lãi suất vay ngân hàng ảnh hưởng như thế nào đến tài chính cá nhân?",
      "Phương pháp tiết kiệm hiệu quả nhất là gì?",
      "Thị trường forex là gì và nó hoạt động như thế nào?",
      "Cách phân biệt đầu tư và đánh bạc là gì?"
    ],
    'esport' : [
      "Những tựa game nào đang thống trị trong giới thể thao điện tử hiện nay?",
      "Có bao nhiêu đội tham gia giải đấu thể thao điện tử đang diễn ra?",
      "Những kỹ năng cần thiết để trở thành một game thủ chuyên nghiệp là gì?",
      "Các giải đấu thể thao điện tử được tổ chức tại những địa điểm nào trên thế giới?",
      "Các trò chơi điện tử nào được đánh giá là phù hợp cho việc luyện tập tư duy và tăng cường trí nhớ?",
      "Những trang web hay kênh Youtube nào có thể giúp cập nhật thông tin về thể thao điện tử nhanh nhất?",
      "Các sự kiện lớn như Chung kết Thế giới Liên Minh Huyền Thoại hay The International của Dota 2 có sự tham gia của những đội tuyển nào?",
      "Các game thủ nổi tiếng trong giới thể thao điện tử là ai?",
      "Có những trò chơi điện tử nào đang được phát triển để có thể trở thành môn thể thao chính thức trong tương lai?",
      "Những cách nào để tăng cường kỹ năng chơi game và đạt thành tích cao trong các giải đấu thể thao điện tử?"
    ],
  };
}