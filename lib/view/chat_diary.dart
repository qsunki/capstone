import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:path_provider/path_provider.dart';

class ChatDiary extends StatefulWidget {
  const ChatDiary({Key? key}) : super(key: key);

  @override
  State<ChatDiary> createState() => _ChatDiaryState();
}

class _ChatDiaryState extends State<ChatDiary> {
  final HttpLink httpLink =
      HttpLink('https://my-test-db-yr9cmy7h.weaviate.network/v1/graphql');
  late GraphQLClient client =
      GraphQLClient(link: httpLink, cache: GraphQLCache());
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> chatLogs = [];


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path/diaryChatLogs.json');
  }

  Future<List<Map<String, dynamic>>> readChatLog() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final json = jsonDecode(contents);
    return json.cast<Map<String, dynamic>>();
  }

  Future<File> writeChatLogs(List<Map<String, dynamic>> chatLogs) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(chatLogs));
  }

  void handleSubmitted(String text, String type) {
    if (text == '') {
      return;
    }
    setState(() {
      chatLogs.add({'role': type, 'content': text});
      _textController.clear();
    });
    if (type == 'user') {
      returnAnswer(text);
    }
    writeChatLogs(chatLogs);
  }

  void handleStream(Stream<OpenAIStreamChatCompletionModel> chatStream) {
    StringBuffer sb = StringBuffer();
    var tmp = {'role': 'assistant', 'content': sb.toString()};
    chatLogs.add(tmp);
    chatStream.listen((chatStreamEvent) {
      setState(() {
        var s = chatStreamEvent.choices[0].delta.content;
        if (s != null) {
          sb.write(s);
          chatLogs.last['content'] = sb.toString();
        }
      });
    }).onDone(() {writeChatLogs(chatLogs);});
  }

  Future<void> returnAnswer(String text) async {
    OpenAIEmbeddingsModel embeddings = await OpenAI.instance.embedding.create(
      model: "text-embedding-ada-002",
      input: text,
    );
    final vector = embeddings.data[0].embeddings;
    final k = 1;
    final String query = '''
{
  Get {
    Diary(
      nearVector: { vector: $vector}
      limit: $k
    ) {
      content
    }
  }
}
''';
    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult result = await client.query(options);
    var foundDiary = result.data!['Get']['Diary'][0]['content'];
    final promptModel = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: '너는 사용자의 일기를 검색하여 찾아주는 일종의 검색엔진이야. 다음은 사용자 질문에 따라 찾아낸 과거의 사용자의 일기야. 너는 이것을 바탕으로 아는 것을 말해줘.\n일기 : $foundDiary',
    );
    var userMessageModel = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: text,
    );
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(
            model: "gpt-3.5-turbo", messages: [promptModel, userMessageModel]);

    handleStream(chatStream);
    // handleSubmitted(chatCompletion.choices[0].message.content, 'assistant');
  }

  @override
  void initState() {
    readChatLog().then((value) {
      setState(() {
        chatLogs = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('일기에게 물어보기'),
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: chatLogs.length,
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(left: 14, right: 14, top: 8),
                    child: Align(
                      alignment: chatLogs[index]['role'] == 'user'
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: chatLogs[index]['role'] == 'user'
                              ? Colors.blue[200]
                              : Colors.red[100],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Text(chatLogs[index]['content']),
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
