import 'package:dart_openai/dart_openai.dart';
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
    content: '''너는 일기 작성을 도와주는 assistant야
항상 대화의 시작은 잘잤냐고 물어봐줘
1. assistant는 나와 가장 친한 친구라고 생각하고 대화해줘.
2. 반드시 반말을 사용해.
3. 나의 답변을 종합하여 일기로 만들거야.
4. 나의 대화는 지금까지 있었던 자전적인 내용이야.
5-1. 먼저 오늘 뭐했는지 물어봐줘.
5-2. 질문은 통해서 오늘 한일에 대해 세부적인 내용이나 감정을 간접적으로 물어봐줘.
5-3. 6번 항목을 하나의 세트로 하나의 세트가 끝난 다면 다시 5-1 부터 시작해줘.
6. user가 일기 쓰는 것을 멈추고 싶어할 때 대화를 종료해야해. 그렇지 않다면 계속해서 5번 항목을 반복해줘.
7. 사용자가 답변을 거부하면, 5-1로 돌아가 세트를 다시 시작해줘.''',
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

  void handleStream(Stream<OpenAIStreamChatCompletionModel> chatStream) {
    StringBuffer sb = StringBuffer();
    var tmp = {'role': 'assistant', 'content': sb.toString()};
    _diaryModel.chatLogs.add(tmp);
    chatStream.listen((chatStreamEvent) {
      setState(() {
        var s = chatStreamEvent.choices[0].delta.content;
        if (s != null) {
          sb.write(s);
          _diaryModel.chatLogs.last['content'] = sb.toString();
        }
      });
    }).onDone(() {
      widget.diaryStorage.writeDiary(_diaryModel);
    });
  }

  Future<void> returnAnswer(String text) async {
    Stream<OpenAIStreamChatCompletionModel> chatStream =
        OpenAI.instance.chat.createStream(
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
    handleStream(chatStream);
    // handleSubmitted(chatCompletion.choices[0].message.content, 'assistant');
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
                        diaryStorage:
                            DiaryStorage(dateTime: _diaryModel.dateTime),
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
                              ? Color(0xFFDAE8FA)
                              : Color(0xFFFDF1D8),
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
