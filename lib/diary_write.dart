import 'dart:developer';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/model/diary_model.dart';

import 'diary_storage.dart';

class DiaryWrite extends StatefulWidget {
  const DiaryWrite({Key? key, required this.diaryStorage}) : super(key: key);

  final DiaryStorage diaryStorage;

  @override
  State<DiaryWrite> createState() => _DiaryWriteState();
}

class _DiaryWriteState extends State<DiaryWrite> {
  final TextEditingController _textEditingController = TextEditingController();
  late DiaryModel _diaryModel = DiaryModel('', '', DateTime.now(), []);

  final _promptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content:
    '아래는 user가 일기를 쓰는 데 바탕이 될 대화야. 이것을 바탕으로 일기를 작성해줘',
  );

  @override
  void initState() {
    super.initState();
    widget.diaryStorage.readDiary().then((value) {
      setState(() {
        _diaryModel = value;
        _textEditingController.text = _diaryModel.content;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 쓰기'),
        actions: [
          IconButton(
              onPressed: () async {
                OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
                    .create(model: "gpt-3.5-turbo",
                    messages: [
                      _promptModel,
                      OpenAIChatCompletionChoiceMessageModel(
                        role: OpenAIChatMessageRole.user,
                        content: _diaryModel.chatLogs.toString(),
                      )
                ]);
                _textEditingController.text = chatCompletion.choices[0].message.content;
              },
              icon: Icon(Icons.create)),
          SizedBox(
            width: 8.0,
          ),
          IconButton(
              onPressed: () {
                _diaryModel.content = _textEditingController.text;
                widget.diaryStorage.writeDiary(_diaryModel);
              },
              icon: Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          // decoration: InputDecoration(
          //   hintText: 'Enter text...',
          // ),
          maxLines: null,
        ),
      ),
    );
  }
}
