// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  // TODO: 카카오 SDK 초기화 등 앱 시작 전 필요한 설정 추가
  runApp(const MyTravelApp());
}

class MyTravelApp extends StatelessWidget {
  const MyTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTravel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard', // 앱 전체에 적용할 폰트 (별도 추가 필요)
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A64F2)),
      ),
      home: const SplashScreen(), // 앱의 첫 화면을 스플래시 화면으로 지정
    );
  }
}