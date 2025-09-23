import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TravelAppScreen extends StatelessWidget {
  final Map<String, dynamic> userInfo;

  const TravelAppScreen({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    // 백엔드로부터 받은 사용자 정보에서 이름 추출
    final user = userInfo['user'];
    final String name = user['name'] ?? '사용자';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 150,
        // 로고
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Icon(Icons.flight_takeoff_rounded, color: Color(0xFF4A64F2)),
              SizedBox(width: 8),
              Text(
                'MyTravel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // 오른쪽 아이콘 버튼들
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () {
              // 로그인 화면으로 돌아가기
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 상단 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.public),
                  label: const Text('여행지 탐색'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4A64F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('내 주변'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 환영 메시지
          Text(
            '$name님, 어디로 떠날까요?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '대륙을 선택하고 맞춤 여행을 계획해보세요',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // 검색창
          TextField(
            decoration: InputDecoration(
              hintText: '대륙이나 국가를 검색해보세요',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF0F2F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 대륙 카드 목록
          ContinentCard(
            imageUrl: 'https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5?w=800',
            continent: '아시아',
            countryCount: '8개 국가',
          ),
          const SizedBox(height: 16),
          ContinentCard(
            imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760c0341?w=800',
            continent: '유럽',
            countryCount: '12개 국가',
          ),
        ],
      ),
    );
  }
}

/// 재사용 가능한 대륙 카드 위젯
class ContinentCard extends StatelessWidget {
  final String imageUrl;
  final String continent;
  final String countryCount;

  const ContinentCard({
    super.key,
    required this.imageUrl,
    required this.continent,
    required this.countryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // 배경 이미지
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade300),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              // 글자가 잘 보이도록 어둡게 그라데이션 처리
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
              ),
              // 텍스트 및 아이콘
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.public, color: Colors.white70, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      continent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        countryCount,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 카드 하단 정보
          ListTile(
            title: const Text('여행지 탐색하기', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('다양한 문화와 경험이 기다려요', style: TextStyle(color: Colors.grey.shade600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}