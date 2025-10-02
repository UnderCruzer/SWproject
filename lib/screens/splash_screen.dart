import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // 온보딩 화면으로 연결

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2.5초 후에 온보딩 질문 화면으로 이동
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        // 화면 전환에 페이드 효과를 주기 위해 PageRouteBuilder 사용
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation, // 페이드 인/아웃 애니메이션
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 700), // 전환 속도
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A64F2), // 이미지의 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 아이콘
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                'assets/images/icon.png',
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(height: 24),
            // 앱 이름
            const Text(
              'MyTravel',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // 부제
            const Text(
              'AI 맞춤 여행 플래너',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            // 로딩 인디케이터
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
