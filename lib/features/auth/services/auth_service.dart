import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      final response =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (response == null) {
        // Database Trigger가 정상 작동하면 발생하지 않아야 함
        AppLogger.auth.e(
          'Profile not found for user $userId - Database trigger may not be working',
        );
        throw Exception('Profile not found. Please contact support.');
      }

      final userVo = UserVo.fromJson(response);
      AppLogger.auth.d('Current user: $userVo');
      return userVo;
    } catch (e, stackTrace) {
      AppLogger.auth.e(
        'Failed to get current user',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Google 로그인
  Future<UserVo?> signInWithGoogle() async {
    try {
      AppLogger.auth.i('Starting Google sign-in');

      // Google Sign-In 설정
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
      const iosClientId = ''; // TODO: iOS Client ID 추가 (iOS 지원 시)

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

      AppLogger.auth.i(
        'Google sign-in successful: ${authResponse.user?.email}',
      );

      // 사용자 정보 조회 (Database Trigger로 profiles 자동 생성됨)
      return await getCurrentUser();
    } catch (e, stackTrace) {
      AppLogger.auth.e(
        'Google sign-in failed',
        error: e,
        stackTrace: stackTrace,
      );
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

  /// 닉네임 중복 검사
  Future<bool> isNicknameAvailable(String nickname) async {
    try {
      AppLogger.auth.d('Checking nickname availability: $nickname');

      final response =
          await _supabase
              .from('profiles')
              .select('id')
              .eq('nickname', nickname)
              .maybeSingle();

      final isAvailable = response == null;
      AppLogger.auth.d('Nickname "$nickname" available: $isAvailable');
      return isAvailable;
    } catch (e, stackTrace) {
      AppLogger.auth.e(
        'Failed to check nickname availability',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 닉네임 업데이트
  Future<UserVo> updateNickname(String nickname) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      AppLogger.auth.i('Updating nickname to: $nickname for user $userId');

      // 현재 닉네임 조회
      final currentUser = await getCurrentUser();
      if (currentUser?.nickname == nickname) {
        AppLogger.auth.d('Nickname unchanged');
        return currentUser!;
      }

      // 닉네임 중복 검사
      final isAvailable = await isNicknameAvailable(nickname);
      if (!isAvailable) {
        throw Exception('Nickname already taken');
      }

      // 닉네임 업데이트
      await _supabase
          .from('profiles')
          .update({
            'nickname': nickname,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      AppLogger.auth.i('Nickname updated successfully');

      // 업데이트된 사용자 정보 조회
      final updatedUser = await getCurrentUser();
      if (updatedUser == null) {
        throw Exception('Failed to fetch updated user');
      }

      return updatedUser;
    } catch (e, stackTrace) {
      AppLogger.auth.e(
        'Failed to update nickname',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 계정 완전 삭제 (profiles + auth.users)
  Future<void> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      AppLogger.auth.i('Deleting account for user $userId');

      // Supabase Function 호출 (profiles + auth.users 모두 삭제)
      await _supabase.rpc('delete_user_account');

      AppLogger.auth.i('Account completely deleted');
    } catch (e, stackTrace) {
      AppLogger.auth.e(
        'Failed to delete account',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
