import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 패키지
import '../models/travel_style.dart';
import 'plan_result_screen.dart'; // 결과 화면 import

class TripSettingsScreen extends StatefulWidget {
  final String destination; // 선택된 여행지
  final TravelStyle travelStyle;

  const TripSettingsScreen({
    super.key,
    required this.destination,
    required this.travelStyle,
  });

  @override
  State<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends State<TripSettingsScreen> {
  int _personCount = 1;
  DateTimeRange? _selectedDateRange;

  // 날짜 선택기를 표시하는 함수
  Future<void> _selectDate(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 3)),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A64F2), // 선택 색상
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  // 여행 기간을 'N박 N일' 형태로 계산
  String get _dateRangeText {
    if (_selectedDateRange == null) {
      return '여행 기간을 선택해주세요';
    } else {
      final duration = _selectedDateRange!.duration.inDays;
      if (duration == 0) return '당일치기';
      return '$duration박 ${duration + 1}일';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.destination} 여행 설정', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 인원수 설정
            _buildSection(
              title: '몇 명이서 떠나시나요?',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (_personCount > 1) {
                        setState(() => _personCount--);
                      }
                    },
                    iconSize: 30,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 20),
                  Text('$_personCount 명', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => _personCount++);
                    },
                    iconSize: 30,
                    color: const Color(0xFF4A64F2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 여행 기간 설정
            _buildSection(
              title: '여행 기간은 어떻게 되시나요?',
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _dateRangeText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(), // 남은 공간을 모두 차지

            // AI 플랜 생성 버튼
            ElevatedButton(
              onPressed: (_selectedDateRange != null)
                  ? () {
                // 모든 정보를 가지고 결과 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlanResultScreen(
                      destination: widget.destination,
                      durationInDays: _selectedDateRange!.duration.inDays + 1,
                      personCount: _personCount,
                      travelStyle: widget.travelStyle,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A64F2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('AI로 여행 플랜 만들기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 재사용 가능한 섹션 UI
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

