import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';

import 'env/env.dart';


void main() {
  // OpenAI.apiKey = Env.apiKey;
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
  //   print(chatStreamEvent.choices[0].delta.content); // ...
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 10),
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 14, right: 14, top: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue[200],
                ),
                padding: EdgeInsets.all(12),
                child: Text('This is a message.'),
              ),
            ),
          );
        },
      )
    );
  }
}
