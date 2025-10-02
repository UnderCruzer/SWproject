/// 사용자의 여행 스타일 답변을 저장하기 위한 데이터 모델 클래스
class TravelStyle {
  String? name;
  String? tripType; // 국내, 해외
  String? planningStyle; // 계획형, 즉흥형
  String? pace; // 휴식형, 모험형
  Set<String> interests = {}; // 관심사 (다중 선택 가능)
  String? budget; // 알뜰, 적당, 프리미엄


  // 디버깅을 위해 답변 내용을 쉽게 출력하는 함수
  @override
  String toString() {
    return 'TravelStyle(이름: $name, 여행지: $tripType, 계획: $planningStyle, 페이스: $pace, 관심사: $interests, 예산: $budget)';
  }
}