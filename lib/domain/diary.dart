import 'dart:async';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';

class Diary extends ChangeNotifier{
  String content;
  String summary;
  final DateTime dateTime;
  List<Map<String, dynamic>> chatLogs;

  Diary(this.content, this.summary, this.dateTime, this.chatLogs);

  Diary.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        summary = json['summary'],
        dateTime = DateTime.parse(json['dateTime']),
        chatLogs = json['chatLogs'].cast<Map<String, dynamic>>();

  Map<String, dynamic> toJson() => {
    'content': content,
    'summary': summary,
    'dateTime': dateTime.toString(),
    'chatLogs': chatLogs,
  };

  void addChat(Map<String, dynamic> chat) {
    chatLogs.add(chat);
    notifyListeners();
  }

  StreamSubscription<OpenAIStreamChatCompletionModel> addChatStream(Stream<OpenAIStreamChatCompletionModel> chatStream) {
    var sb = StringBuffer();
    var chat = {'content': '', 'role': 'assistant'};
    addChat(chat);
    return chatStream.listen((event) {
      var s = event.choices[0].delta.content;
      if (s != null){
        sb.write(s);
        chat['content'] = sb.toString();
        notifyListeners();
      }
    });
  }

}
