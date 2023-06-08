import 'dart:convert';
import 'dart:developer';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/app_provider.dart';
import 'package:flutter_openai/domain/diary.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DiaryWrite extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();
  final DateTime dateTime;

  DiaryWrite({Key? key, required this.dateTime}) : super(key: key);

  final promptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content: '아래는 user가 일기를 쓰는 데 바탕이 될 대화야. 이것을 바탕으로 일기를 작성해줘',
  );

  final summaryPromptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content: '입력은 사용자의 일기야. 이것을 5문장 이내로 요약해줘.',
  );

  Future<void> diaryToDB(Diary diary) async {
    OpenAIEmbeddingsModel embeddings = await OpenAI.instance.embedding.create(
      model: "text-embedding-ada-002",
      input: diary.content,
    );
    var date =
        "${diary.dateTime.year}년${diary.dateTime.month}월${diary.dateTime.day}일 ";
    final vector = embeddings.data[0].embeddings;
    var url = Uri.parse(
        'https://my-test-db-yr9cmy7h.weaviate.network/v1/batch/objects?consistency_level=ALL');
    var data = {
      "objects": [
        {
          "class": "Diary",
          "properties": {"content": date + diary.content},
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 쓰기'),
        actions: [
          IconButton(
              onPressed: () {
                var diary = context.read<Diary>();
                var sb = StringBuffer();
                Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI
                    .instance.chat
                    .createStream(model: "gpt-3.5-turbo", messages: [
                  promptModel,
                  OpenAIChatCompletionChoiceMessageModel(
                    role: OpenAIChatMessageRole.user,
                    content: diary.chatLogs.toString(),
                  )
                ]);
                chatStream.listen((chatStreamEvent) {
                  var s = chatStreamEvent.choices[0].delta.content;
                  if (s != null) {
                    sb.write(s);
                    textEditingController.text = sb.toString();
                  }
                });
              },
              icon: Icon(Icons.create)),
          SizedBox(
            width: 8.0,
          ),
          IconButton(
              onPressed: () async {
                var diary = context.read<Diary>();
                diary.content = textEditingController.text;
                OpenAIChatCompletionModel summaryCompletion = await OpenAI
                    .instance.chat
                    .create(model: "gpt-3.5-turbo", messages: [
                  summaryPromptModel,
                  OpenAIChatCompletionChoiceMessageModel(
                    role: OpenAIChatMessageRole.user,
                    content: diary.content,
                  )
                ]);
                diary.summary = summaryCompletion.choices[0].message.content;
                diaryToDB(diary);
                if (context.mounted) {
                  context.read<AppProv>().diaryRepo.writeDiary(diary);
                }
              },
              icon: Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: textEditingController,
          // decoration: InputDecoration(
          //   hintText: 'Enter text...',
          // ),
          maxLines: null,
        ),
      ),
    );
  }
}
