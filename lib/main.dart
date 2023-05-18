import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/chat.dart';
import 'package:flutter_openai/diary_storage.dart';
import 'package:flutter_openai/diary_write.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'calendar.dart';
import 'setting.dart';
import 'summary.dart';
import 'env/env.dart';

void main() {
  OpenAI.apiKey = Env.apiKey;
  // Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
  //   model: "gpt-3.5-turbo",
  //   messages: [
  //     const OpenAIChatCompletionChoiceMessageModel(
  //       content: "hello",
  //       role: OpenAIChatMessageRole.user,
  //     )
  //   ],
  // );
  //
  // chatStream.listen((chatStreamEvent) {
  //   print(chatStreamEvent.choices[0].delta.content);
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIARY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  static const _widgetOptions = <Widget>[
    Calendar(),
    Summary(),
    Setting(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AIARY')),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex < 2
          ? SpeedDial(
              icon: Icons.add,
              renderOverlay: false,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.chat_bubble),
                  backgroundColor: Colors.blue[400],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          diaryStorage: DiaryStorage(dateTime: DateTime.now()),
                        ),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.note_add),
                  backgroundColor: Colors.blue[400],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryWrite(),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.summarize), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
