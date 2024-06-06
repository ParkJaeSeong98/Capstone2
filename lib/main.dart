import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'custom_spinning_wheel.dart';
import 'MenuRecommendationPage.dart';
import 'HealthModePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

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
      const Duration(seconds: 2),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 30),
            Text(
              '뭘 먹을지 고민이라면?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '푸드 컴퍼스',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHealthMode = false;
  List<String> _foodItems = [];
  Map<String, Map<String, dynamic>> _cachedNutrients = {};

  int radius = 3000;

  Future<void> _fetchFoodItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('foods').get();
    setState(() {
      _foodItems = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });

    // 음식 영양 성분 미리 가져오기
    for (String foodItem in _foodItems) {
      _cachedNutrients[foodItem] = await _fetchFoodNutrients(foodItem);
    }
  }

  String getMealTimeText() { // 시간 가져오는 메서드
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 6 && hour < 10) {
      return '아침';
    } else if (hour >= 10 && hour < 11) {
      return '아점';
    } else if (hour >= 11 && hour < 14) {
      return '점심';
    } else if (hour >= 14 && hour < 16) {
      return '이른 저녁';
    } else if (hour >= 16 && hour < 21) {
      return '저녁';
    } else {
      return '야식';
    }
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<Map<String, dynamic>> _fetchFoodNutrients(String foodName) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('foods').doc(foodName).get();

    if (snapshot.exists) {
      Map<String, dynamic> nutrients = {};

      DocumentSnapshot superSnapshot = await snapshot.reference.collection('nutrients').doc('nutrients').collection('super').doc('super').get();
      nutrients['carbohydrate'] = superSnapshot.get('carbohydrate');
      nutrients['protein'] = superSnapshot.get('protein');
      nutrients['fat'] = superSnapshot.get('fat');

      QuerySnapshot subSnapshot = await snapshot.reference.collection('nutrients').doc('nutrients').collection('sub').get();
      for (QueryDocumentSnapshot doc in subSnapshot.docs) {
        nutrients.addAll(doc.data() as Map<String, dynamic>);
      }

      return nutrients;
    }

    return {};
  }

  bool _matchesNutrientLevel(dynamic value, String level) {
    if (value == null) return false;

    double nutrientValue = value.toDouble();

    switch (level) {
      case '조금':
        return nutrientValue <= 5;
      case '보통':
        return nutrientValue > 5 && nutrientValue <= 10;
      case '많이':
        return nutrientValue > 10;
      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _toggleHealthMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String carbohydratesLevel = prefs.getString('carbohydratesLevel') ?? '';
    String proteinLevel = prefs.getString('proteinLevel') ?? '';
    String fatsLevel = prefs.getString('fatsLevel') ?? '';
    List<String> savedNutrients = prefs.getStringList('addedNutrients') ?? [];

    bool hasUserPreferences = carbohydratesLevel.isNotEmpty || proteinLevel.isNotEmpty || fatsLevel.isNotEmpty || savedNutrients.isNotEmpty;

    if (hasUserPreferences) {
      setState(() {
        _isHealthMode = !_isHealthMode;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthModePage(),
          settings: RouteSettings(arguments: _isHealthMode),
        ),
      ).then((returnedMode) {
        if (returnedMode != null) {
          setState(() {
            _isHealthMode = returnedMode as bool;
          });
        }
      });
    }
  }

  Future<void> _editHealthMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool newHealthMode = !_isHealthMode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthModePage(),
        settings: RouteSettings(arguments: newHealthMode),
      ),
    ).then((returnedMode) {
      if (returnedMode != null) {
        setState(() {
          _isHealthMode = returnedMode as bool;
        });
      }
    });
  }

  void _spinRoulette() async {
    if (_foodItems.isEmpty) return;

    String? selectedItem;
    List<String> filteredFoodItems = [];

    if (_isHealthMode) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String carbohydratesLevel = prefs.getString('carbohydratesLevel') ?? '';
      String proteinLevel = prefs.getString('proteinLevel') ?? '';
      String fatsLevel = prefs.getString('fatsLevel') ?? '';
      List<String> savedNutrients = prefs.getStringList('addedNutrients') ?? [];

      for (String foodItem in _foodItems) {
        Map<String, dynamic> nutrients = _cachedNutrients[foodItem] as Map<String, dynamic>;

        bool matchesCarbohydrates = _matchesNutrientLevel(nutrients['carbohydrate'], carbohydratesLevel);
        bool matchesProtein = _matchesNutrientLevel(nutrients['protein'], proteinLevel);
        bool matchesFats = _matchesNutrientLevel(nutrients['fat'], fatsLevel);

        bool containsSavedNutrients = savedNutrients.every((savedNutrient) {
          return nutrients.keys.any((nutrient) {
            return nutrient.contains(savedNutrient) && nutrients[nutrient] > 0;
          });
        });

        if (matchesCarbohydrates && matchesProtein && matchesFats && containsSavedNutrients) {
          filteredFoodItems.add(foodItem);
        }
      }

      if (filteredFoodItems.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(filteredFoodItems.length);
        selectedItem = filteredFoodItems[randomIndex];
      }
    } else {
      // HealthMode OFF: 전체 음식 중에서 랜덤 선택
      final random = Random();
      final randomIndex = random.nextInt(_foodItems.length);
      selectedItem = _foodItems[randomIndex];
    }

    if (_isHealthMode && filteredFoodItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(16),
            contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text('알림'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/crying_cat.png',
                    width: 400,
                    height: 200,
                  ),
                  SizedBox(height: 16),
                  Text('조건에 맞는 음식이 없습니다.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String mealTimeText = getMealTimeText();
          return AlertDialog(
            title: Text('오늘 $mealTimeText은 이거다!'),
            titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 30.0),
            content: Text(
              '$selectedItem',
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
                      MaterialPageRoute(builder: (context) => MenuRecommendationPage(mealTime: mealTimeText, menu: selectedItem!, radius: radius)),
                    );
                  },
                  child: Text('확인'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateAndSelectRadius() async {
    final selectedRadius = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectRadiusPage()),
    );

    if (selectedRadius != null) {
      setState(() {
        radius = selectedRadius * 1000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String mealTimeText = getMealTimeText();
    String currentTime = getCurrentTime();
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: _navigateAndSelectRadius,
        ),
        actions: [
          IconButton(
            icon: Image.asset(_isHealthMode ? 'assets/images/on_button.png' : 'assets/images/off_button.png'),
            onPressed: _toggleHealthMode,
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _editHealthMode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오늘 $mealTimeText은 이거다!',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),),
            SizedBox(height: 50),
            _foodItems.isEmpty
                ? CircularProgressIndicator()
                : CustomSpinningWheel(
              size: 300,
              onSpinComplete: _spinRoulette,
              spinSpeed: 0.2,
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class SelectRadiusPage extends StatefulWidget {
  @override
  _SelectRadiusPageState createState() => _SelectRadiusPageState();
}

class _SelectRadiusPageState extends State<SelectRadiusPage> {
  int _selectedRadius = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식당 검색 반경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var radius in [1, 3, 5, 10])
              ListTile(
                title: Text(
                  '$radius km',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: radius == 3 ? FontWeight.bold : FontWeight.normal,
                    color: radius == 3 ? Colors.blue : Colors.black,
                  ),
                ),
                leading: Radio<int>(
                  value: radius,
                  groupValue: _selectedRadius,
                  onChanged: (value) {
                    setState(() {
                      _selectedRadius = value!;
                    });
                    Navigator.pop(context, _selectedRadius);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}