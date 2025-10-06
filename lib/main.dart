import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로거 초기화 테스트
  print('🚀 앱 시작');
  final logPath = await AppLogger.getLogFilePath();
  print('📝 로그 파일 경로: $logPath');

  AppLogger.timer.i('앱 시작됨');

  runApp(
    const ProviderScope(
      child: TimeDogApp(),
    ),
  );
}
