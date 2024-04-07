import 'package:flutter/material.dart';

class UserInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보 입력 페이지'),
      ),
      body: Center(
        child: Text('여기에 사용자 정보 입력 내용'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context); // 현재 페이지를 닫고 이전 페이지로 돌아갑니다.
        },
      ),
    );
  }
}