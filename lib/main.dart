import 'package:flutter/material.dart';
import 'dart:async';
import 'package:widget_spinning_wheel/widget_spinning_wheel.dart';
import 'MenuRecommendationPage.dart';
import 'HealthModePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// main color: 57BD85
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHealthMode = false; // Track the state of the Health Mode

  Future<List<String>> _getFoodItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('foods').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
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
        title: Text(""),
        actions: [
          IconButton(
            icon: Image.asset(_isHealthMode ? 'assets/images/on_button.png' : 'assets/images/off_button.png'),
            onPressed: toggleHealthMode,
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Optionally, navigate to a different page depending on additional conditions
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "점심, 뭐 먹을까?",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            FutureBuilder<List<String>>(
              future: _getFoodItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return WidgetSpinningWheel(
                    labels: snapshot.data!, // 수정: 가져온 음식 이름 데이터를 labels에 전달
                    onSpinComplete: (String label) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('오늘 점심은 이거다!'),
                            titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 30.0),
                            content: Text(
                              '$label',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                            actions: [
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFF57BD85),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // First, close the dialog
                                    Navigator.push( // Then, navigate to the next page.
                                      context,
                                      MaterialPageRoute(builder: (context) => MenuRecommendationPage(mealTime: "lunch", menu: label)),
                                    );
                                  },
                                  child: Text('확인'),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    size: 300,
                    colours: [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple], // Optional color customization
                    defaultSpeed: 0.3, // Optional speed adjustment
                  );
                } else {
                  // 추가: 데이터 로딩 중일 때 CircularProgressIndicator 표시
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

