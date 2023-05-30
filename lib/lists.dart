import 'package:flutter/material.dart';
import 'package:flutter_openai/diary_storage.dart';

import 'chat.dart';
import 'model/diary_model.dart';

class Lists extends StatefulWidget {
  const Lists({Key? key}) : super(key: key);

  @override
  State<Lists> createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  List<DiaryModel> diaries = [];

  Future<void> loadDiaries() async {
    List<DiaryModel> loadedDiaries = await DiaryStorage.readDiaries();
    setState(() {
      diaries = loadedDiaries;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => loadDiaries(),
      child: ListView.builder(
        itemCount: diaries.length,
        itemBuilder: (context, index) {
          final diary = diaries[diaries.length - 1 - index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Card(
              elevation: 2.0,
              child: ListTile(
                title: Text(
                  '${diary.dateTime.year}.${diary.dateTime.month}.${diary.dateTime.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(diary.summary),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                diaryStorage:
                                    DiaryStorage(dateTime: diary.dateTime),
                              )));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
