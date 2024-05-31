import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'HealthModePage.dart';
// for kakaomap API
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class MenuRecommendationPage extends StatefulWidget {
  final String mealTime;
  final String menu;

  const MenuRecommendationPage({Key? key, required this.mealTime, required this.menu}) : super(key: key);

  @override
  _MenuRecommendationPageState createState() => _MenuRecommendationPageState();
}

class _MenuRecommendationPageState extends State<MenuRecommendationPage> {
  bool _isHealthMode = false; // Added state for health mode toggle

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
    // _getNearbyRestaurants();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showModalBottomSheet();
    // });
    _initRestaurants();
  }

  // 비동기 메서드 이름 변경 및 호출 방법 수정
  Future<void> _initRestaurants() async {
    //restaurants = [];
    position = await getCurrentLocation();
    await _getNearbyRestaurants(position!); // await을 사용하여 데이터 로드 완료까지 기다림

    // for (int i = 0; i < restaurants.length; i++) {
    //   markers.add(
    //     Marker(
    //       markerId: i.toString(),
    //       latLng: LatLng(double.parse(restaurants[i]['x']), double.parse(restaurants[i]['y']))
    //     ),
    //   );
    // }
    print(restaurants);
    //_showModalBottomSheet(); // 데이터 로드 후에 showModalBottomSheet() 호출
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //builder: (context) => Static2MarkerScreen(title: "피자",),
                    builder: (context) => NewPage(restaurants: restaurants, position: position!), // 새로운 페이지 위젯을 여기에 제공
                  ),
                );
              },
              child: Container(
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

  // void _showModalBottomSheet() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return DraggableScrollableSheet(
  //         expand: false,
  //         minChildSize: 0.3,
  //         maxChildSize: 0.9,
  //         initialChildSize: 0.5,
  //         builder: (BuildContext context, ScrollController scrollController) {
  //           return Container(
  //             padding: EdgeInsets.all(20),
  //             child: restaurants.isEmpty
  //                 ? const Center(
  //                     child: Text("No Results"),
  //                 )
  //                 :
  //                 // ListView.builder(
  //                 //   controller: scrollController,
  //                 //   itemCount: restaurants.length,
  //                 //   itemBuilder: (BuildContext context, int index) {
  //                 //     return ListTile(
  //                 //       title: Text(restaurants[index]['place_name']),
  //                 //       onTap: () {
  //                 //         Navigator.push(
  //                 //           context,
  //                 //           MaterialPageRoute(
  //                 //             builder: (context) => WebViewPage(url: restaurants[index]['place_url']),
  //                 //           ),
  //                 //         );
  //                 //       },
  //                 //     );
  //                 //   },
  //                 // ),
  //                 // KakaoMap(
  //                 //   onMapCreated: ((controller) async {
  //                 //     mapController = controller;
  //                 //     setState(() { });
  //                 //   }),
  //                 //   markers: markers.toList(),
  //                 //   center: LatLng(position!.latitude, position!.longitude),
  //                 // ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _getNearbyRestaurants(Position? position) async {  // 주변 식당 리스트

    //Position position = await getCurrentLocation();
    double latitude = position!.latitude;
    double longitude = position!.longitude;
    //String keyword = widget.menu;
    String keyword = "피자";

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

  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    webViewController!.clearCache();
    // 입력받은 URL에서 http를 https로 변경
    String modifiedUrl = widget.url.replaceAll('http://', 'https://');

    // WebView 초기화
    webViewController = WebViewController()
      ..loadRequest(Uri.parse(modifiedUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebViewWidget(controller: webViewController!),
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
    print("HELLO");

    return Scaffold(
      appBar: AppBar(
        title: Text('지도'),
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
                    infoWindowContent: '<div style="padding:15px;">${widget.restaurants[i]['place_name']}<br><a href=${widget.restaurants[i]['place_url']} style="color:blue" target="_blank">식당 정보</a></div>',
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
          //currentLevel: 6, // 얼마나 확대할지
          onMarkerTap: ((markerId, latLng, zoomLevel) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('식당정보를 누르면 확인가능합니다.')));
          }),
        ),
      ),
    );
  }
}





/// 이미지 지도에 마커 표시하기
/// https://apis.map.kakao.com/web/sample/staticMapWithMarker/
class Static2MarkerScreen extends StatefulWidget {
  const Static2MarkerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Static2MarkerScreen> createState() => _Static2MarkerScreenState();
}

class _Static2MarkerScreenState extends State<Static2MarkerScreen> {
  late KakaoMapController mapController;

  LatLng center = LatLng(33.450701, 126.570667);
  Set<Marker> markers = {};

  @override
  void initState() {
    markers.add(Marker(markerId: 'markerId', latLng: center));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("피자"),
      ),
      body: KakaoStaticMap(
        markers: markers.toList(),
        center: center,
        currentLevel: 6,
      ),
    );
  }
}