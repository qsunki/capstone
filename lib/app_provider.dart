import 'package:flutter/material.dart';
import 'package:flutter_openai/repository/diary_repository.dart';
import 'package:flutter_openai/view/calendar.dart';
import 'package:flutter_openai/view/diary_list.dart';

class AppProv extends ChangeNotifier {
  int _index = 1;
  final DiaryRepository diaryRepo = DiaryRepository();
  final _mainWidgets = <Widget>[
    Calendar(),
    DiaryList(),
  ];

  int get index => _index;

  set index(int index) {
    _index = index;
    notifyListeners();
  }

  Widget get selectedWidget => _mainWidgets[_index];
}
