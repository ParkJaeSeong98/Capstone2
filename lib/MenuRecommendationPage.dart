import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'HealthModePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// for kakaomap API
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NutrientInfoPage extends StatelessWidget {
  final String foodName;
  final Map<String, dynamic> nutrients;
  final List<String> selectedNutrients;

  const NutrientInfoPage({
    Key? key,
    required this.foodName,
    required this.nutrients,
    required this.selectedNutrients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, dynamic>> otherNutrients = nutrients.entries
        .where((entry) => !['에너지', '탄수화물', '단백질', '지방'].contains(entry.key))
        .toList();

    // 사용자가 선택한 기타영양소와 일치하는 영양소를 맨 위로 이동
    otherNutrients.sort((a, b) {
      bool aContainsSelected = selectedNutrients.any((selectedNutrient) =>
          a.key.replaceAll(' ', '').contains(selectedNutrient.replaceAll(' ', '')));
      bool bContainsSelected = selectedNutrients.any((selectedNutrient) =>
          b.key.replaceAll(' ', '').contains(selectedNutrient.replaceAll(' ', '')));

      if (aContainsSelected && !bContainsSelected) {
        return -1;
      } else if (!aContainsSelected && bContainsSelected) {
        return 1;
      } else {
        return 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$foodName 영양소 정보'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('주요 영양소'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('에너지: ${nutrients['에너지']}'),
                Text('탄수화물: ${nutrients['탄수화물']}'),
                Text('단백질: ${nutrients['단백질']}'),
                Text('지방: ${nutrients['지방']}'),
              ],
            ),
          ),
          ListTile(
            title: Text('기타 영양소'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: otherNutrients.map((entry) {
                final isSelected = selectedNutrients.any((selectedNutrient) =>
                    entry.key.replaceAll(' ', '').contains(selectedNutrient.replaceAll(' ', '')));
                return Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuRecommendationPage extends StatefulWidget {
  final String mealTime;
  final String menu;

  const MenuRecommendationPage({Key? key, required this.mealTime, required this.menu}) : super(key: key);

  @override
  _MenuRecommendationPageState createState() => _MenuRecommendationPageState();
}

class _MenuRecommendationPageState extends State<MenuRecommendationPage> {
  bool _isHealthMode = false; // Added state for health mode toggle
  bool _isLoading = true;

  final String apiKey = 'd743ba7caedcdefb200416fd7e9fffa9';
  final int radius = 3000; // 3km 반경 내에서 검색
  List<dynamic> restaurants = [];

  Position? position;
  //Set<Marker> markers = {};
  late KakaoMapController mapController;

  @override
  void initState() {
    super.initState();
    AuthRepository.initialize(appKey: 'ef3b44bb326c11d6d6e504f3253729ee');  // 지도 띄우기 위한 API KEY
    _initRestaurants();
  }

  // 비동기 메서드 이름 변경 및 호출 방법 수정
  Future<void> _initRestaurants() async {
    //restaurants = [];
    position = await getCurrentLocation();
    await _getNearbyRestaurants(position!); // await을 사용하여 데이터 로드 완료까지 기다림

    setState(() {
      _isLoading = false; // 로딩 상태 종료
    });
    print(restaurants);
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
            GestureDetector(
              onTap: !_isLoading ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //builder: (context) => Static2MarkerScreen(title: "피자",),
                    builder: (context) => NewPage(restaurants: restaurants, position: position!), // 새로운 페이지 위젯을 여기에 제공
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('식당을 확인하려면 마커를 클릭해보세요!')));
              } : null,
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                width: 350,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/foods/${widget.menu}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('이미지를 찾을 수 없습니다'));
                  },
                ),
              ),
            ),
            SizedBox(height: 40),
            _isLoading ?  Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(text: '식당을 불러오고 있어요!'),
                        ]
                    ),
                  ),
                ],
              ), // 로딩 인디케이터
            ) : Container(
              child: restaurants.isEmpty ?
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(text: '주변에 식당이 없어요!'),
                  ]
                ),
              )
                  :
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                    style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(text: '음식 사진을 클릭하세요!'),
                    ]
                ),
              ),

            ),
          ],
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
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  // Fetch nutrients from Firestore
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('foods').doc(widget.menu).get();
                  if (snapshot.exists) {
                    Map<String, dynamic> nutrients = {};

                    // Get 'nutrients' document
                    DocumentSnapshot nutrientsSnapshot = await snapshot.reference.collection('nutrients').doc('nutrients').get();

                    if (nutrientsSnapshot.exists) {
                      // Get energy value from 'nutrients' document
                      nutrients['에너지'] = nutrientsSnapshot.get('energy') ?? '';

                      // Get carbohydrate, protein, and fat values from 'super' collection
                      DocumentSnapshot superSnapshot = await nutrientsSnapshot.reference.collection('super').doc('super').get();
                      nutrients['탄수화물'] = superSnapshot.get('carbohydrate') ?? '';
                      nutrients['단백질'] = superSnapshot.get('protein') ?? '';
                      nutrients['지방'] = superSnapshot.get('fat') ?? '';

                      // Get additional nutrients from 'sub' collection
                      DocumentSnapshot subSnapshot = await nutrientsSnapshot.reference.collection('sub').doc('sub').get();
                      if (subSnapshot.exists) {
                        Map<String, dynamic>? subData = subSnapshot.data() as Map<String, dynamic>?;
                        if (subData != null) {
                          subData.forEach((key, value) {
                            nutrients[key] = value ?? '';
                          });
                        }
                      }

                      // Get selected additional nutrients from SharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      List<String> selectedNutrients = prefs.getStringList('addedNutrients') ?? [];

                      Navigator.pop(context); // Close the loading dialog

                      // Navigate to NutrientInfoPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutrientInfoPage(
                            foodName: widget.menu,
                            nutrients: nutrients,
                            selectedNutrients: selectedNutrients, // Pass the selected additional nutrients
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  Navigator.pop(context); // Close the loading dialog if there's an error
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('오류 발생'),
                        content: Text('영양소 정보를 불러오는 중 오류가 발생했습니다.'),
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
                }
              },
              child: Text(
                '음식 영양소 보기',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
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

  Future<void> _getNearbyRestaurants(Position? position) async {  // 주변 식당 리스트

    //Position position = await getCurrentLocation();
    double latitude = position!.latitude;
    double longitude = position!.longitude;
    String keyword = widget.menu;
    //String keyword = "토마토소스스파게티";

    try {
      final url = Uri.parse(
          'https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword&x=$longitude&y=$latitude&radius=$radius'
        //'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=FD6&x=$longitude&y=$latitude&radius=$radius' 위는 키워드, 아래는 식당카테고리
      );
      final response = await http.get(url, headers: {
        'Authorization': 'KakaoAK $apiKey',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          restaurants = data['documents'];
        });
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<Position> getCurrentLocation() async {  // 위치 정보 얻음
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // 위치 권한을 요청
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Location permission not granted');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      return position;
    } catch (e) {
      return Future.error('Error getting current location: $e');
    }
  }

}


// 식당 카카오맵 url 연결해줌
class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    String modifiedUrl = widget.url.replaceAll('http://', 'https://');
    // WebView 초기화
    webViewController = WebViewController()
      ..loadRequest(Uri.parse(modifiedUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    webViewController.clearCache();
    // 입력받은 URL에서 http를 https로 변경
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebViewWidget(controller: webViewController),
    );
  }
}


