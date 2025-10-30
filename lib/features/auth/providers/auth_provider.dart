import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'package:timedog_test/features/auth/models/vo_user.dart';
import 'package:timedog_test/features/auth/services/auth_service.dart';

/// Supabase 클라이언트 Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});

/// 현재 사용자 상태 Provider
final currentUserProvider = StreamProvider<UserVo?>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges.asyncMap((authState) async {
    final session = authState.session;

    if (session == null) {
      AppLogger.auth.d('Auth state changed: No session');
      return null;
    }

    AppLogger.auth.d('Auth state changed: Session exists for ${session.user.email}');
    return await authService.getCurrentUser();
  });
});

/// 인증 상태 Provider (로그인 여부)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// 닉네임 설정 여부 Provider
final hasNicknameProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.hasNickname ?? false,
    orElse: () => false,
  );
});

/// AuthNotifier - 인증 관련 액션 처리
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  /// Google 로그인
  Future<UserVo?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
      return user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// 닉네임 중복 검사
  Future<bool> isNicknameAvailable(String nickname) async {
    try {
      return await _authService.isNicknameAvailable(nickname);
    } catch (e, stackTrace) {
      AppLogger.auth.e('Failed to check nickname', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 닉네임 업데이트
  Future<UserVo> updateNickname(String nickname) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _authService.updateNickname(nickname);
      state = const AsyncValue.data(null);
      return updatedUser;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// AuthNotifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Supabase 초기화 Provider
final supabaseInitProvider = FutureProvider<void>((ref) async {
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    AppLogger.auth.i('Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.auth.e('Failed to initialize Supabase', error: e, stackTrace: stackTrace);
    rethrow;
  }
});