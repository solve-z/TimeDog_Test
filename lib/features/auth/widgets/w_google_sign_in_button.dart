import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'package:timedog_test/features/auth/providers/auth_provider.dart';

/// Google 로그인 버튼 위젯
class GoogleSignInButtonWidget extends ConsumerStatefulWidget {
  const GoogleSignInButtonWidget({super.key});

  @override
  ConsumerState<GoogleSignInButtonWidget> createState() =>
      _GoogleSignInButtonWidgetState();
}

class _GoogleSignInButtonWidgetState
    extends ConsumerState<GoogleSignInButtonWidget> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signInWithGoogle();
      AppLogger.auth.i('Google 로그인 성공');
    } catch (e, stackTrace) {
      AppLogger.auth.e('Google 로그인 실패', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지가 없을 경우 아이콘으로 대체
                        return const Icon(
                          Icons.login,
                          size: 24,
                          color: Colors.blue,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Google로 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
