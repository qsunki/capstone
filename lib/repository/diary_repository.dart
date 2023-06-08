import 'dart:convert';

import 'package:flutter_openai/domain/diary.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class DiaryRepository {
  Future<List<Diary>> readDiaries() async {
    var dir = await _localDir;
    var listSync = dir.listSync();
    var map = listSync
        .map((e) => (e as File).readAsStringSync())
        .map(jsonDecode)
        .map((e) => Diary.fromJson(e))
        .toList();
    return map;
  }

  Future<Directory> get _localDir async {
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}/Aiary';
    var aiary = Directory(path);
    if (!aiary.existsSync()) aiary.createSync();
    return aiary;
  }

  Future<Diary> readDiary(DateTime dateTime) async {
    // try {
      var dir = await _localDir;
      var file = File(
          '${dir.path}/${dateTime.year}-${dateTime.month}-${dateTime.day}.json');
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return Diary.fromJson(json);
    // } catch (e) {
    //   log(e.toString());
    //   return Diary('', '', dateTime, []);
    // }
  }

  Future<File> writeDiary(Diary diary) async {
    var dir = await _localDir;
    var dateTime = diary.dateTime;
    var file = File(
        '${dir.path}/${dateTime.year}-${dateTime.month}-${dateTime.day}.json');
    final json = diary.toJson();
    return file.writeAsString(jsonEncode(json));
  }

  Future<Diary> readDiaryChat() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = File(
          '${dir.path}/diaryChatLogs.json');
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return Diary.fromJson(json);
    } catch (e) {
      return Diary('', '', DateTime(0000), []);
    }
  }
}
