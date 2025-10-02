import 'package:flutter/material.dart';
import 'package:sw_project/models/travel_style.dart';
import 'package:sw_project/screens/main_screen.dart';
import 'package:sw_project/screens/onboarding_screen.dart';
import 'package:sw_project/screens/splash_screen.dart';
import 'package:sw_project/services/storage_service.dart';

// main 함수를 async로 변경하여 await를 사용할 수 있도록 합니다.
void main() async {
  // runApp을 호출하기 전에 Flutter 엔진과 위젯 바인딩이 초기화되었는지 확인합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 기기에 저장된 여행 스타일 데이터를 비동기적으로 불러옵니다.
  final TravelStyle? travelStyle = await StorageService.getTravelStyle();

  runApp(MyTravelApp(
    // 저장된 데이터가 없으면 온보딩 화면으로, 있으면 메인 화면으로 시작합니다.
    // 스플래시 화면이 이 로직을 처리하도록 수정할 수도 있지만,
    // 현재 구조에서는 main에서 분기하는 것이 가장 명확합니다.
    initialScreen: travelStyle == null
        ? const OnboardingScreen()
        : MainScreen(travelStyle: travelStyle),
  ));
}

class MyTravelApp extends StatelessWidget {
  final Widget initialScreen;

  const MyTravelApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTravel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A64F2)),
      ),
      // 스플래시 화면 대신, main 함수에서 결정된 첫 화면을 보여줍니다.
      // 스플래시를 유지하고 싶다면 initialScreen을 SplashScreen으로 전달해야 합니다.
      // 여기서는 스플래시 -> 온보딩 -> 메인 흐름을 명확히 하기 위해 직접 제어합니다.
      home: const SplashScreen(), // 스플래시를 먼저 보여주고, 스플래시가 온보딩/메인으로 보냅니다.
      // 이 구조를 유지하기 위해 main의 로직을 스플래시로 옮겨야 합니다.
      // 우선 가장 간단한 해결책으로 아래 코드를 제안합니다.
    );
  }
}

