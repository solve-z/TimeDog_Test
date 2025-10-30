import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/features/auth/widgets/w_google_sign_in_button.dart';

/// 로그인 화면
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // 앱 로고 및 브랜딩
              Column(
                children: [
                  // 앱 아이콘 (임시로 Icon 사용, 추후 이미지로 교체)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 앱 이름
                  const Text(
                    'TimeDog',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 앱 설명
                  Text(
                    '김독이와 함께하는 시간 관리',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Google 로그인 버튼
              const GoogleSignInButtonWidget(),

              const SizedBox(height: 16),

              // 개인정보 처리방침 및 이용약관 (추후 추가)
              Text(
                '로그인 시 개인정보 처리방침 및\n이용약관에 동의하게 됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}