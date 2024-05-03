import 'package:flutter/material.dart';
import 'HealthModePage.dart';

class MenuRecommendationPage extends StatefulWidget {
  final String mealTime;
  final String menu;

  const MenuRecommendationPage({Key? key, required this.mealTime, required this.menu}) : super(key: key);

  @override
  _MenuRecommendationPageState createState() => _MenuRecommendationPageState();
}

class _MenuRecommendationPageState extends State<MenuRecommendationPage> {
  bool _isHealthMode = false; // Added state for health mode toggle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModalBottomSheet();
    });
  }

  void toggleHealthMode() {
    bool newHealthMode = !_isHealthMode;  // Calculate the new mode state before navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthModePage(),
        settings: RouteSettings(arguments: newHealthMode),  // Pass the new state to HealthModePage
      ),
    ).then((returnedMode) {
      // Use the returnedMode to update the state if it is not null
      if (returnedMode != null) {
        setState(() {
          _isHealthMode = returnedMode as bool;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: <Widget>[
          IconButton(
            icon: Image.asset(_isHealthMode ? 'assets/images/on_button.png' : 'assets/images/off_button.png'),
            onPressed: toggleHealthMode,
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Implement navigation to MyPage
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(text: '고민하는 당신을 위해 준비했어요.\n오늘의 ${_translateMealTime(widget.mealTime)} 추천 메뉴는 '),
                    TextSpan(
                      text: '${widget.menu}',
                      style: TextStyle(fontSize: 25, color: Color(0xFF57BD85)),
                    ),
                    TextSpan(text: '!',
                        style: TextStyle(fontSize: 25, color: Color(0xFF57BD85))),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              width: 350,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/${widget.menu}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('이미지를 찾을 수 없습니다'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateMealTime(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return '아침';
      case 'lunch':
        return '점심';
      case 'dinner':
        return '저녁';
      default:
        return '식사';
    }
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          initialChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                controller: scrollController,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: Text('More details about ${widget.menu}. Scrollable map feature coming soon!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
