import 'dart:async';
import 'package:flutter/material.dart';
import '../models/place_prediction.dart';
import '../models/travel_style.dart';
import '../services/place_service.dart';
import 'planner_screen.dart';
import 'profile_screen.dart';
import 'trip_settings_screen.dart'; // 여행 설정 화면 import 추가
import '/widget/toggle_buttons.dart';

class MainScreen extends StatefulWidget {
  final TravelStyle travelStyle;

  const MainScreen({super.key, required this.travelStyle});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PlannerScreen(),
      _SearchPage(travelStyle: widget.travelStyle),
      ProfileScreen(travelStyle: widget.travelStyle),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: '내 플래너',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A64F2),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}

class _SearchPage extends StatefulWidget {
  final TravelStyle travelStyle;
  const _SearchPage({required this.travelStyle});

  @override
  State<_SearchPage> createState() => __SearchPageState();
}

class __SearchPageState extends State<_SearchPage> {
  final PlaceService _placeService = PlaceService();
  List<PlacePrediction> _predictions = [];
  Timer? _debounce;
  bool _isLoading = false;

  // 여행 스타일을 분석하여 한 줄 요약을 생성하는 함수
  String _summarizeTravelStyle(TravelStyle style) {
    String summary = "당신은 ";
    if (style.planningStyle == '계획형') {
      summary += "치밀한 계획으로 ";
    } else {
      summary += "발길 닿는 대로 ";
    }

    if (style.pace == '모험형') {
      summary += "모험을 즐기는 ";
    } else {
      summary += "힐링을 찾아 떠나는 ";
    }

    if (style.interests.contains('문화/역사')) {
      summary += "지적인 탐험가 같아요!";
    } else if (style.interests.contains('맛집/음식')) {
      summary += "미식가 같아요!";
    } else {
      summary += "자유로운 영혼 같아요!";
    }
    return summary;
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        setState(() => _isLoading = true);
        _placeService.getAutocomplete(value).then((predictions) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _predictions = predictions;
            });
          }
        });
      } else {
        if (mounted) setState(() => _predictions = []);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialSelection = widget.travelStyle.tripType == '국내' ? 1 : 2;
    final String userName = (widget.travelStyle.name != null && widget.travelStyle.name!.isNotEmpty)
        ? widget.travelStyle.name!
        : '여행자';
    final String styleSummary = _summarizeTravelStyle(widget.travelStyle);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                '$userName님,\n어디로 여행을 떠나시나요?',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF4A64F2)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        styleSummary,
                        style: const TextStyle(color: Color(0xFF3B52C4), fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '국가명이나 도시명으로 검색해보세요.',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ToggleButtonsWidget(initialSelection: initialSelection),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return Card(
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EFFF),
                          child: Icon(Icons.location_on_outlined, color: Color(0xFF4A64F2)),
                        ),
                        title: Text(prediction.mainText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(prediction.secondaryText),
                        onTap: () {
                          // --- 🚀 수정된 부분 ---
                          // print 대신 Navigator.push를 사용하여 화면 전환
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TripSettingsScreen(
                                destination: prediction.mainText, // '빈'과 같은 주요 장소 이름 전달
                                travelStyle: widget.travelStyle,
                              ),
                            ),
                          );
                          // --------------------
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

