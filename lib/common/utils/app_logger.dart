import 'package:logger/logger.dart';

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
class AppLogger {
  // 싱글톤 패턴
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // 콘솔 출력만 사용
  static final _consoleOutput = ConsoleOutput();

  // 카테고리별 로거
  static final Logger timer = Logger(
    output: _consoleOutput,
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
    output: _consoleOutput,
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
    output: _consoleOutput,
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
    output: _consoleOutput,
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

}
