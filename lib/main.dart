import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.timer.i('앱 시작됨');

  runApp(const ProviderScope(child: TimeDogApp()));
}
