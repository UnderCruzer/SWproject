import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => NearbyMapScreenState();
}

class NearbyMapScreenState extends State<NearbyMapScreen> {
  // GoogleMap을 제어하기 위한 컨트롤러
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // 초기 카메라 위치 (서울 시청)
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.0,
  );

  // 현재 위치를 저장할 변수
  Position? _currentPosition;
  String _statusMessage = '현재 위치를 찾는 중...';
  bool _isLoading = true;

  // 지도에 표시할 마커
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// 사용자의 현재 위치를 가져오는 함수
  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '위치 권한을 확인하는 중...';
    });

    try {
      // 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다. 기기 설정에서 활성화해주세요.');
      }

      // 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
      }

      // 현재 위치 가져오기
      setState(() { _statusMessage = '현재 위치를 가져오는 중...'; });
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ================== 👇 디버깅 코드 추가 👇 ==================
      // 가져온 위치 정보를 콘솔에 출력합니다.
      if (_currentPosition != null) {
        print('✅ 현재 위치: 위도=${_currentPosition!.latitude}, 경도=${_currentPosition!.longitude}');
      } else {
        print('❌ 위치 정보를 가져오는 데 실패했습니다.');
      }
      // ========================================================

      // 위치를 성공적으로 가져오면 마커를 추가하고 카메라를 이동
      if (_currentPosition != null) {
        _addMarker(_currentPosition!);
        _moveCamera(_currentPosition!);
        _statusMessage = '현재 위치를 찾았습니다!';
      }
    } catch (e) {
      // 에러 처리
      setState(() {
        _statusMessage = e.toString();
      });
    } finally {
      // 로딩 상태 종료
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 지도 카메라를 특정 위치로 이동시키는 함수
  Future<void> _moveCamera(Position position) async {
    final GoogleMapController controller = await _controller.future;
    final newPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16.0,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  /// 지도에 마커를 추가하는 함수
  void _addMarker(Position position) {
    setState(() {
      _markers.clear(); // 기존 마커 제거
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: '현재 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 주변 탐색'),
        actions: [
          // 위치 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _getUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 구글맵 위젯
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kInitialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
          ),
          // 로딩 중이거나 에러 발생 시 상태 메시지 표시
          if (_isLoading || _statusMessage.isNotEmpty && !_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: _isLoading ? Colors.blue.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      // 현재 위치로 이동하는 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentPosition != null) {
            _moveCamera(_currentPosition!);
          }
        },
        label: const Text('내 위치로'),
        icon: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}