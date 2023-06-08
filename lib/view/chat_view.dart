import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/domain/diary.dart';
import 'package:flutter_openai/repository/diary_repository.dart';

class ChatView extends StatelessWidget {
  final TextEditingController textController;
  final Diary diary;
  final DiaryRepository diaryRepository;
  final OpenAIChatCompletionChoiceMessageModel prompt;

  const ChatView({
    Key? key,
    required this.textController,
    required this.diary,
    required this.diaryRepository,
    required this.prompt,
  }) : super(key: key);

  void handleSubmitted(String text, String type, BuildContext context) {
    if (text == '') {
      return;
    }
    diary.addChat({'content': text, 'role': type});
    textController.clear();
    if (type == 'user') {
      returnAnswer(text);
    }
    diaryRepository.writeDiary(diary);
  }

  void handleStream(Stream<OpenAIStreamChatCompletionModel> chatStream) {
    diary.addChatStream(chatStream).onDone(() {
      diaryRepository.writeDiary(diary);
    });
  }

  Future<void> returnAnswer(String text) async {
    Stream<OpenAIStreamChatCompletionModel> chatStream =
        OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: diary.chatLogs.length < 10
          ? [
              prompt,
              ...diary.chatLogs.map((e) =>
                  OpenAIChatCompletionChoiceMessageModel(
                      content: e['content'],
                      role: OpenAIChatMessageRole.values
                          .firstWhere((role) => role.name == e['role']))),
            ]
          : [
              prompt,
              ...diary.chatLogs.sublist(diary.chatLogs.length - 10).map((e) =>
                  OpenAIChatCompletionChoiceMessageModel(
                      content: e['content'],
                      role: OpenAIChatMessageRole.values
                          .firstWhere((role) => role.name == e['role'])))
            ],
    );
    handleStream(chatStream);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: diary.chatLogs.length,
            padding: EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(left: 14, right: 14, top: 8),
                child: Align(
                  alignment: diary.chatLogs[index]['role'] == 'user'
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: diary.chatLogs[index]['role'] == 'user'
                          ? Colors.blue[200]
                          : Colors.red[100],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Text(diary.chatLogs[index]['content']),
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
            data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: textController,
                      onSubmitted: (text) =>
                          handleSubmitted(text, 'user', context),
                      decoration:
                          InputDecoration.collapsed(hintText: 'Send a message'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () =>
                          handleSubmitted(textController.text, 'user', context),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
