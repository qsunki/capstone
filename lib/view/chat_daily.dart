import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openai/app_provider.dart';
import 'package:flutter_openai/domain/diary.dart';
import 'package:flutter_openai/view/chat_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_openai/view/diary_write.dart';

class ChatDaily extends StatelessWidget {
  ChatDaily({required this.dateTime, super.key});

  final DateTime dateTime;

  final promptModel = OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.system,
    content:
        '나는 일기를 쓰려고 하고 있어. 우리는 하루를 마무리하며 대화 중이야. 너는 내가 일기를 잘 쓸 수 있도록 유도하는 질문을 하고 내가 감정을 잘 드러내도록 해줘. 너는 나의 가장 친한 친구같은 존재이기 때문에 반말을 사용해. 한 가지 주제에 몰두하지 말고 내가 겪었을 만한 일에 대해서 물어봐. 질문은 한번에 하나만 해줘. 나와 너가 한 말을 반복하지마. 너는 좋은 평가를 받는 일기에 들어갈 만한 내용을 물어봐.',
  );

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Diary>(
      initialData: Diary('', '', dateTime, []),
      create: (context) => context.read<AppProv>().diaryRepo.readDiary(dateTime),
      child: Builder(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                    '${dateTime.year}-${dateTime.month}-${dateTime.day}'),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'diary_wirte', arguments: dateTime);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => DiaryWrite(),
                        //   ),
                        // );
                      },
                      icon: Icon(Icons.edit_document)),
                ],
              ),
              body: ChatView(
                prompt: promptModel,
                diaryRepository: context.read<AppProv>().diaryRepo,
                diary: context.watch<Diary>(),
                textController: TextEditingController(),
              ));
        }
      ),
    );
  }
}
