import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_timer.dart';
import 'notification_service.dart';

class TimerNotifier extends StateNotifier<TimerState> with WidgetsBindingObserver {
  TimerNotifier() : super(const TimerState()) {
    _initializeState();
    _initializeNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  Timer? _timer;
  DateTime? _targetEndTime;
  final NotificationService _notificationService = NotificationService();
  static const String _settingsKey = 'timer_settings';
  static const String _stateKey = 'timer_state';

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _initializeState() async {
    final prefs = await SharedPreferences.getInstance();

    // 설정 로드
    final settingsJson = prefs.getString(_settingsKey);
    TimerSettings settings = const TimerSettings();
    if (settingsJson != null) {
      settings = TimerSettings.fromJson(jsonDecode(settingsJson));
    }

    // 저장된 상태 로드 및 복원
    final stateJson = prefs.getString(_stateKey);
    if (stateJson != null) {
      try {
        final savedState = TimerState.fromJson(jsonDecode(stateJson));
        final restoredState = _restoreTimerState(savedState, settings);
        state = restoredState;

        // 복원된 상태가 실행 중이었다면 타이머 재시작
        if (restoredState.status == TimerStatus.running) {
          _startTimer();
        }
      } catch (e) {
        print('상태 복원 실패: $e');
        state = TimerState(settings: settings, currentTime: settings.focusTime);
      }
    } else {
      // 저장된 상태가 없으면 기본 상태
      state = TimerState(settings: settings, currentTime: settings.focusTime);
    }
  }

  TimerState _restoreTimerState(TimerState savedState, TimerSettings currentSettings) {
    // 실행 중인 타이머가 있었는지 확인
    // 타이머가 "실행 중" 상태였고, 시작/종료 시간이 기록되어 있으면 → 복원을 시도
    if (savedState.status == TimerStatus.running && savedState.startTime != null && savedState.endTime != null) {
      final now = DateTime.now();
      final targetEndTime = savedState.endTime!;

      if (now.isAfter(targetEndTime)) {
        // 이미 완료된 상태 - 다음 phase로 전환
        return _calculateCompletedState(savedState, currentSettings, now.difference(targetEndTime));
      } else {
        // 아직 진행 중 - 남은 시간으로 복원
        final remainingTime = targetEndTime.difference(now);
        _targetEndTime = targetEndTime; // 복원된 종료 시간 설정

        return savedState.copyWith(
          settings: currentSettings,
          currentTime: remainingTime,
        );
      }
    }

    // 실행 중이 아니었다면 그대로 복원 (설정만 업데이트)
    return savedState.copyWith(settings: currentSettings);
  }

  TimerState _calculateCompletedState(TimerState savedState, TimerSettings settings, Duration elapsed) {
    // 복잡한 계산이 필요한 경우 (여러 phase를 지나친 경우)
    // 간단히 다음 phase로 전환된 일시정지 상태로 설정
    if (savedState.round == PomodoroRound.focus) {
      final isLongBreak = savedState.currentRound == settings.totalRounds;
      final nextRound = isLongBreak ? PomodoroRound.longBreak : PomodoroRound.shortBreak;

      return savedState.copyWith(
        settings: settings,
        status: TimerStatus.paused,
        round: nextRound,
        currentTime: nextRound == PomodoroRound.longBreak
            ? settings.longBreakTime
            : settings.shortBreakTime,
        completedRounds: savedState.currentRound,
        endTime: DateTime.now(),
        startTime: null,
      );
    } else {
      // 휴식 완료
      if (savedState.currentRound < settings.totalRounds) {
        return savedState.copyWith(
          settings: settings,
          status: TimerStatus.paused,
          currentRound: savedState.currentRound + 1,
          round: PomodoroRound.focus,
          currentTime: settings.focusTime,
          endTime: DateTime.now(),
          startTime: null,
        );
      } else {
        // 모든 라운드 완료
        return TimerState(
          settings: settings,
          status: TimerStatus.stopped,
          currentTime: settings.focusTime,
          completedRounds: settings.totalRounds,
          endTime: DateTime.now(),
        );
      }
    }
  }


  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_settingsKey, jsonEncode(state.settings.toJson()));
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_stateKey, jsonEncode(state.toJson()));
  }

  void _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_stateKey);
  }

  void _startTimer() {
    final now = DateTime.now();

    // 목표 종료 시간이 없으면 설정
    if (_targetEndTime == null) {
      _targetEndTime = now.add(state.currentTime);
    }

    // endTime을 상태에도 저장
    state = state.copyWith(endTime: _targetEndTime);
    _saveState();

    // 시작 시에는 즉시 알림만 업데이트 (시간 표시는 그대로 유지)
    _updateRunningNotification();

    // 다음 정각 초까지의 지연 시간 계산하여 정확한 타이밍으로 시작
    final currentMs = DateTime.now().millisecond;
    final delayToNextSecond = Duration(milliseconds: 1000 - currentMs);


    // 첫 번째 업데이트는 다음 정각 초에
    Timer(delayToNextSecond, () {
      if (_timer == null) return; // 이미 취소된 경우

      if (state.mode == TimerMode.pomodoro) {
        _updatePomodoroTimer();
      } else {
        _updateStopwatchTimer();
      }
      _updateRunningNotification();

      // 그 후 정확히 1초마다 주기적 업데이트
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.mode == TimerMode.pomodoro) {
          _updatePomodoroTimer();
        } else {
          _updateStopwatchTimer();
        }
        _updateRunningNotification();
      });
    });

    // 임시 타이머 설정 (취소 가능하도록)
    _timer = Timer(Duration.zero, () {});
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

    // 이전 타이머 상태 초기화
    _targetEndTime = null;

    final now = DateTime.now();

    // 완료 상태에서 시작하면 새로운 사이클 시작
    if (state.status == TimerStatus.stopped && state.completedRounds == state.settings.totalRounds) {
      _targetEndTime = now.add(state.settings.focusTime);
      state = TimerState(
        mode: state.mode,
        status: TimerStatus.running,
        settings: state.settings,
        currentTime: state.settings.focusTime,
        currentRound: 1,
        round: PomodoroRound.focus,
        startTime: now,
        endTime: _targetEndTime,
      );
    } else {
      // 새로운 타이머 시작 또는 일시정지에서 재개
      if (state.status == TimerStatus.paused) {
        // 일시정지에서 재개 - 남은 시간으로 새로운 종료 시간 계산
        _targetEndTime = now.add(state.currentTime);
      } else {
        // 새로운 타이머 시작
        _targetEndTime = now.add(state.currentTime);
      }

      state = state.copyWith(
        status: TimerStatus.running,
        startTime: now,
        endTime: _targetEndTime,
      );
    }

    // 상태 저장
    _saveState();

    try {
      // 백그라운드 권한 확인 및 요청
      final hasPermission = await _notificationService.requestBatteryOptimizationExemption();
      if (!hasPermission) {
        print('백그라운드 실행 권한이 없습니다. 앱 설정에서 배터리 최적화를 해제해주세요.');
      }

      // 백그라운드 실행 활성화
      final enabled = await _notificationService.enableBackgroundExecution();
      if (!enabled) {
        print('백그라운드 실행 활성화 실패. 상태 저장으로 대체됩니다.');
      }

    } catch (e) {
      print('백그라운드 실행 활성화 실패: $e');
    }

    // 비동기 작업으로 인한 지연을 보정하기 위해 목표 시간 재계산
    final actualNow = DateTime.now();
    _targetEndTime = actualNow.add(state.currentTime);
    state = state.copyWith(endTime: _targetEndTime);


    _startTimer();
  }

  void pause() async {
    if (state.status != TimerStatus.running) return;

    _stopTimer();

    // 현재 남은 시간을 정확히 계산
    if (_targetEndTime != null) {
      final now = DateTime.now();
      final remainingTime = _targetEndTime!.difference(now);

      if (remainingTime.isNegative) {
        // 이미 완료되었다면 완료 처리
        _handlePomodoroRoundComplete();
        return;
      }

      state = state.copyWith(
        status: TimerStatus.paused,
        currentTime: remainingTime,
      );
    } else {
      state = state.copyWith(status: TimerStatus.paused);
    }

    _targetEndTime = null;

    // 상태 저장
    _saveState();

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
    _targetEndTime = null;

    if (state.mode == TimerMode.pomodoro) {
      state = state.copyWith(
        status: TimerStatus.stopped,
        currentTime: state.targetTime,
        clearEndTime: true,
      );
    } else {
      state = state.copyWith(
        status: TimerStatus.stopped,
        currentTime: Duration.zero,
        clearEndTime: true,
      );
    }

    // 상태 저장
    _saveState();

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
    _targetEndTime = null;

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

    // 상태 초기화 (저장된 상태 삭제)
    _clearState();

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
    if (_targetEndTime == null) return;

    final now = DateTime.now();

    // 목표 시간을 초과했는지 먼저 확인 (실제 시간 기준)
    if (now.isAfter(_targetEndTime!) || now.isAtSameMomentAs(_targetEndTime!)) {
      // 타이머 완료 - 실제 시간으로 판단
      print('⏰ 실제 시간 완료: ${now.hour}:${now.minute}:${now.second}');
      state = state.copyWith(currentTime: Duration.zero);
      _handlePomodoroRoundComplete();
      return;
    }

    final remainingTime = _targetEndTime!.difference(now);

    // 남은 시간 업데이트
    state = state.copyWith(currentTime: remainingTime);
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

      // 상태 저장
      _saveState();
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

        // 상태 저장
        _saveState();
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

        // 상태 저장 (완료 상태로)
        _saveState();
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
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    super.didChangeAppLifecycleState(appState);

    switch (appState) {
      case AppLifecycleState.resumed:
        print('📱 앱 복원됨 - 시간 동기화 시작');
        _syncTimerOnResume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('📱 앱 백그라운드로 이동');
        if (state.status == TimerStatus.running) {
          print('   타이머 실행 중 - 상태 저장');
          _saveState();
        }
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _syncTimerOnResume() {
    if (state.status != TimerStatus.running || _targetEndTime == null) return;

    final now = DateTime.now();
    final remainingTime = _targetEndTime!.difference(now);

    print('🔄 시간 동기화 중');
    print('   현재 시간: ${now.hour}:${now.minute}:${now.second}');
    print('   목표 시간: ${_targetEndTime!.hour}:${_targetEndTime!.minute}:${_targetEndTime!.second}');
    print('   남은 시간: ${remainingTime.inSeconds}초 (${remainingTime.inMilliseconds}ms)');

    if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
      // 백그라운드에서 타이머가 완료됨
      print('✅ 백그라운드에서 완료됨');
      state = state.copyWith(currentTime: Duration.zero);
      _handlePomodoroRoundComplete();
    } else {
      // 남은 시간으로 상태 업데이트
      print('⏰ 남은 시간으로 업데이트됨');
      state = state.copyWith(currentTime: remainingTime);
    }
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _targetEndTime = null;
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
