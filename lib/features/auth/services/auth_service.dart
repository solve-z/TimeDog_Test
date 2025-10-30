import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'package:timedog_test/features/auth/models/vo_user.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// 현재 로그인된 사용자 정보 조회
  Future<UserVo?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        AppLogger.auth.d('No active session');
        return null;
      }

      final userId = session.user.id;
      final email = session.user.email;

      if (email == null) {
        AppLogger.auth.w('User email is null');
        return null;
      }

      // profiles 테이블에서 사용자 정보 조회
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Database Trigger가 정상 작동하면 발생하지 않아야 함
        AppLogger.auth.e('Profile not found for user $userId - Database trigger may not be working');
        throw Exception('Profile not found. Please contact support.');
      }

      final userVo = UserVo.fromJson(response);
      AppLogger.auth.d('Current user: $userVo');
      return userVo;
    } catch (e, stackTrace) {
      AppLogger.auth.e('Failed to get current user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Google 로그인
  Future<UserVo?> signInWithGoogle() async {
    try {
      AppLogger.auth.i('Starting Google sign-in');

      // Google Sign-In 설정
      const webClientId = ''; // TODO: Google Cloud Console에서 발급받은 Web Client ID 추가
      const iosClientId = ''; // TODO: Google Cloud Console에서 발급받은 iOS Client ID 추가

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId.isNotEmpty ? iosClientId : null,
        serverClientId: webClientId.isNotEmpty ? webClientId : null,
      );

      // Google 계정 선택
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.auth.w('Google sign-in cancelled by user');
        return null;
      }

      // Google 인증 토큰 가져오기
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        AppLogger.auth.e('Failed to get Google tokens');
        throw Exception('Failed to get Google authentication tokens');
      }

      // Supabase에 Google 토큰으로 로그인
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      AppLogger.auth.i('Google sign-in successful: ${authResponse.user?.email}');

      // 사용자 정보 조회 (Database Trigger로 profiles 자동 생성됨)
      return await getCurrentUser();
    } catch (e, stackTrace) {
      AppLogger.auth.e('Google sign-in failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      AppLogger.auth.i('Signing out');
      await _supabase.auth.signOut();
      AppLogger.auth.i('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.auth.e('Sign out failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 인증 상태 변경 스트림
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}