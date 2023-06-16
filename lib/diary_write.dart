import 'dart:convert';
import 'dart:developer';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/model/diary_model.dart';
import 'package:http/http.dart' as http;

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
    content: '아래는 user가 일기를 쓰는 데 바탕이 될 대화야. 이것을 바탕으로 일기를 작성해줘',
  );

  final _summaryPromptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content: '입력은 사용자의 일기야. 이것을 5문장 이내로 요약해줘.',
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

  Future<void> diaryToDB() async {
    OpenAIEmbeddingsModel embeddings = await OpenAI.instance.embedding.create(
      model: "text-embedding-ada-002",
      input: _diaryModel.content,
    );
    var date =
        "${_diaryModel.dateTime.year}년${_diaryModel.dateTime.month}월${_diaryModel.dateTime.day}일 ";
    final vector = embeddings.data[0].embeddings;
    var url = Uri.parse(
        'https://my-capstone-f9fj7zjf.weaviate.network/v1/batch/objects?consistency_level=ALL');
    var data = {
      "objects": [
        {
          "class": "Diary",
          "properties": {"content": date + _diaryModel.content},
          "vector": vector
        }
      ]
    };
    http.post(url,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        log('요청이 성공하였습니다.');
      } else {
        log('요청이 실패하였습니다. 상태 코드: ${response.statusCode}');
      }
    }).catchError((error) {
      log('오류가 발생하였습니다: $error');
    });
  }

  @override
  void dispose() {
    _diaryModel.content = _textEditingController.text;
    widget.diaryStorage.writeDiary(_diaryModel);
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
              onPressed: () {
                var sb = StringBuffer();
                Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI
                    .instance.chat
                    .createStream(model: "gpt-3.5-turbo", messages: [
                  _promptModel,
                  OpenAIChatCompletionChoiceMessageModel(
                    role: OpenAIChatMessageRole.user,
                    content: _diaryModel.chatLogs.toString(),
                  )
                ]);
                chatStream.listen((chatStreamEvent) {
                  var s = chatStreamEvent.choices[0].delta.content;
                  if (s != null) {
                    sb.write(s);
                    _textEditingController.text = sb.toString();
                  }
                });
                // _textEditingController.text =
                //     chatCompletion.choices[0].message.content;
              },
              icon: Icon(Icons.create)),
          SizedBox(
            width: 8.0,
          ),
          IconButton(
              onPressed: () async {
                _diaryModel.content = _textEditingController.text;
                OpenAIChatCompletionModel summaryCompletion = await OpenAI
                    .instance.chat
                    .create(model: "gpt-3.5-turbo", messages: [
                  _summaryPromptModel,
                  OpenAIChatCompletionChoiceMessageModel(
                    role: OpenAIChatMessageRole.user,
                    content: _diaryModel.content,
                  )
                ]);
                _diaryModel.summary =
                    summaryCompletion.choices[0].message.content;
                diaryToDB();
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
