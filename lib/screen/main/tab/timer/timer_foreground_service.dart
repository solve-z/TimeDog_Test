import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'package:timedog_test/screen/main/tab/timer/notification_service.dart';

/// TaskHandler: Isolate에서 실행되는 타이머 백그라운드 작업
@pragma('vm:entry-point')
class TimerTaskHandler extends TaskHandler {
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  String _phase = '집중 시간';

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    AppLogger.timer.i('[TaskHandler] 서비스 시작');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // 주기적 이벤트 (사용하지 않음 - 우리는 Timer 사용)
  }

  @override
  void onReceiveData(Object data) {
    AppLogger.timer.d('[TaskHandler] 데이터 수신: $data');

    if (data is Map<String, dynamic>) {
      final command = data['command'] as String?;

      switch (command) {
        case 'start':
          _remainingSeconds = data['remainingSeconds'] as int? ?? 0;
          _phase = data['phase'] as String? ?? '집중 시간';
          _startTimer();
          break;

        case 'pause':
          _pauseTimer();
          break;

        case 'stop':
          _stopTimer();
          break;

        case 'update':
          _remainingSeconds = data['remainingSeconds'] as int? ?? 0;
          _phase = data['phase'] as String? ?? '집중 시간';
          if (_isRunning) {
            _updateNotification();
          }
          break;

        case 'resume':
          _remainingSeconds = data['remainingSeconds'] as int? ?? 0;
          _phase = data['phase'] as String? ?? '집중 시간';
          _startTimer();
          break;
      }
    }
  }

  void _startTimer() {
    AppLogger.timer.i('[TaskHandler] 타이머 시작 - 남은 시간: $_remainingSeconds초');

    _stopTimer(); // 기존 타이머 정리
    _isRunning = true;

    // 즉시 알림 업데이트
    _updateNotification();

    // 1초마다 타이머 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      _remainingSeconds--;

      // 알림 업데이트 (1초마다)
      _updateNotification();

      // UI로는 5초마다만 전송 (성능 최적화)
      if (_remainingSeconds % 5 == 0) {
        _sendDataToUI({
          'event': 'timerTick',
          'remainingSeconds': _remainingSeconds,
        });
      }

      if (_remainingSeconds <= 0) {
        AppLogger.timer.i('[TaskHandler] 타이머 완료');
        _isRunning = false;
        timer.cancel();

        // 완료 알림 표시 (같은 알림 업데이트)
        _showCompleteNotification();

        // UI에 완료 이벤트 전송
        _sendDataToUI({'event': 'timerComplete'});
      }
    });
  }

  void _pauseTimer() {
    AppLogger.timer.i('[TaskHandler] 타이머 일시정지');
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    // 일시정지 알림 표시
    FlutterForegroundTask.updateService(
      notificationTitle: 'TimeDog - $_phase - 일시정지',
      notificationText: '남은 시간: ${_formatTime(_remainingSeconds)}',
    );
  }

  void _stopTimer() {
    AppLogger.timer.i('[TaskHandler] 타이머 정지');
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void _updateNotification() {
    final timeString = _formatTime(_remainingSeconds);

    FlutterForegroundTask.updateService(
      notificationTitle: 'TimeDog - $_phase',
      notificationText: '남은 시간: $timeString',
    );
  }

  void _showCompleteNotification() async {
    String title = '';
    String message = '';

    if (_phase.contains('집중')) {
      title = '🎉 집중 시간 완료!';
      message = '휴식 시간으로 전환합니다. 시작 버튼을 눌러주세요.';
    } else if (_phase.contains('휴식')) {
      title = '💪 휴식 시간 완료!';
      message = '다음 집중 시간으로 전환합니다. 시작 버튼을 눌러주세요.';
    } else {
      title = '🎉 타이머 완료!';
      message = '수고하셨습니다!';
    }

    AppLogger.timer.i('[TaskHandler] 완료 알림 표시: $title');

    // 별도 채널로 완료 알림 표시 (팝업, 화면 꺼져있어도 표시)
    try {
      await NotificationService().showCompletionNotification(
        title: title,
        message: message,
      );
    } catch (e) {
      AppLogger.timer.e('[TaskHandler] 완료 알림 표시 실패: $e');
    }

    // Foreground Service 중지 (완료 알림만 남김)
    await FlutterForegroundTask.stopService();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes : $secs';
  }

  void _sendDataToUI(Map<String, dynamic> data) {
    FlutterForegroundTask.sendDataToMain(data);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    AppLogger.timer.w('[TaskHandler] 서비스 종료 (앱 종료 감지)');
    _stopTimer();

    // 앱이 종료될 때 타이머를 stopped 상태로 변경
    // UI에 종료 이벤트 전송 (앱이 아직 실행 중이라면 처리됨)
    _sendDataToUI({'event': 'appTerminated'});
  }

  @override
  void onNotificationButtonPressed(String id) {
    AppLogger.timer.d('[TaskHandler] 알림 버튼 클릭: $id');
  }

  @override
  void onNotificationPressed() {
    AppLogger.timer.d('[TaskHandler] 알림 클릭 - 앱으로 이동');
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {
    AppLogger.timer.d('[TaskHandler] 알림 닫힘');
  }
}

/// Foreground Service 관리 클래스
class TimerForegroundService {
  static final TimerForegroundService _instance =
      TimerForegroundService._internal();
  factory TimerForegroundService() => _instance;
  TimerForegroundService._internal();

  bool _isInitialized = false;
  ReceivePort? _receivePort;
  Function(Map<String, dynamic>)? _onDataReceived;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    AppLogger.timer.i('[ForegroundService] 초기화 시작');

    // Foreground Service 알림 설정 (타이머 진행 상태만 표시)
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'timer_foreground',
        channelName: 'Timer Progress',
        channelDescription: 'Shows timer progress in status bar',
        channelImportance: NotificationChannelImportance.MIN, // 팝업 없음
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
        showWhen: false,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
        playSound: false,
        enableVibration: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000), // 5초마다 체크
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );

    _isInitialized = true;
    AppLogger.timer.i('[ForegroundService] 초기화 완료');
  }

  /// 데이터 수신 콜백 설정
  void setDataReceivedCallback(Function(Map<String, dynamic>) callback) {
    _onDataReceived = callback;
  }

  /// 서비스 시작
  Future<bool> startService({
    required int remainingSeconds,
    required String phase,
  }) async {
    await initialize();

    AppLogger.timer.i(
      '[ForegroundService] 서비스 시작 요청 - 남은 시간: $remainingSeconds초',
    );

    // ReceivePort 설정 - 서비스 시작 전에 리스너 등록
    _setupReceivePort();

    // 이미 서비스가 실행 중인지 확인
    final isRunning = await FlutterForegroundTask.isRunningService;

    if (isRunning) {
      AppLogger.timer.w('[ForegroundService] 서비스가 이미 실행 중 - 재시작');

      // 기존 서비스 정지
      final stopResult = await FlutterForegroundTask.stopService();
      if (stopResult is ServiceRequestSuccess) {
        AppLogger.timer.i('[ForegroundService] 기존 서비스 정지 성공');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    final timeString = _formatTime(remainingSeconds);

    final result = await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'TimeDog - $phase',
      notificationText: '남은 시간: $timeString',
      notificationIcon: null,
      notificationButtons: [],
      callback: startCallback,
    );

    // sealed class이므로 타입 체크로 성공 여부 확인
    if (result is ServiceRequestSuccess) {
      AppLogger.timer.i('[ForegroundService] 서비스 시작 성공');

      // TaskHandler에 시작 명령 전송
      await Future.delayed(const Duration(milliseconds: 100));
      sendCommand({
        'command': 'start',
        'remainingSeconds': remainingSeconds,
        'phase': phase,
      });

      return true;
    } else if (result is ServiceRequestFailure) {
      AppLogger.timer.e('[ForegroundService] 서비스 시작 실패: ${result.error}');
      return false;
    }

    return false;
  }

  /// ReceivePort 설정
  void _setupReceivePort() {
    if (_receivePort != null) return;

    _receivePort = ReceivePort();
    _receivePort!.listen((data) {
      if (data is Map<String, dynamic>) {
        AppLogger.timer.d('[ForegroundService] TaskHandler에서 데이터 수신: $data');
        _onDataReceived?.call(data);
      }
    });
  }

  /// 서비스 일시정지
  Future<void> pauseService() async {
    AppLogger.timer.i('[ForegroundService] 일시정지 명령 전송');
    sendCommand({'command': 'pause'});
  }

  /// 서비스 재개
  Future<void> resumeService({
    required int remainingSeconds,
    required String phase,
  }) async {
    AppLogger.timer.i('[ForegroundService] 재개 명령 전송');
    sendCommand({
      'command': 'resume',
      'remainingSeconds': remainingSeconds,
      'phase': phase,
    });
  }

  /// 서비스 업데이트
  Future<void> updateService({
    required int remainingSeconds,
    required String phase,
  }) async {
    sendCommand({
      'command': 'update',
      'remainingSeconds': remainingSeconds,
      'phase': phase,
    });
  }

  /// 서비스 정지
  Future<bool> stopService() async {
    AppLogger.timer.i('[ForegroundService] 서비스 정지 요청');

    sendCommand({'command': 'stop'});
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await FlutterForegroundTask.stopService();

    // sealed class이므로 타입 체크로 성공 여부 확인
    if (result is ServiceRequestSuccess) {
      AppLogger.timer.i('[ForegroundService] 서비스 정지 성공');
      return true;
    } else if (result is ServiceRequestFailure) {
      AppLogger.timer.e('[ForegroundService] 서비스 정지 실패: ${result.error}');
      return false;
    }

    return false;
  }

  /// TaskHandler에 명령 전송
  void sendCommand(Map<String, dynamic> data) {
    AppLogger.timer.d('[ForegroundService] 명령 전송: $data');
    FlutterForegroundTask.sendDataToTask(data);
  }

  /// 서비스 실행 여부 확인
  Future<bool> isRunningService() async {
    return await FlutterForegroundTask.isRunningService;
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes : $secs';
  }
}

/// TaskHandler 시작 콜백
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TimerTaskHandler());
}
