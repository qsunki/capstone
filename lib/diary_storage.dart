import 'dart:convert';
import 'dart:developer';

import 'package:flutter_openai/model/diary_model.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class DiaryStorage {
  DateTime dateTime;

  DiaryStorage({required this.dateTime});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path\\${dateTime.year}-${dateTime.month}-${dateTime.day}.json');
  }

  Future<DiaryModel> readDiary() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final json = jsonDecode(contents);
    return DiaryModel.fromJson(json);
  }

  Future<File> writeDiary(DiaryModel diaryModel) async {
    final file = await _localFile;
    final json = diaryModel.toJson();
    return file.writeAsString(jsonEncode(json));
  }
}
