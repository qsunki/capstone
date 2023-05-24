import 'dart:convert';

import 'package:flutter_openai/model/diary_model.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class DiaryStorage {
  DateTime dateTime;

  DiaryStorage({required this.dateTime});

  static Future<List<DiaryModel>> readDiaries() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Aiary';
    final dir = Directory(path);
    var listSync = dir.listSync();
    var map = listSync.map((e) => (e as File).readAsStringSync()).map(jsonDecode).map((e) => DiaryModel.fromJson(e)).toList();
    return map;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path/Aiary/${dateTime.year}-${dateTime.month}-${dateTime.day}.json');
  }

  Future<DiaryModel> readDiary() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return DiaryModel.fromJson(json);
    } catch (e) {
      return DiaryModel('', '', dateTime, []);
    }
  }

  Future<File> writeDiary(DiaryModel diaryModel) async {
    final file = await _localFile;
    final json = diaryModel.toJson();
    return file.writeAsString(jsonEncode(json));
  }
}
