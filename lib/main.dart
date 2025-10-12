import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로거 파일 출력 초기화
  await AppLogger.init();

  // Foreground Task 초기화
  FlutterForegroundTask.initCommunicationPort();

  runApp(const ProviderScope(child: TimeDogApp()));
}
