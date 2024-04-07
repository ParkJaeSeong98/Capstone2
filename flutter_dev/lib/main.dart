import 'package:flutter/material.dart';
import 'user_info_page.dart';
import 'user_input_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isButtonEnabled = true; // 버튼 on/off 상태

  void _navigateToUserInputPage() { // 확인 버튼 클릭 후 사용자 정보 입력 페이지 이동 메서드
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInputPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('시작 페이지'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isButtonEnabled ? Icons.lightbulb_outline : Icons.lightbulb),
            onPressed: () {
              if (_isButtonEnabled) {
                _navigateToUserInputPage(); // 전구 아이콘이 켜져 있을 때만 페이지 이동
              }
              setState(() {
                _isButtonEnabled = !_isButtonEnabled;
              });
            },
          ),
          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoPage()),
                );
              }, 
              icon: Icon(Icons.account_circle),
          )
        ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3, // 룰렛이 차지하는 영역 비율
            child: Center(
              // 여기에 룰렛 위젯을 배치해야함.
              child: Text('룰렛'),
            ),
          ),
          Divider( // 구분선
            color: Colors.grey,
            thickness: 2, // 선의 두께 설정
          ),
          Expanded(
            flex: 2, // 찾기 버튼이 차지하는 영역 비율
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 찾기 버튼 이벤트 처리 로직
                },
                child: Text('찾기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}