// lib/services/auth_service.dart

import 'api_service.dart'; // ApiService를 import 합니다.

class AuthService {
  // ApiService를 사용하기 위해 인스턴스를 생성합니다.
  final ApiService _apiService = ApiService();

  // 👇 여기에 socialLogin 메서드를 정의합니다.
  Future<Map<String, dynamic>?> socialLogin(String provider, String token) async {
    try {
      final response = await _apiService.post(
        '/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred during social login: $e');
      return null;
    }
  }
}