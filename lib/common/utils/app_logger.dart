import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 앱 전역 로거
///
/// 사용법:
/// - AppLogger.timer.d('디버그 메시지')
/// - AppLogger.timer.i('정보 메시지')
/// - AppLogger.timer.w('경고 메시지')
/// - AppLogger.timer.e('에러 메시지')
///
/// 카테고리별 로거:
/// - AppLogger.timer: 타이머 관련 로그
/// - AppLogger.music: 음악 관련 로그
/// - AppLogger.sound: 완료 사운드 관련 로그
/// - AppLogger.video: 비디오 관련 로그
/// - AppLogger.statistics: 통계 관련 로그
/// - AppLogger.auth: 인증 관련 로그
class AppLogger {
  // 싱글톤 패턴
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // 파일 출력 추가
  static MultiOutput? _multiOutput;

  static Future<void> init() async {
    if (_multiOutput != null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/logs/app_logs.txt');

      // 로그 디렉토리 생성
      if (!await logFile.parent.exists()) {
        await logFile.parent.create(recursive: true);
      }

      // 기존 로그 파일 삭제 (새로운 세션 시작)
      if (await logFile.exists()) {
        await logFile.delete();
      }

      _multiOutput = MultiOutput([
        ConsoleOutput(),
        FileOutput(file: logFile),
      ]);

      print('✅ 로그 파일 초기화 완료: ${logFile.path}');
    } catch (e) {
      print('❌ 로그 파일 초기화 실패: $e');
      _multiOutput = MultiOutput([ConsoleOutput()]);
    }
  }

  // 콘솔 + 파일 출력 (초기화 전에는 콘솔만)
  static LogOutput get _output => _multiOutput ?? ConsoleOutput();

  // 카테고리별 로거
  static final Logger timer = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '🎯 [TIMER]',
      info: '⏰ [TIMER]',
      warning: '⚠️  [TIMER]',
      error: '❌ [TIMER]',
    ),
  );

  static final Logger music = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '🎵 [MUSIC]',
      info: '🎶 [MUSIC]',
      warning: '⚠️  [MUSIC]',
      error: '❌ [MUSIC]',
    ),
  );

  static final Logger sound = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '🔔 [SOUND]',
      info: '🔔 [SOUND]',
      warning: '⚠️  [SOUND]',
      error: '❌ [SOUND]',
    ),
  );

  static final Logger video = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '🎬 [VIDEO]',
      info: '📹 [VIDEO]',
      warning: '⚠️  [VIDEO]',
      error: '❌ [VIDEO]',
    ),
  );

  static final Logger statistics = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '📊 [STATS]',
      info: '📈 [STATS]',
      warning: '⚠️  [STATS]',
      error: '❌ [STATS]',
    ),
  );

  static final Logger auth = Logger(
    output: _output,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: '🔐 [AUTH]',
      info: '🔑 [AUTH]',
      warning: '⚠️  [AUTH]',
      error: '❌ [AUTH]',
    ),
  );

}
