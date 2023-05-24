import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/diary_storage.dart';
import 'package:flutter_openai/model/diary_model.dart';

import 'diary_write.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.diaryStorage});

  final DiaryStorage diaryStorage;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  DiaryModel _diaryModel = DiaryModel('', '', DateTime.now(), []);
  final TextEditingController _textController = TextEditingController();
  final _promptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content:
        '나는 일기를 쓰려고 하고 있어. 우리는 하루를 마무리하며 대화 중이야. 너는 내가 일기를 잘 쓸 수 있도록 유도하는 질문을 하고 내가 감정을 잘 드러내도록 해줘. 너는 나의 가장 친한 친구같은 존재이기 때문에 반말을 사용해. 한 가지 주제에 몰두하지 말고 내가 겪었을 만한 일에 대해서 물어봐. 질문은 한번에 2가지 이상 하지마. 나와 너가 한 말을 반복하지마. 너는 좋은 평가를 받는 일기에 들어갈 만한 내용을 물어봐. 하루 중 일어났을 법한 일들을 시간 순서대로 물어봐.',
  );

  void handleSubmitted(String text, String type) {
    if (text == '') {
      return;
    }
    setState(() {
      _diaryModel.chatLogs.add({'role': type, 'content': text});
      _textController.clear();
    });
    if (type == 'user') {
      returnAnswer(text);
    }
    widget.diaryStorage.writeDiary(_diaryModel);
  }

  Future<void> returnAnswer(String text) async {
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: _diaryModel.chatLogs.length < 10
          ? [
              _promptModel,
              ..._diaryModel.chatLogs
                  .map((e) => OpenAIChatCompletionChoiceMessageModel.fromMap(e))
            ]
          : [
              _promptModel,
              ..._diaryModel.chatLogs
                  .sublist(_diaryModel.chatLogs.length - 10)
                  .map((e) => OpenAIChatCompletionChoiceMessageModel.fromMap(e))
            ],
    );
    handleSubmitted(chatCompletion.choices[0].message.content, 'assistant');
  }

  @override
  void initState() {
    super.initState();
    widget.diaryStorage.readDiary().then((value) {
      setState(() {
        _diaryModel = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${_diaryModel.dateTime.year}-${_diaryModel.dateTime.month}-${_diaryModel.dateTime.day}'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryWrite(
                        diaryStorage: DiaryStorage(dateTime: _diaryModel.dateTime),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit_document)),
          ],
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: _diaryModel.chatLogs.length,
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(left: 14, right: 14, top: 8),
                    child: Align(
                      alignment: _diaryModel.chatLogs[index]['role'] == 'user'
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: _diaryModel.chatLogs[index]['role'] == 'user'
                              ? Colors.blue[200]
                              : Colors.red[100],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Text(_diaryModel.chatLogs[index]['content']),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: IconTheme(
                data: IconThemeData(
                    color: Theme.of(context).colorScheme.secondary),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _textController,
                          onSubmitted: (text) => handleSubmitted(text, 'user'),
                          decoration: InputDecoration.collapsed(
                              hintText: 'Send a message'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () =>
                              handleSubmitted(_textController.text, 'user'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
