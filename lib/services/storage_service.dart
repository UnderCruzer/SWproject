import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_style.dart';
import 'dart:convert';

/// SharedPreferences를 사용하여 기기에 데이터를 저장하고 불러오는 클래스
class StorageService {
  static const _key = 'travelStyle';

  // TravelStyle 객체를 JSON 문자열로 변환하여 저장
  static Future<void> saveTravelStyle(TravelStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    // 객체를 Map으로, 다시 JSON 문자열로 변환
    final styleMap = {
      'name': style.name,
      'tripType': style.tripType,
      'planningStyle': style.planningStyle,
      'pace': style.pace,
      'interests': style.interests.toList(), // Set을 List로 변환
      'budget': style.budget,
    };
    await prefs.setString(_key, jsonEncode(styleMap));
  }

  // 저장된 JSON 문자열을 TravelStyle 객체로 변환하여 불러오기
  static Future<TravelStyle?> getTravelStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString != null) {
      final styleMap = jsonDecode(jsonString);

      // 수정된 부분: 기본 생성자로 객체를 만든 후, 각 속성에 값을 할당합니다.
      final style = TravelStyle();
      style.name = styleMap['name'];
      style.tripType = styleMap['tripType'];
      style.planningStyle = styleMap['planningStyle'];
      style.pace = styleMap['pace'];
      style.interests = Set<String>.from(styleMap['interests']); // List를 Set으로 변환
      style.budget = styleMap['budget'];

      return style;
    }
    return null; // 저장된 데이터가 없으면 null 반환
  }
}
