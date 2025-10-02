import os
import json
from flask import Flask, request, jsonify
import google.generativeai as genai
import googlemaps

app = Flask(__name__)

# --- 설정 (Setup) ---
# ⚠️ 중요: 실제 서비스에서는 이 키들을 환경 변수로 관리해야 합니다.
# 환경 변수에서 API 키를 읽어옵니다.
try:
    genai.configure(api_key=os.environ["AIzaSyDgdPmDgth75zoTGuDpiB-_g6OOk_wrMPw"])
    gmaps = googlemaps.Client(key=os.environ["AIzaSyCz-2ijryjIQDolefGhKep6Tz988_SkCsU"])
except KeyError as e:
    print(f"!!! 중요: 환경 변수 '{e.args[0]}'가 설정되지 않았습니다. README 파일을 참고하여 API 키를 설정해주세요.")
    # 실제 운영 환경에서는 여기서 프로그램을 종료해야 합니다.
    # exit()

# --- AI 모델 초기화 ---
generation_config = {
    "temperature": 0.7,
    "top_p": 1,
    "top_k": 1,
    "max_output_tokens": 2048,
    "response_mime_type": "application/json", # JSON 형식으로 응답 받도록 설정
}
model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config
)


# --- RAG 로직의 핵심 함수들 ---

def retrieve_places(destination, travel_style):
    """ 1. 검색(Retrieval) 단계: 사용자의 여행 스타일에 맞춰 실제 장소를 검색 """

    interest_map = {
        '문화/역사': 'museum|art_gallery|historical_landmark',
        '자연/풍경': 'park|tourist_attraction',
        '맛집/음식': 'restaurant|cafe',
        '쇼핑': 'shopping_mall|store',
    }

    retrieved_places = {}

    for interest in travel_style.get('interests', []):
        if interest in interest_map:
            query = f"{interest_map[interest]} in {destination}"
            try:
                #  Google Places API를 사용하여 장소 검색
                print(f"Google Places API에 검색 요청: '{query}'")
                places_result = gmaps.places(query=query, language='ko')

                # 상위 5개 장소의 이름만 추출하여 저장
                retrieved_places[interest] = [place['name'] for place in places_result.get('results', [])[:5]]
                print(f"'{interest}' 검색 결과: {retrieved_places[interest]}")
                # -------------------------

            except Exception as e:
                print(f"Error retrieving places for {interest}: {e}")

    return retrieved_places


def generate_plan_with_rag(destination, duration, person_count, travel_style, places):
    """2. 증강 생성(Augmented Generation) 단계: 검색된 장소 목록을 이용해 AI에게 계획 생성을 요청합니다."""

    context_places = "\n".join([f"- {category}: {', '.join(names)}" for category, names in places.items()])

    prompt = f"""
    당신은 최고의 여행 플래너 AI입니다. 다음 조건과 <검색된 실제 장소 목록>을 반드시 활용하여 여행 계획을 짜주세요.

    ### 조건:
    - **여행지**: {destination}
    - **여행 기간**: {duration}일
    - **인원**: {person_count}명
    - **사용자 여행 스타일**:
        - 계획: {travel_style.get('planningStyle')}
        - 페이스: {travel_style.get('pace')}
        - 관심사: {', '.join(travel_style.get('interests', []))}
        - 예산: {travel_style.get('budget')}

    ### <검색된 실제 장소 목록>:
    {context_places}

    ### 출력 형식 (JSON):
    - 각 날짜를 '1일차', '2일차'와 같은 key로 하고, 각 날짜의 활동을 상세 설명이 포함된 문자열 리스트로 구성해주세요.
    - 예시: {{ "1일차": ["오전: 쇤부른 궁전 방문", "점심: 비너 슈니첼 맛집 탐방", "오후: 벨베데레 궁전에서 클림트 작품 감상"], "2일차": [...] }}
    - 활동은 <검색된 실제 장소 목록>에 있는 장소들을 중심으로 논리적인 순서와 동선에 맞게 배치해주세요.
    - 각 활동은 '오전', '점심', '오후', '저녁'과 같이 시간대를 포함하여 구체적으로 작성해주세요.
    """

    try:
        # --- 실제 AI 호출 부분 ---
        print("AI에게 여행 계획 생성을 요청합니다...")
        response = model.generate_content(prompt)
        plan_data = json.loads(response.text)
        print("AI로부터 계획을 생성받았습니다.")
        # ------------------------

        return plan_data
    except Exception as e:
        print(f"Error in generation step: {e}")
        return {"error": "AI가 계획을 생성하는 중 오류가 발생했습니다."}


# --- API 엔드포인트 ---

@app.route('/api/generate-rag-plan', methods=['POST'])
def generate_rag_plan_endpoint():
    """Flutter 앱의 요청을 받아 RAG 파이프라인을 실행하는 API"""
    data = request.json

    # 1. 검색(Retrieval)
    retrieved_places = retrieve_places(data.get('destination'), data.get('travelStyle'))

    if not retrieved_places:
        return jsonify({"error": "관심사에 맞는 장소를 찾을 수 없습니다. 다른 관심사를 선택해보세요."}), 400

    # 2. 증강 생성(Augmented Generation)
    final_plan = generate_plan_with_rag(
        data.get('destination'),
        data.get('duration'),
        data.get('personCount'),
        data.get('travelStyle'),
        retrieved_places
    )

    return jsonify(final_plan)


if __name__ == '__main__':
    app.run(debug=True, port=5000)

