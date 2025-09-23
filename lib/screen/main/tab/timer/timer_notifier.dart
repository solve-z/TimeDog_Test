import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_timer.dart';
import 'notification_service.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(const TimerState()) {
    _loadSettings();
    _initializeNotifications();
  }

  Timer? _timer;
  final NotificationService _notificationService = NotificationService();
  static const String _settingsKey = 'timer_settings';

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      final settings = TimerSettings.fromJson(jsonDecode(settingsJson));
      state = state.copyWith(
        settings: settings,
        currentTime: settings.focusTime,
      );
    }
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_settingsKey, jsonEncode(state.settings.toJson()));
  }

  void toggleMode() {
    _stopTimer();
    final newMode =
        state.mode == TimerMode.pomodoro
            ? TimerMode.stopwatch
            : TimerMode.pomodoro;

    if (newMode == TimerMode.pomodoro) {
      state = TimerState(
        mode: newMode,
        settings: state.settings,
        currentTime: state.settings.focusTime,
      );
    } else {
      state = TimerState(
        mode: newMode,
        settings: state.settings,
        currentTime: Duration.zero,
      );
    }
  }

  void start() async {
    if (state.status == TimerStatus.running) return;

    // 기존 완료 알림 취소 (다음 라운드 시작 시)
    await _notificationService.cancelAllNotifications();

    // 완료 상태에서 시작하면 새로운 사이클 시작
    if (state.status == TimerStatus.stopped && state.completedRounds == state.settings.totalRounds) {
      state = TimerState(
        mode: state.mode,
        status: TimerStatus.running,
        settings: state.settings,
        currentTime: state.settings.focusTime,
        currentRound: 1,
        round: PomodoroRound.focus,
        startTime: DateTime.now(),
      );
    } else {
      final now = DateTime.now();
      state = state.copyWith(status: TimerStatus.running, startTime: now);
    }

    try {
      // 백그라운드 실행 활성화
      await _notificationService.enableBackgroundExecution();
    } catch (e) {
      print('백그라운드 실행 활성화 실패: $e');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == TimerMode.pomodoro) {
        _updatePomodoroTimer();
      } else {
        _updateStopwatchTimer();
      }
      _updateRunningNotification();
    });
  }

  void pause() async {
    if (state.status != TimerStatus.running) return;

    _stopTimer();
    state = state.copyWith(status: TimerStatus.paused);

    try {
      // 백그라운드 실행 비활성화 및 알림 제거
      await _notificationService.disableBackgroundExecution();
      await _notificationService.cancelRunningNotification();
    } catch (e) {
      print('백그라운드 실행 비활성화 실패: $e');
    }
  }

  void stop() async {
    _stopTimer();
    if (state.mode == TimerMode.pomodoro) {
      state = state.copyWith(
        status: TimerStatus.stopped,
        currentTime: state.targetTime,
      );
    } else {
      state = state.copyWith(
        status: TimerStatus.stopped,
        currentTime: Duration.zero,
      );
    }

    try {
      // 백그라운드 실행 비활성화 및 알림 제거
      await _notificationService.disableBackgroundExecution();
      await _notificationService.cancelRunningNotification();
    } catch (e) {
      print('백그라운드 실행 비활성화 실패: $e');
    }
  }

  void reset() async {
    _stopTimer();
    if (state.mode == TimerMode.pomodoro) {
      state = TimerState(
        mode: TimerMode.pomodoro,
        settings: state.settings,
        currentTime: state.settings.focusTime,
      );
    } else {
      state = TimerState(
        mode: TimerMode.stopwatch,
        settings: state.settings,
        currentTime: Duration.zero,
      );
    }

    try {
      // 백그라운드 실행 비활성화 및 알림 제거
      await _notificationService.disableBackgroundExecution();
      await _notificationService.cancelRunningNotification();
    } catch (e) {
      print('백그라운드 실행 비활성화 실패: $e');
    }
  }

  void updateSettings(TimerSettings newSettings) {
    state = state.copyWith(settings: newSettings);
    _saveSettings();

    if (state.status == TimerStatus.stopped) {
      state = state.copyWith(currentTime: newSettings.focusTime);
    }
  }

  void _updatePomodoroTimer() {
    if (state.currentTime.inSeconds > 0) {
      state = state.copyWith(
        currentTime: Duration(seconds: state.currentTime.inSeconds - 1),
      );

      // 0초가 되면 즉시 완료 처리
      if (state.currentTime.inSeconds == 0) {
        _handlePomodoroRoundComplete();
      }
    }
  }

  void _updateStopwatchTimer() {
    state = state.copyWith(
      currentTime: Duration(seconds: state.currentTime.inSeconds + 1),
    );
  }

  void _handlePomodoroRoundComplete() async {
    final endTime = DateTime.now();

    if (state.round == PomodoroRound.focus) {
      // 집중 시간 완료 → 휴식으로 전환
      _stopTimer(); // 타이머 정지
      await _notificationService.cancelRunningNotification(); // 실행 중 알림 취소
      await _notificationService.showTimerCompleteNotification(
        title: '집중 시간 완료!',
        message: '휴식 시간으로 전환합니다. 시작 버튼을 눌러주세요.',
      );

      final isLongBreak = state.currentRound == state.settings.totalRounds;
      final nextRound =
          isLongBreak ? PomodoroRound.longBreak : PomodoroRound.shortBreak;

      state = state.copyWith(
        status: TimerStatus.paused,
        round: nextRound,
        currentTime:
            nextRound == PomodoroRound.longBreak
                ? state.settings.longBreakTime
                : state.settings.shortBreakTime,
        endTime: endTime,
        startTime: null,
        completedRounds: state.currentRound, // 집중 시간 완료 시 라운드 완료 카운트
      );
    } else {
      // 휴식 시간 완료
      if (state.currentRound < state.settings.totalRounds) {
        // 아직 더 해야할 라운드가 있음 → 다음 집중 시간으로
        _stopTimer(); // 타이머 정지
        await _notificationService.cancelRunningNotification(); // 실행 중 알림 취소
        await _notificationService.showTimerCompleteNotification(
          title: '휴식 시간 완료!',
          message: '다음 집중 시간으로 전환합니다. 시작 버튼을 눌러주세요.',
        );

        state = state.copyWith(
          status: TimerStatus.paused,
          currentRound: state.currentRound + 1,
          round: PomodoroRound.focus,
          currentTime: state.settings.focusTime,
          endTime: endTime,
          startTime: null,
        );
      } else {
        // 마지막 라운드의 휴식 완료 → 모든 라운드 완료
        await _notificationService.cancelRunningNotification(); // 실행 중 알림 취소
        await _notificationService.showTimerCompleteNotification(
          title: '뽀모도로 완료! 🎉',
          message: '모든 라운드를 완료했습니다!',
        );

        _stopTimer();
        state = TimerState(
          mode: TimerMode.pomodoro,
          status: TimerStatus.stopped,
          settings: state.settings,
          currentTime: state.settings.focusTime,
          currentRound: 1,
          round: PomodoroRound.focus,
          endTime: endTime,
          completedRounds: state.settings.totalRounds, // 모든 라운드 완료 표시
        );
        await _notificationService.disableBackgroundExecution();
        await _notificationService.cancelRunningNotification();
      }
    }
  }

  void _updateRunningNotification() async {
    if (state.status != TimerStatus.running) return;

    // 00:00일 때는 알림 업데이트 안함 (완료 알림이 곧 표시될 예정)
    if (state.currentTime.inSeconds == 0) return;

    String phase;
    if (state.mode == TimerMode.pomodoro) {
      switch (state.round) {
        case PomodoroRound.focus:
          phase = '집중 시간 (${state.currentRound}/${state.settings.totalRounds})';
          break;
        case PomodoroRound.shortBreak:
          phase = '짧은 휴식';
          break;
        case PomodoroRound.longBreak:
          phase = '긴 휴식';
          break;
      }
    } else {
      phase = '스톱워치';
    }

    await _notificationService.showTimerRunningNotification(
      timeRemaining: state.formattedTime,
      phase: phase,
    );
  }

  void _stopTimer() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() async {
    _stopTimer();
    try {
      await _notificationService.disableBackgroundExecution();
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      print('NotificationService 정리 실패: $e');
    }
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
