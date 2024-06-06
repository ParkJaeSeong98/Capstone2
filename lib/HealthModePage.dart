import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'nutrients_list.dart';

Map<String, Map<String, String>> nutrientMessages = {
  'Carbohydrates': {
    '조금': '탄수화물 섭취량이 부족하면 에너지 부족으로 이어질 수 있습니다.',
    '보통': '적절한 탄수화물 섭취는 건강한 식단에 중요합니다.',
    '많이': '너무 많은 탄수화물을 섭취할 시 혈당이 급격하게 상승할 수 있습니다.',
  },
  'Protein': {
    '조금': '단백질 섭취량이 부족하면 근육량 유지에 어려움이 있을 수 있습니다.',
    '보통': '충분한 단백질 섭취는 근육 성장과 유지에 도움이 됩니다.',
    '많이': '과도한 단백질 섭취는 신장에 부담을 줄 수 있습니다.',
  },
  'Fats': {
    '조금': '지방 섭취량이 너무 적으면 호르몬 불균형이 생길 수 있습니다.',
    '보통': '적절한 지방 섭취는 건강한 호르몬 밸런스에 도움이 됩니다.',
    '많이': '과도한 지방 섭취는 비만과 심혈관 질환의 위험을 높일 수 있습니다.',
  },
};

Map<String, String> nutrientRecommendations = {
  'Carbohydrates': '하루 권장 섭취량: 300g',
  'Protein': '하루 권장 섭취량: 60g',
  'Fats': '하루 권장 섭취량: 55g',
};

class HealthModePage extends StatefulWidget {
  @override
  _HealthModePageState createState() => _HealthModePageState();
}

class _HealthModePageState extends State<HealthModePage> {
  Future<void> loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String carbohydratesLevel = prefs.getString('carbohydratesLevel') ?? '';
    String proteinLevel = prefs.getString('proteinLevel') ?? '';
    String fatsLevel = prefs.getString('fatsLevel') ?? '';

    List<String> savedNutrients = prefs.getStringList('addedNutrients') ?? [];

    setState(() {
      selectedLevels['Carbohydrates'] = carbohydratesLevel;
      selectedLevels['Protein'] = proteinLevel;
      selectedLevels['Fats'] = fatsLevel;
      addedNutrients.addAll(savedNutrients);
    });
  }

  Future<void> saveUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('carbohydratesLevel', selectedLevels['Carbohydrates'] ?? '');
    await prefs.setString('proteinLevel', selectedLevels['Protein'] ?? '');
    await prefs.setString('fatsLevel', selectedLevels['Fats'] ?? '');

    await prefs.setStringList('addedNutrients', addedNutrients);
  }

  final Map<String, String> nutrientImages = {
    'Carbohydrates': 'assets/images/carbohydrates.png',
    'Protein': 'assets/images/protein.png',
    'Fats': 'assets/images/fats.png',
  };

  Map<String, String> selectedLevels = {
    'Carbohydrates': '',
    'Protein': '',
    'Fats': '',
  };

  final List<String> intakeLevels = ['조금', '보통', '많이'];
  final List<String> addedNutrients = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Mode"),
        automaticallyImplyLeading: false, // 화살표 숨기기
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRichTextHeader(),
              buildNutrientSelection(),
              buildSearchAddNutrient(),
              buildNutrientBasket(),
              SizedBox(height: 150), // 여유 공간 추가
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // 원하는 배경색으로 설정
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 5),
              ),
              onPressed: () async {
                await saveUserPreferences();
                Navigator.pop(context);
              },
              child: Text(
                '저장',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Padding buildRichTextHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: '건강한 식습관 ', style: TextStyle(color: Color(0xFF57BD85))),
            TextSpan(text: '만들기\n당신의 '),
            TextSpan(text: '도움이 필요', style: TextStyle(color: Color(0xFF57BD85))),
            TextSpan(text: '해요.'),
          ],
        ),
      ),
    );
  }

  Column buildNutrientSelection() {
    return Column(
      children: [
        ...nutrientImages.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 25),
              Image.asset(entry.value, width: 100, height: 100, fit: BoxFit.contain),
              SizedBox(width: 6),
              ...intakeLevels.map((level) => buildLevelSelector(entry, level)).toList(),
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(entry.key),
                        content: Text(nutrientRecommendations[entry.key]!),
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
                },
              ),
            ],
          ),
        )).toList(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            selectedMessage,
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String selectedMessage = '';

  Padding buildLevelSelector(MapEntry<String, String> entry, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedLevels[entry.key] = level;
                selectedMessage = nutrientMessages[entry.key]![level]!;
              });
              saveUserPreferences();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedLevels[entry.key] == level ? Color(0xFF57BD85) : Colors.transparent,
                border: Border.all(color: Color(0xFF57BD85), width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(level, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Column buildSearchAddNutrient() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "기타 영양소 검색",
              ),
            ),
            suggestionsCallback: (pattern) {
              return nutrients.where((nutrient) => nutrient.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              setState(() {
                addedNutrients.add(suggestion);
                searchController.clear();
              });
              saveUserPreferences(); // 추가
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            hideOnLoading: false,
            keepSuggestionsOnLoading: true,
          ),
        ),
      ],
    );
  }

  Widget buildNutrientBasket() {
    return Column(
      children: addedNutrients.map((nutrient) => ListTile(
        title: Text(nutrient),
        trailing: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              addedNutrients.remove(nutrient);
            });
          },
        ),
      )).toList(),
    );
  }
}
