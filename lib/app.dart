import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/s_main.dart';
import 'features/animation/providers/video_controller_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/s_login_test.dart';
import 'common/constants/app_constants.dart';

class TimeDogApp extends ConsumerWidget {
  const TimeDogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 시작 시 비디오 컨트롤러 미리 로드 (백그라운드에서 초기화)
    ref.read(videoControllerProvider);

    // Supabase 초기화
    final supabaseInit = ref.watch(supabaseInitProvider);

    return MaterialApp(
      title: 'TimeDog',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: supabaseInit.when(
        data: (_) => const LoginTestScreen(), // 테스트용 로그인 화면
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('초기화 실패: $error')),
        ),
      ),
    );
  }
}
