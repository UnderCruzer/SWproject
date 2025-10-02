import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sw_project/services/auth_service.dart';
import 'package:sw_project/screens/travel_app_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // ❗️ 여기에 Google Cloud에서 발급받은 클라이언트 ID를 반드시 입력하세요.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken != null) {
          final result = await _authService.socialLogin('google', idToken);

          // 3. 로그인 성공 시 화면 전환 로직 추가
          if (result != null && mounted) {
            print('로그인 성공: $result');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TravelAppScreen(userInfo: result),
              ),
            );
          }
        }
      }
    } catch (error) {
      print('구글 로그인 실패: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인에 실패했습니다: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 부분은 변경사항 없습니다.
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    size: 48,
                    color: Color(0xFF4A64F2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '환영합니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '계정에 로그인하여 여행을 시작하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(flex: 2),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
                  label: const Text('Google 계정으로 로그인'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}