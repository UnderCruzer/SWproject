import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/travel_style.dart';

class PlanResultScreen extends StatefulWidget {
  final String destination;
  final int durationInDays;
  final int personCount;
  final TravelStyle travelStyle;

  const PlanResultScreen({
    super.key,
    required this.destination,
    required this.durationInDays,
    required this.personCount,
    required this.travelStyle,
  });

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _plan; // AI가 생성한 계획을 저장

  @override
  void initState() {
    super.initState();
    _generatePlanFromBackend();
  }

  // 백엔드에 여행 계획 생성을 요청하는 함수
  Future<void> _generatePlanFromBackend() async {
    // ⚠️ 중요: '10.0.2.2'는 안드로이드 에뮬레이터가 로컬 PC의 localhost를 가리키는 특수 주소입니다.
    // 실제 기기에서 테스트하거나 배포 시에는 백엔드 서버의 공인 IP 주소로 변경해야 합니다.
    const String backendUrl = 'http://10.0.2.2:5000/api/generate-rag-plan';

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'destination': widget.destination,
          'duration': widget.durationInDays,
          'personCount': widget.personCount,
          'travelStyle': {
            'planningStyle': widget.travelStyle.planningStyle,
            'pace': widget.travelStyle.pace,
            'interests': widget.travelStyle.interests.toList(),
            'budget': widget.travelStyle.budget,
          },
        }),
      );

      if (response.statusCode == 200) {
        final planData = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _plan = planData;
            _isLoading = false;
          });
        }
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('백엔드 오류: ${errorData['error']} (상태 코드: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '여행 계획을 불러오는 데 실패했습니다.\n오류: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'AI가 추천하는 ${widget.destination} 여행',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      // 요청하신 로딩 화면 UI
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'AI가 계획을 짜주는 중이에요!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시만 기다려주세요...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 50),
              const SizedBox(height: 16),
              const Text("오류 발생", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.red[700]),
              ),
            ],
          ),
        ),
      );
    }

    if (_plan == null || _plan!.isEmpty || _plan!.containsKey('error')) {
      return const Center(child: Text('AI가 계획을 생성하지 못했습니다.'));
    }

    // 일차 순서대로 정렬
    final sortedDays = _plan!.keys.toList()
      ..sort((a, b) {
        final dayA = int.tryParse(a.replaceAll('일차', '')) ?? 0;
        final dayB = int.tryParse(b.replaceAll('일차', '')) ?? 0;
        return dayA.compareTo(dayB);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final activities = List<String>.from(_plan![day]!);
        return _buildDayCard(day, activities, index + 1);
      },
    );
  }

  // 일차별 계획을 보여주는 카드 위젯
  Widget _buildDayCard(String day, List<String> activities, int dayNumber) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dayNumber일차',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A64F2)),
            ),
            const Divider(height: 24),
            ...activities.map((activity) {
              // '오전:', '점심:' 등 시간대 키워드를 찾아 스타일을 다르게 적용
              final parts = activity.split(':');
              final time = parts.length > 1 ? '${parts[0]}:' : '';
              final description = parts.length > 1 ? parts.sublist(1).join(':').trim() : activity;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade400, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                            children: [
                              TextSpan(text: time, style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' $description'),
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

