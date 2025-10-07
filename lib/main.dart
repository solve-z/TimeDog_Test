import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로거 파일 출력 초기화
  await AppLogger.init();

  AppLogger.timer.i('앱 시작됨');
  AppLogger.video.i('VIDEO 로거 테스트 - 앱 초기화');

  runApp(const ProviderScope(child: TimeDogApp()));
}