class NewPage extends StatefulWidget {

  final Position position;
  final List<dynamic> restaurants;

  NewPage({
    Key? key,
    required this.restaurants,
    required this.position,
  }) : super(key: key);

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  late KakaoMapController mapController;
  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {

    print(markers);

    return Scaffold(
      appBar: AppBar(
        title: Text('지도'),
          actions: [
              IconButton(
                icon: Icon(Icons.map),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NewPage(restaurants: widget.restaurants, position: widget.position)),
                  );
                },
            ),],
      ),
      body: Center(
        child:
        KakaoMap(
          onMapCreated: ((controller) async {
            mapController = controller;

            // 식당들
            for (int i = 0; i < widget.restaurants.length; i++) {
              markers.add(
                Marker(
                    markerId: i.toString(),
                    latLng: LatLng(double.parse(widget.restaurants[i]['y']), double.parse(widget.restaurants[i]['x'])),

                    //infoWindowContent: '<div style="padding:15px;">${widget.restaurants[i]['place_name']}<br><a href=${widget.restaurants[i]['place_url']} style="color:blue" target="_blank">식당 정보</a></div>',
                    infoWindowContent: '<div style="padding:15px;">${widget.restaurants[i]['place_name']}<br><a href=${widget.restaurants[i]['place_url']} style="color:blue" target="_self">식당 정보</a></div>',
                    infoWindowRemovable: true,
                    //infoWindowFirstShow: false,
                ),
              );
            }
            // 현재위치
            markers.add(
                Marker(
                    markerId: 'markerId',
                    latLng: LatLng(widget.position.latitude, widget.position.longitude),
                    width: 30,
                    height: 40,
                    offsetX: 15,
                    offsetY: 44,
                    markerImageSrc: 'https://w7.pngwing.com/pngs/398/162/png-transparent-computer-icons-google-map-maker-map-marker-angle-black-map-thumbnail.png',
                    infoWindowContent: '<div style="padding:15px;">현재 위치</div>',
                    infoWindowRemovable: true,
                    infoWindowFirstShow: true,
                )
            );
            setState(() { });
          }),
          markers: markers.toList(),
          center: LatLng(widget.position.latitude, widget.position.longitude),
          currentLevel: 6, // 얼마나 확대할지
          onMarkerTap: ((markerId, latLng, zoomLevel) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('식당정보를 클릭하세요!')));
          }),
        ),
      ),
    );
  }
}