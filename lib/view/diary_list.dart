import 'package:flutter/material.dart';
import 'package:flutter_openai/app_provider.dart';
import 'package:flutter_openai/domain/diary.dart';
import 'package:provider/provider.dart';


class DiaryList extends StatelessWidget {
  const DiaryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<Diary>>(
      initialData: [],
      create: (context) => context.read<AppProv>().diaryRepo.readDiaries(),
      child: Builder(
        builder: (context) {
          return ListView.builder(
            itemCount: context.watch<List<Diary>>().length,
            itemBuilder: (context, index) {
              final diaries = context.watch<List<Diary>>();
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
                      Navigator.pushNamed(context, 'chat_daily', arguments: diary.dateTime);
                    },
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
