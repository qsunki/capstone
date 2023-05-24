import 'package:flutter/material.dart';

class DiaryModel {
  String content;
  String summary;
  final DateTime dateTime;
  List<Map<String, dynamic>> chatLogs;

  DiaryModel(this.content, this.summary, this.dateTime, this.chatLogs);

  DiaryModel.fromJson(Map<String, dynamic> json)
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

}
