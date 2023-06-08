import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/app_provider.dart';
import 'package:flutter_openai/view/chat_daily.dart';
import 'package:flutter_openai/view/chat_diary.dart';
import 'package:flutter_openai/view/diary_write.dart';
import 'package:provider/provider.dart';
import 'package:flutter_openai/env/env.dart';

void main() {
  OpenAI.apiKey = Env.apiKey;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProv>(
      create: (context) => AppProv(),
      child: MaterialApp(
        title: 'AIARY',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(),
        debugShowCheckedModeBanner: false,
        routes: {
          'chat_diary': (_) => ChatDiary(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case 'chat_daily':
              return MaterialPageRoute(
                builder: (context) => ChatDaily(
                  dateTime: settings.arguments as DateTime,
                ),
              );
            case 'chat_write':
              return MaterialPageRoute(
                  builder: (context) => DiaryWrite(
                        dateTime: settings.arguments as DateTime,
                      ));
          }
          return null;
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AIARY'),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, 'chat_daily',
                  arguments: DateTime.now()),
              icon: Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: context.watch<AppProv>().selectedWidget,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, 'chat_diary'),
          child: Icon(Icons.chat)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.summarize), label: 'Lists'),
        ],
        currentIndex: context.watch<AppProv>().index,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => context.read<AppProv>().index = index,
      ),
    );
  }
}
