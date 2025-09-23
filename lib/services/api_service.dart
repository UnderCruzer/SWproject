// lib/services/api_service.dart

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  // ApiService가 생성될 때 Dio 인스턴스를 초기화합니다.
  // AuthService() -> ApiService() 로 수정
  ApiService()
      : _dio = Dio(BaseOptions(
    // 실제 백엔드 서버의 주소를 입력하세요.
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(milliseconds: 5000), // 5초
    receiveTimeout: const Duration(milliseconds: 3000), // 3초
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // POST 요청을 위한 메서드
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      // DioException을 잡아서 에러를 처리하거나 다시 던집니다.
      print('API POST Error: $e');
      rethrow;
    }
  }

// 여기에 GET, PUT, DELETE 등 다른 메서드도 추가할 수 있습니다.
}