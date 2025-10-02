// Google Places API의 자동완성 응답을 담기 위한 데이터 모델입니다.
class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });

  // JSON 데이터를 PlacePrediction 객체로 변환하는 factory 생성자
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'],
    );
  }
}