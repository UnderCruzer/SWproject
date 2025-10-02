import 'package:flutter/material.dart';
import '../models/travel_style.dart';
import '../services/storage_service.dart';
import 'main_screen.dart'; // 메인 화면을 import 합니다.

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TravelStyle _travelStyle = TravelStyle();
  int _currentPage = 0;

  static const int _totalPages = 7;

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await StorageService.saveTravelStyle(_travelStyle);
    print('저장된 여행 스타일: ${_travelStyle.toString()}');

    if (mounted) {
      // 화면 전환 로직을 다시 한번 확인합니다.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // 수집한 travelStyle 데이터를 MainScreen으로 전달합니다.
          builder: (_) => MainScreen(travelStyle: _travelStyle),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildNamePage(),
      _buildTripTypePage(),
      _buildPlanningStylePage(),
      _buildPacePage(),
      _buildAlmostDonePage(),
      _buildInterestsPage(),
      _buildBudgetPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: pages,
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return _buildQuestionPage(
      title: '안녕하세요! 👋',
      subtitle: '당신의 이름을 알려주세요.',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '이름을 입력해주세요',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (text) {
            setState(() {
              _travelStyle.name = text;
            });
          },
        ),
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildTripTypePage() {
    final String userName = (_travelStyle.name != null && _travelStyle.name!.isNotEmpty)
        ? _travelStyle.name!
        : '여행자';

    return _buildQuestionPage(
      title: '$userName님, 반가워요!',
      subtitle: '주로 어떤 여행을 즐기시나요?',
      content: Column(
        children: [
          _buildOptionCard(
              icon: Icons.home_work_outlined,
              title: '국내 여행',
              subtitle: '한국의 아름다운 곳을 탐험해보세요',
              isSelected: _travelStyle.tripType == '국내',
              onTap: () => setState(() => _travelStyle.tripType = '국내')),
          const SizedBox(height: 10),
          _buildOptionCard(
              icon: Icons.language,
              title: '해외 여행',
              subtitle: '세계 각국의 문화를 경험해보세요',
              isSelected: _travelStyle.tripType == '해외',
              onTap: () => setState(() => _travelStyle.tripType = '해외')),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildPlanningStylePage() {
    return _buildQuestionPage(
      title: '여행 계획은 어떻게 세우시나요?',
      subtitle: '당신의 여행 스타일을 알려주세요',
      content: Column(
        children: [
          _buildOptionCard(
              icon: Icons.map_outlined,
              title: '꼼꼼한 계획형',
              subtitle: '미리미리 계획을 세우고 일정을 꼼꼼히 준비해요',
              isSelected: _travelStyle.planningStyle == '계획형',
              onTap: () => setState(() => _travelStyle.planningStyle = '계획형')),
          const SizedBox(height: 10),
          _buildOptionCard(
              icon: Icons.favorite_border,
              title: '자유로운 즉흥형',
              subtitle: '그때그때 끌리는 대로 자유롭게 여행해요',
              isSelected: _travelStyle.planningStyle == '즉흥형',
              onTap: () => setState(() => _travelStyle.planningStyle = '즉흥형')),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildPacePage() {
    return _buildQuestionPage(
      title: '여행 중 어떤 페이스를 선호하시나요?',
      subtitle: '편안함 vs 활동적인 여행',
      content: Column(
        children: [
          _buildOptionCard(
              icon: Icons.self_improvement,
              title: '여유로운 휴식형',
              subtitle: '느긋하게 쉬면서 힐링하는 여행을 좋아해요',
              isSelected: _travelStyle.pace == '휴식형',
              onTap: () => setState(() => _travelStyle.pace = '휴식형')),
          const SizedBox(height: 10),
          _buildOptionCard(
              icon: Icons.directions_run,
              title: '활동적인 모험형',
              subtitle: '다양한 활동과 체험을 즐기는 여행을 좋아해요',
              isSelected: _travelStyle.pace == '모험형',
              onTap: () => setState(() => _travelStyle.pace = '모험형')),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildAlmostDonePage() {
    return _buildQuestionPage(
      title: '거의 다 되었어요! 🎉',
      subtitle: '마지막으로 몇 가지만 더 알려주시면, 맞춤 여행을 추천해 드릴게요.',
      content: const SizedBox.shrink(),
      onNext: _nextPage,
    );
  }

  Widget _buildInterestsPage() {
    const interests = ['문화/역사', '자연/풍경', '맛집/음식', '쇼핑', '사진/인스타', '힐링/휴양', '액티비티', '나이트라이프'];
    return _buildQuestionPage(
      title: '어떤 여행 경험에 관심이 있으신가요?',
      subtitle: '관심사를 모두 선택해주세요 (복수선택 가능)',
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: interests.map((interest) {
          final isSelected = _travelStyle.interests.contains(interest);
          return ChoiceChip(
            label: Text(interest),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _travelStyle.interests.add(interest);
                } else {
                  _travelStyle.interests.remove(interest);
                }
              });
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFFD6E0FF),
            labelStyle: TextStyle(color: isSelected ? const Color(0xFF4A64F2) : Colors.black54, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? const Color(0xFF4A64F2) : Colors.grey.shade200, width: 1.5)),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }).toList(),
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildBudgetPage() {
    return _buildQuestionPage(
      title: '여행 예산 스타일은 어떠신가요?',
      subtitle: '마지막 질문이에요!',
      content: Column(
        children: [
          _buildOptionCard(
              icon: Icons.savings_outlined,
              title: '알뜰 여행',
              subtitle: '합리적인 가격으로 알차게 여행해요',
              isSelected: _travelStyle.budget == '알뜰',
              onTap: () => setState(() => _travelStyle.budget = '알뜰')),
          const SizedBox(height: 10),
          _buildOptionCard(
              icon: Icons.balance,
              title: '적당한 여행',
              subtitle: '가성비와 퀄리티의 균형을 맞춰요',
              isSelected: _travelStyle.budget == '적당',
              onTap: () => setState(() => _travelStyle.budget = '적당')),
          const SizedBox(height: 10),
          _buildOptionCard(
              icon: Icons.diamond_outlined,
              title: '프리미엄 여행',
              subtitle: '특별한 경험과 최고의 서비스를 원해요',
              isSelected: _travelStyle.budget == '프리미엄',
              onTap: () => setState(() => _travelStyle.budget = '프리미엄')),
        ],
      ),
      onNext: _finishOnboarding,
    );
  }

  Widget _buildQuestionPage({
    required String title,
    required String subtitle,
    required Widget content,
    required VoidCallback onNext,
  }) {
    bool isButtonEnabled() {
      switch (_currentPage) {
        case 0: return _travelStyle.name != null && _travelStyle.name!.isNotEmpty;
        case 1: return _travelStyle.tripType != null;
        case 2: return _travelStyle.planningStyle != null;
        case 3: return _travelStyle.pace != null;
        case 4: return true;
        case 5: return _travelStyle.interests.isNotEmpty;
        case 6: return _travelStyle.budget != null;
        default: return false;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 40),
                content,
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isButtonEnabled() ? onNext : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF4A64F2),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == _totalPages - 1 ? '완료 →' : '다음 →',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EFFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A64F2) : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF4A64F2).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF4A64F2) : Colors.grey.shade600, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF4A64F2)),
          ],
        ),
      ),
    );
  }
}

