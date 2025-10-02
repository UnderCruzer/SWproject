import 'package:flutter/material.dart';
import '../models/travel_style.dart';

class ProfileScreen extends StatefulWidget {
  // MainScreen으로부터 TravelStyle 데이터를 받기 위해 required 추가
  final TravelStyle travelStyle;

  const ProfileScreen({super.key, required this.travelStyle});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _locationEnabled = true; // 실시간 위치 허용 상태

  /// 여행 스타일에 따라 한 줄 요약 문구를 생성하는 함수
  String _generateTravelStyleSummary(TravelStyle style) {
    String persona = "";

    if (style.planningStyle == '계획형' && style.pace == '모험형') {
      persona = "치밀한 계획으로 모험을 즐기는 탐험가";
    } else if (style.planningStyle == '즉흥형' && style.pace == '휴식형') {
      persona = "발길 닿는 대로 힐링을 찾아 떠나는 자유로운 영혼";
    } else if (style.interests.contains('맛집/음식') && style.interests.contains('힐링/휴양')) {
      persona = "맛집과 함께 여유를 즐기는 낭만 미식가";
    } else if (style.interests.contains('맛집/음식')) {
      persona = "새로운 맛을 찾아 떠나는 미식가";
    } else if (style.interests.contains('문화/역사')) {
      persona = "역사의 발자취를 따라가는 지적인 여행자";
    } else if (style.pace == '모험형' || style.interests.contains('액티비티')) {
      persona = "짜릿한 액티비티를 즐기는 모험가";
    } else {
      persona = "여유로운 힐링을 즐기는 낭만가";
    }
    return '여행 스타일을 보아하니 $persona 같아요!';
  }


  @override
  Widget build(BuildContext context) {
    final String userName = (widget.travelStyle.name != null && widget.travelStyle.name!.isNotEmpty)
        ? widget.travelStyle.name!
        : '여행자';

    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색 변경
      appBar: AppBar(
        title: Text('$userName님의 정보', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 여행 스타일 요약 카드
          _buildSummaryCard(_generateTravelStyleSummary(widget.travelStyle)),
          const SizedBox(height: 16),

          // 나의 여행 스타일 섹션
          _buildProfileSection(
            title: '나의 여행 스타일',
            icon: Icons.explore_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStyleItem('여행 타입', widget.travelStyle.tripType),
                _buildStyleItem('계획 스타일', widget.travelStyle.planningStyle),
                _buildStyleItem('여행 페이스', widget.travelStyle.pace),
                _buildStyleItem('예산', widget.travelStyle.budget),
                _buildStyleItem('관심사', widget.travelStyle.interests.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 최근 여행 기록 섹션
          _buildProfileSection(
            title: '최근 여행 기록',
            icon: Icons.edit_note_outlined,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '예: 제주도 3박 4일 (가족여행)',
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A64F2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('기록하기'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 내가 가본 곳 섹션
          _buildProfileSection(
            title: '내가 가본 곳',
            icon: Icons.flag_outlined,
            child: Center(
              child: TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('방문한 장소 추가하기'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 설정 섹션
          _buildProfileSection(
            title: '설정',
            icon: Icons.settings_outlined,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('실시간 위치 허용', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                _locationEnabled ? '주변 장소 추천 기능이 활성화됩니다.' : '주변 장소 추천을 받지 않습니다.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              value: _locationEnabled,
              onChanged: (bool value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
              activeColor: const Color(0xFF4A64F2),
              secondary: Icon(
                  _locationEnabled ? Icons.location_on : Icons.location_off,
                  color: const Color(0xFF4A64F2)
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 여행 스타일 요약 카드 위젯
  Widget _buildSummaryCard(String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A64F2), Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A64F2).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 재사용 가능한 섹션 카드 위젯
  Widget _buildProfileSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700], size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // 여행 스타일 항목을 보여주는 위젯
  Widget _buildStyleItem(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

