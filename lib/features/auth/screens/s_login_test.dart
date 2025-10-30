import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/features/auth/providers/auth_provider.dart';
import 'package:timedog_test/features/auth/widgets/w_google_sign_in_button.dart';

/// 로그인 테스트 화면 (Phase 4-1 테스트용)
class LoginTestScreen extends ConsumerWidget {
  const LoginTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 앱 로고 영역 (임시)
            const Icon(
              Icons.pets,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'TimeDog',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // 현재 로그인 상태 표시
            currentUser.when(
              data: (user) {
                if (user == null) {
                  return const Text(
                    '로그인이 필요합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  );
                }
                return Column(
                  children: [
                    const Text(
                      '로그인 성공!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${user.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (user.nickname != null)
                      Text(
                        'Nickname: ${user.nickname}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 32),

            // Google 로그인 버튼
            const GoogleSignInButtonWidget(),
          ],
        ),
      ),
    );
  }
}