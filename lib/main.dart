import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class NearbyRestaurantsPage extends StatefulWidget {
  @override
  _NearbyRestaurantsPageState createState() => _NearbyRestaurantsPageState();
}

class _NearbyRestaurantsPageState extends State<NearbyRestaurantsPage> {
  final String apiKey = 'd743ba7caedcdefb200416fd7e9fffa9';
  //final double latitude = 37.5050;     //37.4941; // 집의 위도
  //final double longitude = 126.9571;   //127.0752; // 집의 경도
  final int radius = 3000; // 3km 반경 내에서 검색

  List<dynamic> restaurants = [];
  String keyword = '피자';

  @override
  void initState() {
    super.initState();
    _getNearbyRestaurants();
  }

  Future<void> _getNearbyRestaurants() async {

    Position position = await getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;

    try {
      final url = Uri.parse(
          'https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword&x=$longitude&y=$latitude&radius=$radius'
        //'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=FD6&x=$longitude&y=$latitude&radius=$radius'
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

  Future<Position> getCurrentLocation() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Restaurants'),
      ),
      body: restaurants.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(restaurants[index]['place_name']),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NearbyRestaurantsPage(),
  ));
}
