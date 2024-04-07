import 'package:flutter/material.dart';

// 사용자 정보 위젯
class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이 페이지'),
      ),
      body: Center(
        child: Text('사용자 정보 및 습관 추적표'),
      ),
    );
  }
}