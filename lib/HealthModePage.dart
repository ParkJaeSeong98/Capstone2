import 'package:flutter/material.dart';

class HealthModePage extends StatefulWidget {
  @override
  _HealthModePageState createState() => _HealthModePageState();
}

class _HealthModePageState extends State<HealthModePage> {

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Mode"),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/on_button.png'),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: [
          buildRichTextHeader(),
          buildNutrientSelection(),
          buildSearchAddNutrient(),
          buildNutrientBasket(),
        ],
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
      children: nutrientImages.entries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 25),
            Image.asset(entry.value, width: 100, height: 100, fit: BoxFit.contain),
            SizedBox(width: 6),
            ...intakeLevels.map((level) => buildLevelSelector(entry, level)).toList(),
          ],
        ),
      )).toList(),
    );
  }

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
              });
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
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Search Nutrients",
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (searchController.text.isNotEmpty) {
                      addedNutrients.add(searchController.text);
                      searchController.clear();
                    }
                  });
                },
              ),
            ),
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
