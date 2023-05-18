import 'package:flutter/material.dart';

class DiaryWrite extends StatelessWidget {
  const DiaryWrite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 쓰기'),
      ),
      body: Center(
        child: TextField(),
      ),
    );
  }
}
