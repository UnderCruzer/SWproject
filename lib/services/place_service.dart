import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/place_prediction.dart';

class PlaceService {
  // ⚠️ 중요: 이 키는 실제 앱 출시 전에는 백엔드 서버로 옮겨야 안전합니다.
  final String _apiKey = 'AIzaSyCz-2ijryjIQDolefGhKep6Tz988_SkCsU'; // 👈 여기에 발급받은 API 키를 꼭 넣어주세요!
  final String _sessionToken = const Uuid().v4();

  Future<List<PlacePrediction>> getAutocomplete(String input) async {
    if (input.isEmpty) {
      return [];
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'key': _apiKey,
        'sessiontoken': _sessionToken,
        'language': 'ko',
        'types': '(regions)',
      },
    );

    // --- 🐞 디버깅 코드 ---
    print('Requesting URL: $uri');
    // --------------------

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // --- 🐞 디버깅 코드 ---
        print('API Response Status: ${data['status']}');
        if (data['status'] != 'OK') {
          print('API Error Message: ${data['error_message']}');
        }
        // --------------------

        if (data['status'] == 'OK') {
          final List predictions = data['predictions'];
          return predictions
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        } else {
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception during API call: $e');
      return [];
    }
  }
}

