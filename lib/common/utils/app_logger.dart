import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// 앱 전역 로거
///
/// 사용법:
/// - AppLogger.timer.d('디버그 메시지')
/// - AppLogger.timer.i('정보 메시지')
/// - AppLogger.timer.w('경고 메시지')
/// - AppLogger.timer.e('에러 메시지')
///
/// 로그 파일 확인:
/// - await AppLogger.getLogFilePath() - 로그 파일 경로 확인
/// - await AppLogger.clearLogs() - 로그 파일 삭제
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

  // 파일 로그 출력
  static final _fileOutput = FileLogOutput();

  // 멀티 출력 (콘솔 + 파일)
  static final _multiOutput = MultiOutput([
    ConsoleOutput(),
    _fileOutput,
  ]);

  // 카테고리별 로거
  static final Logger timer = Logger(
    output: _multiOutput,
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
    output: _multiOutput,
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
    output: _multiOutput,
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
    output: _multiOutput,
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

  /// 로그 파일 경로 가져오기
  static Future<String> getLogFilePath() async {
    return await _fileOutput.getLogFilePath();
  }

  /// 로그 파일 삭제
  static Future<void> clearLogs() async {
    await _fileOutput.clearLogs();
  }

  /// 로그 파일 내용 읽기
  static Future<String> readLogs() async {
    return await _fileOutput.readLogs();
  }
}

/// 파일 출력 로거
class FileLogOutput extends LogOutput {
  File? _logFile;
  static const String _logFileName = 'logs/app_logs.txt';

  Future<File> _getLogFile() async {
    if (_logFile != null) return _logFile!;

    try {
      // 항상 Windows PC의 프로젝트 폴더에 저장
      // Android 디바이스에서 실행 중이어도 Windows 폴더에 저장
      final windowsLogPath = r'C:\Users\dltkd\Desktop\timedog_test\logs\app_logs.txt';
      final windowsLogDir = r'C:\Users\dltkd\Desktop\timedog_test\logs';

      // 디렉토리 생성
      final logDir = Directory(windowsLogDir);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
        print('📁 로그 디렉토리 생성: ${logDir.path}');
      }

      _logFile = File(windowsLogPath);

      // 파일이 없으면 생성
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
        print('📝 로그 파일 생성: $windowsLogPath');
      } else {
        print('📝 로그 파일 경로: $windowsLogPath');
      }

      return _logFile!;
    } catch (e) {
      print('❌ 로그 파일 생성 실패: $e');
      print('❌ 상세 정보: ${e.toString()}');

      // 실패 시 fallback으로 앱 문서 폴더 사용
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fallbackPath = '${directory.path}/logs/app_logs.txt';

        final fallbackDir = Directory('${directory.path}/logs');
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }

        _logFile = File(fallbackPath);
        await _logFile!.create(recursive: true);
        print('📝 Fallback 로그 파일 생성: $fallbackPath');

        return _logFile!;
      } catch (e2) {
        print('❌ Fallback도 실패: $e2');
        rethrow;
      }
    }
  }

  @override
  void output(OutputEvent event) {
    // 비동기 작업을 동기적으로 처리하지 않고, Future를 실행만 시킴
    _writeToFile(event).catchError((e) {
      print('❌ 로그 파일 쓰기 실패: $e');
    });
  }

  Future<void> _writeToFile(OutputEvent event) async {
    try {
      final file = await _getLogFile();

      for (var line in event.lines) {
        // ANSI 색상 코드 제거 (파일에는 텍스트만 저장)
        final cleanLine = _removeAnsiColors(line);
        await file.writeAsString(
          '$cleanLine\n',
          mode: FileMode.append,
          flush: true,
        );
      }
    } catch (e) {
      print('❌ 로그 파일 쓰기 오류: $e');
      rethrow;
    }
  }

  /// ANSI 색상 코드 제거
  String _removeAnsiColors(String text) {
    // ANSI escape codes 패턴
    final ansiPattern = RegExp(r'\x1B\[[0-9;]*m');
    return text.replaceAll(ansiPattern, '');
  }

  /// 로그 파일 경로 가져오기
  Future<String> getLogFilePath() async {
    final file = await _getLogFile();
    return file.path;
  }

  /// 로그 파일 삭제
  Future<void> clearLogs() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        await file.delete();
        _logFile = null;
        print('🗑️  로그 파일 삭제됨');
      }
    } catch (e) {
      print('❌ 로그 파일 삭제 실패: $e');
    }
  }

  /// 로그 파일 내용 읽기
  Future<String> readLogs() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '로그 파일이 비어있습니다.';
    } catch (e) {
      return '로그 파일 읽기 실패: $e';
    }
  }
}
