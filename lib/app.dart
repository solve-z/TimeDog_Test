import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screen/main/s_main.dart';
import 'screen/main/tab/timer/video_controller_provider.dart';
import 'common/constant/app_constants.dart';

class TimeDogApp extends ConsumerWidget {
  const TimeDogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 시작 시 비디오 컨트롤러 미리 로드 (백그라운드에서 초기화)
    ref.read(videoControllerProvider);

    return MaterialApp(
      title: 'TimeDog',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
