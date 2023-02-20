
import 'package:chat_app/screen/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Handle {
  int countWrite = 1;
  int countRead = 1;

  Future<void> addData(String user_id, String user_chat, String bot_chat) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('data').doc(user_id);
    final dataSnapshot = await datas.get();
    final data = dataSnapshot.data();

    countWrite = dataSnapshot.exists? (data as Map)['count'] + 1 : 1;

    if (dataSnapshot.exists) {
      await datas.update({
        '${countWrite}user': user_chat,
        '${countWrite}bot': bot_chat,
        'count': countWrite,
      });
    } else {
      await datas.set({
        '${countWrite}user': user_chat,
        '${countWrite}bot': bot_chat,
        'count': countWrite,
      });
    }
  }

  Future<List<ChatMessage>> readData(String user_id) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('data').doc(user_id);

    List<ChatMessage> _chatMessage = [];

    final snapshot = await datas.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      while ((data as Map)['${countRead}user'] != null) {
        print('user: ${(data as Map)['${countRead}user']}');
        print('bot: ${(data as Map)['${countRead}bot']}');

        ChatMessage chatMessage = ChatMessage(
          text: (data as Map)['${countRead}user'],
          isUser: true,
        );

        _chatMessage.insert(0, chatMessage);

        ChatMessage chatMessageBot = ChatMessage(
          text: (data as Map)['${countRead}bot'],
          isUser: false,
        );

        _chatMessage.insert(0, chatMessageBot);

        countRead++;
      }
    }

    return _chatMessage;
  }
}