// import 'package:flutter_openai/diary_storage.dart';
// import 'package:flutter_openai/env/env.dart';
import 'dart:convert';

import 'package:dart_openai/openai.dart';
import 'package:graphql/client.dart';


import 'package:http/http.dart' as http;

import 'env/env.dart';

void main() {
  OpenAI.apiKey = Env.apiKey;
  Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
    model: "gpt-3.5-turbo",
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: "hello",
        role: OpenAIChatMessageRole.user,
      )
    ],
  );

  chatStream.listen((chatStreamEvent) {
    print(chatStreamEvent.choices[0].delta.content); // ...
  });
  //
  // // POST 요청을 보낼 엔드포인트 URL
  // var url = Uri.parse('https://my-test-db-yr9cmy7h.weaviate.network/v1/batch/objects?consistency_level=ALL');
  //
  // // 전송할 데이터
  // var data = {
  //   "objects": [{
  //     "class": "Diary",
  //     "properties": {
  //       "content": "안녕하세요."
  //     },
  //     "vector": [0.1, 0.12, 0.22]
  //   }]
  // };
  //
  // // POST 요청 전송
  // http.post(url, body: jsonEncode(data), headers: {'Content-Type': 'application/json'}).then((response) {
  //   if (response.statusCode == 200) {
  //     print('요청이 성공하였습니다.');
  //     print(response.body);
  //   } else {
  //     print('요청이 실패하였습니다. 상태 코드: ${response.statusCode}');
  //   }
  // }).catchError((error) {
  //   print('오류가 발생하였습니다: $error');
  // });
}


// Future<void> main() async {
//   // DateTime dt = DateTime(2023, 5, 24);
//   // var diaryStorage = DiaryStorage(dateTime: dt);
//   // var readDiary = diaryStorage.readDiary();
//   final HttpLink httpLink = HttpLink('https://my-test-db-yr9cmy7h.weaviate.network/v1/graphql');
//
//   final GraphQLClient client = GraphQLClient(link: httpLink, cache: GraphQLCache());
//   final k = 1;
//   final String query = '''
// {
//   Get {
//     Diary(
//       limit: $k
//     ) {
//       content
//     }
//   }
// }
// ''';
//   final QueryOptions options = QueryOptions(document: gql(query));
//   final QueryResult result = await client.query(options);
//   if (result.hasException) {
//     print('error');
//     print(result);
//     print('\n');
//     print(result.exception.toString());
//   } else {
//     print('good');
//     print(result.data);
//   }
//
// }