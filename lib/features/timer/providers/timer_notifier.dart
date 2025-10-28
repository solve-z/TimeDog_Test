import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import '../models/vo_timer.dart';
import '../../../services/notification/notification_service.dart';
import '../services/timer_foreground_service.dart';
import '../../todo/providers/todo_provider.dart';
import '../../todo/models/vo_todo_item.dart';
import '../../music/services/music_player_service.dart';
import '../../music/providers/music_provider.dart';
import '../services/timer_strategy.dart';

class TimerNotifier extends StateNotifier<TimerState>
    with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _timer;
  DateTime? _targetEndTime;
  final NotificationService _notificationService = NotificationService();
  final TimerForegroundService _foregroundService = TimerForegroundService();
  static const String _settingsKey = 'timer_settings';
  static const String _stateKey = 'timer_state';
  bool _backgroundPermissionsInitialized = false;

  // 현재 타이머 전략
  TimerStrategy _strategy = PomodoroStrategy();

  TimerNotifier(this._ref) : super(const TimerState()) {
    _initializeState(); // 저장된 타이머 상태 복원
    _initializeNotifications(); // 알림 초기화
    WidgetsBinding.instance.addObserver(this); // 생명주기 감지 등록
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _foregroundService.initialize();
    await _initializeBackgroundPermissions();

    // Foreground Service 데이터 수신 콜백 설정
    _foregroundService.setDataReceivedCallback((data) {
      final event = data['event'] as String?;
      if (event == 'timerComplete') {
        AppLogger.timer.i('[TimerNotifier] Foreground Service에서 완료 이벤트 수신');
        _handleTimerComplete();
      }
    });
  }

  Future<void> _initializeBackgroundPermissions() async {
    if (_backgroundPermissionsInitialized) return;

    try {
      final hasPermission =
          await _notificationService.requestBatteryOptimizationExemption();
      if (!hasPermission) {
        print('백그라운드 실행 권한이 없습니다. 앱 설정에서 배터리 최적화를 해제해주세요.');
      }
      _backgroundPermissionsInitialized = true;
    } catch (e) {
      print('백그라운드 권한 초기화 실패: $e');
    }
  }

  void _initializeState() async {
    final prefs = await SharedPreferences.getInstance();

    AppLogger.timer.i('=== 타이머 상태 초기화 시작 ===');

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

        // 앱이 정상적으로 백그라운드에 있는지 확인
        final isInBackground = prefs.getBool('app_in_background') ?? false;

        AppLogger.timer.i('📂 저장된 상태 로드:');
        AppLogger.timer.d('   - app_in_background: $isInBackground');
        AppLogger.timer.d('   - savedState.mode: ${savedState.mode}');
        AppLogger.timer.d('   - savedState.status: ${savedState.status}');
        AppLogger.timer.d(
          '   - savedState.currentTime: ${savedState.currentTime.inSeconds}초',
        );

        if (isInBackground) {
          // 백그라운드에서 복귀 → 정상 복원 (running 유지)
          AppLogger.timer.i('✅ 백그라운드에서 복귀 - running 상태 유지');
          AppLogger.timer.d('   저장된 상태: ${savedState.status}');

          // 전략 설정
          _strategy = TimerStrategyFactory.getStrategy(savedState.mode);

          final restoredState = _restoreTimerState(savedState, settings);
          state = restoredState;

          if (restoredState.status == TimerStatus.running) {
            _startTimer();
          }
        } else {
          // 앱 재실행 (정상 종료 or 스와이프로 끄기)
          AppLogger.timer.w('🔄 앱 재실행 감지');
          AppLogger.timer.d('   isInBackground 플래그: $isInBackground');
          AppLogger.timer.d('   저장된 상태: ${savedState.status}');

          // ⚠️ _restoreTimerState 전에 먼저 running 상태 체크!
          if (savedState.status == TimerStatus.running) {
            // 타이머가 실행 중이었는데 백그라운드 플래그가 없음
            // → 앱이 스와이프로 종료됨 → stopped 상태로 변경
            AppLogger.timer.w('❌ 앱이 비정상 종료됨 (스와이프) - stopped 상태로 변경');

            // 전략 설정
            _strategy = TimerStrategyFactory.getStrategy(savedState.mode);

            if (savedState.mode == TimerMode.pomodoro) {
              state = TimerState(
                mode: savedState.mode,
                status: TimerStatus.stopped,
                settings: settings,
                currentTime: settings.focusTime,
                currentRound: savedState.currentRound,
                round: savedState.round,
                completedRounds: savedState.completedRounds,
                roundStatusList: savedState.roundStatusList,
              );
              AppLogger.timer.i(
                '   → stopped 상태로 변경 완료 (Pomodoro, 시간: ${state.currentTime.inSeconds}초)',
              );
            } else {
              state = TimerState(
                mode: savedState.mode,
                status: TimerStatus.stopped,
                settings: settings,
                currentTime: Duration.zero,
              );
              AppLogger.timer.i('   → stopped 상태로 변경 완료 (Stopwatch, 시간: 0초)');
            }
          } else {
            // 정상 상태 복원
            _strategy = TimerStrategyFactory.getStrategy(savedState.mode);
            final restoredState = _restoreTimerState(savedState, settings);
            AppLogger.timer.i('✅ 정상 상태 복원: ${restoredState.status}');
            state = restoredState;
          }
        }

        // 플래그 초기화
        await prefs.setBool('app_in_background', false);
        AppLogger.timer.d('   - app_in_background 플래그 초기화 완료');
      } catch (e) {
        AppLogger.timer.e('상태 복원 실패: $e');
        AppLogger.timer.e('Stack trace: ${StackTrace.current}');
        // 기본 뽀모도로 전략으로 초기화
        _strategy = PomodoroStrategy();
        state = TimerState(settings: settings, currentTime: settings.focusTime);
      }
    } else {
      AppLogger.timer.i('저장된 상태 없음 - 기본 상태로 시작');
      // 저장된 상태가 없으면 기본 상태
      _strategy = PomodoroStrategy();
      state = TimerState(settings: settings, currentTime: settings.focusTime);
    }

    AppLogger.timer.i('=== 타이머 상태 초기화 완료 ===');
    AppLogger.timer.i('   최종 상태: ${state.status}');
    AppLogger.timer.i('   현재 시간: ${state.currentTime.inSeconds}초');
  }

  TimerState _restoreTimerState(
    TimerState savedState,
    TimerSettings currentSettings,
  ) {
    // 실행 중인 타이머가 있었는지 확인
    // 타이머가 "실행 중" 상태였고, 시작/종료 시간이 기록되어 있으면 → 복원을 시도
    if (savedState.status == TimerStatus.running &&
        savedState.startTime != null &&
        savedState.endTime != null) {
      final now = DateTime.now();
      final targetEndTime = savedState.endTime!;

      if (now.isAfter(targetEndTime)) {
        // 이미 완료된 상태 - 다음 phase로 전환
        return _calculateCompletedState(
          savedState,
          currentSettings,
          now.difference(targetEndTime),
        );
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

  TimerState _calculateCompletedState(
    TimerState savedState,
    TimerSettings settings,
    Duration elapsed,
  ) {
    // 복잡한 계산이 필요한 경우 (여러 phase를 지나친 경우)
    // 간단히 다음 phase로 전환된 일시정지 상태로 설정
    if (savedState.round == PomodoroRound.focus) {
      final isLongBreak = savedState.currentRound == settings.totalRounds;
      final nextRound =
          isLongBreak ? PomodoroRound.longBreak : PomodoroRound.shortBreak;

      return savedState.copyWith(
        settings: settings,
        status: TimerStatus.paused,
        round: nextRound,
        currentTime:
            nextRound == PomodoroRound.longBreak
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
    // 기존 타이머가 있다면 완전히 정지
    _stopTimer();

    final now = DateTime.now();

    // 전략에 따라 목표 종료 시간 설정
    if (_targetEndTime == null) {
      _targetEndTime = _strategy.calculateTargetEndTime(now, state.currentTime);
    }

    // endTime을 상태에도 저장
    state = state.copyWith(endTime: _targetEndTime);
    _saveState();

    // 다음 정각 초까지의 지연 시간 계산하여 정확한 타이밍으로 시작
    final currentMs = DateTime.now().millisecond;
    final delayToNextSecond = Duration(milliseconds: 1000 - currentMs);

    // 첫 번째 업데이트는 다음 정각 초에
    Timer(delayToNextSecond, () {
      // 첫 번째 업데이트 실행
      _updateTimer();

      // Foreground Service에 시간 업데이트 전송 (5초마다)
      if (state.currentTime.inSeconds % 5 == 0) {
        _updateForegroundService();
      }

      // 그 후 정확히 1초마다 주기적 업데이트를 위한 새로운 타이머 시작
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTimer();

        // Foreground Service에 시간 업데이트 전송 (5초마다)
        if (state.currentTime.inSeconds % 5 == 0) {
          _updateForegroundService();
        }
      });
    });
  }

  void _updateTimer() {
    _strategy.updateTimer(state, _targetEndTime, (newState) {
      state = newState;
    });

    // 완료 체크
    final now = DateTime.now();
    if (_strategy.shouldComplete(now, _targetEndTime)) {
      _handleTimerComplete();
    }
  }

  void _updateForegroundService() async {
    if (state.status != TimerStatus.running) return;

    try {
      final phase = _getPhaseString();
      await _foregroundService.updateService(
        remainingSeconds: state.currentTime.inSeconds,
        phase: phase,
        isStopwatch: state.mode == TimerMode.stopwatch,
      );
    } catch (e) {
      AppLogger.timer.e('Foreground Service 업데이트 실패: $e');
    }
  }

  void toggleMode() async {
    _stopTimer();
    _targetEndTime = null;

    // Foreground Service 정지
    try {
      await _foregroundService.stopService();
    } catch (e) {
      AppLogger.timer.e('Foreground Service 정지 실패: $e');
    }

    final newMode =
        state.mode == TimerMode.pomodoro
            ? TimerMode.stopwatch
            : TimerMode.pomodoro;

    // 전략 변경
    _strategy = TimerStrategyFactory.getStrategy(newMode);

    // 전략에 따른 초기 상태 설정
    state = _strategy.getInitialState(state.settings);

    // 상태 저장
    _saveState();
  }

  Future<void> start() async {
    if (state.status == TimerStatus.running) return;

    // 할일 선택 여부 확인
    final todoState = _ref.read(todoProvider);
    if (todoState.selectedTodo == null) {
      throw Exception('NO_TODO_SELECTED');
    }

    // 완전히 타이머 정지하고 초기화
    _stopTimer();
    _targetEndTime = null;

    // 기존 완료 알림 취소 (다음 라운드 시작 시)
    await _notificationService.cancelAllNotifications();

    final now = DateTime.now();

    // 완료 상태에서 시작하면 새로운 사이클 시작 (뽀모도로만)
    if (state.status == TimerStatus.stopped &&
        state.completedRounds == state.settings.totalRounds &&
        state.mode == TimerMode.pomodoro) {
      _targetEndTime = _strategy.calculateTargetEndTime(
        now,
        state.settings.focusTime,
      );
      state = TimerState(
        mode: state.mode,
        status: TimerStatus.running,
        settings: state.settings,
        currentTime: state.settings.focusTime,
        currentRound: 1,
        round: PomodoroRound.focus,
        startTime: now,
        endTime: _targetEndTime,
        roundStatusList: List.generate(
          state.settings.totalRounds,
          (_) => RoundStatus.notStarted,
        ),
      );
    }
    // 새로운 타이머 시작 또는 일시정지에서 재개
    else if (state.status == TimerStatus.stopped &&
        state.mode == TimerMode.stopwatch) {
      state = state.copyWith(status: TimerStatus.running, startTime: now);
    } else {
      _targetEndTime = _strategy.calculateTargetEndTime(now, state.currentTime);

      // 일시정지에서 재개하는 경우 startTime을 현재 시간으로 새로 설정
      state = state.copyWith(
        status: TimerStatus.running,
        startTime: now, // 항상 현재 시간으로 설정
        endTime: _targetEndTime,
      );
    }

    // 상태 저장
    _saveState();

    AppLogger.timer.i('타이머 시작 - 현재 시간: ${state.currentTime.inSeconds}초');
    if (_targetEndTime != null) {
      AppLogger.timer.d(
        '목표 종료 시간: ${_targetEndTime!.hour}:${_targetEndTime!.minute}:${_targetEndTime!.second}',
      );
    }
    AppLogger.timer.d('라운드: ${state.round}, 상태: ${state.status}');

    // Foreground Service 시작
    try {
      final phase = _getPhaseString();
      final started = await _foregroundService.startService(
        remainingSeconds: state.currentTime.inSeconds,
        phase: phase,
        isStopwatch: state.mode == TimerMode.stopwatch,
      );

      if (!started) {
        AppLogger.timer.e('Foreground Service 시작 실패');
      }
    } catch (e) {
      AppLogger.timer.e('Foreground Service 시작 오류: $e');
    }

    // 타이머 시작 (비디오 재생 시작)
    _startTimer();

    // 비디오 재생 후 음악 재생 (비디오가 먼저 오디오 포커스를 가진 후 음악 재생)
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final musicNotifier = _ref.read(musicProvider.notifier);
      await musicNotifier.ensureLoaded();

      final musicSelection = _ref.read(musicProvider);
      final musicPlayerService = _ref.read(musicPlayerServiceProvider);
      print('🎵 [타이머] 음악 재생 시도 - 음악 ID: ${musicSelection.musicId}');

      if (musicSelection.musicId != 'none') {
        await musicPlayerService.playMusic(musicSelection.musicId);
        print('🎵 [타이머] 음악 재생 완료');
      } else {
        print('🎵 [타이머] 음악 선택 없음');
      }
    } catch (e) {
      print('❌ [타이머] 음악 재생 실패: $e');
    }
  }

  String _getPhaseString() {
    if (state.mode == TimerMode.stopwatch) {
      return '스톱워치';
    }

    switch (state.round) {
      case PomodoroRound.focus:
        return '집중 시간 (${state.currentRound}/${state.settings.totalRounds})';
      case PomodoroRound.shortBreak:
        return '짧은 휴식';
      case PomodoroRound.longBreak:
        return '긴 휴식';
    }
  }

  void pause() async {
    if (state.status != TimerStatus.running) return;

    // 음악 일시정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.pauseMusic();

    final pauseTime = DateTime.now();

    // 전략에 따라 집중시간 기록 여부 결정
    if (state.startTime != null && _strategy.shouldRecordFocusTime(state)) {
      final todoNotifier = _ref.read(todoProvider.notifier);
      final todoState = _ref.read(todoProvider);
      if (todoState.selectedTodo != null) {
        final focusType =
            state.mode == TimerMode.stopwatch
                ? FocusType.stopwatch
                : FocusType.pomodoro;

        final focusRecord = FocusTimeRecord(
          id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
          startTime: state.startTime!,
          endTime: pauseTime,
          focusType: focusType,
        );
        await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);
      }
    }

    // 완전히 타이머 정지
    _stopTimer();

    // 현재 남은 시간을 정확히 계산 (뽀모도로만)
    if (_targetEndTime != null && state.mode == TimerMode.pomodoro) {
      final now = DateTime.now();
      final remainingTime = _targetEndTime!.difference(now);

      if (remainingTime.isNegative) {
        // 이미 완료되었다면 완료 처리
        _handleTimerComplete();
        return;
      }

      state = state.copyWith(
        status: TimerStatus.paused,
        currentTime: remainingTime,
        endTime: pauseTime,
      );
    } else {
      state = state.copyWith(status: TimerStatus.paused, endTime: pauseTime);
    }

    // 타이머 상태 완전히 초기화
    _targetEndTime = null;

    // 상태 저장
    _saveState();

    try {
      // Foreground Service 일시정지
      await _foregroundService.pauseService();
    } catch (e) {
      AppLogger.timer.e('Foreground Service 일시정지 실패: $e');
    }
  }

  void stop() async {
    // 음악 정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.stopMusic();

    final stopTime = DateTime.now();

    // 전략에 따라 집중시간 기록 여부 결정
    if (state.status == TimerStatus.running &&
        state.startTime != null &&
        _strategy.shouldRecordFocusTime(state)) {
      final todoNotifier = _ref.read(todoProvider.notifier);
      final todoState = _ref.read(todoProvider);
      if (todoState.selectedTodo != null) {
        final focusType =
            state.mode == TimerMode.stopwatch
                ? FocusType.stopwatch
                : FocusType.pomodoro;

        final focusRecord = FocusTimeRecord(
          id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
          startTime: state.startTime!,
          endTime: stopTime,
          focusType: focusType,
        );
        await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);
      }
    }

    _stopTimer();
    _targetEndTime = null;

    // 전략에 따라 초기화 시간 설정
    final resetTime = _strategy.getResetTime(state.settings);

    state = state.copyWith(
      status: TimerStatus.stopped,
      currentTime: resetTime,
      clearEndTime: true,
    );

    // 상태 저장
    _saveState();

    try {
      // Foreground Service 정지
      await _foregroundService.stopService();
    } catch (e) {
      AppLogger.timer.e('Foreground Service 정지 실패: $e');
    }
  }

  void reset() async {
    // 음악 정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.stopMusic();

    _stopTimer();
    _targetEndTime = null;

    // 전략에 따른 초기 상태로 리셋
    state = _strategy.getInitialState(state.settings);

    // 상태 초기화 (저장된 상태 삭제)
    _clearState();

    try {
      // Foreground Service 정지
      await _foregroundService.stopService();
    } catch (e) {
      AppLogger.timer.e('Foreground Service 정지 실패: $e');
    }
  }

  void updateSettings(TimerSettings newSettings) {
    state = state.copyWith(settings: newSettings);
    _saveSettings();

    if (state.status == TimerStatus.stopped &&
        state.mode == TimerMode.pomodoro) {
      state = state.copyWith(currentTime: newSettings.focusTime);
    }
  }

  void _handleTimerComplete() async {
    // 이미 완료 처리 중이면 중복 실행 방지
    if (state.status != TimerStatus.running) {
      AppLogger.timer.w('이미 완료 처리됨 - 중복 호출 방지');
      return;
    }

    // ✅ 정확한 완료 시각 = _targetEndTime (타이머 시작 시 계산한 목표 시각)
    final actualEndTime = _targetEndTime ?? DateTime.now();

    // 타이머 즉시 정지 (중복 호출 방지)
    _stopTimer();
    _targetEndTime = null;

    // 완료 사운드 재생 (내부에서 배경 음악 정지 처리)
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);

    // 전략에 따른 완료 처리
    await _strategy.handleComplete(
      state,
      actualEndTime,
      (newState) {
        state = newState;
      },
      () => _stopTimer(),
      () => musicPlayerService.playCompletionSound(),
      (focusRecord) async {
        final todoNotifier = _ref.read(todoProvider.notifier);
        await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);
      },
    );

    // 상태 저장
    _saveState();

    // 모든 라운드 완료 시 Foreground Service 정지
    if (state.status == TimerStatus.stopped &&
        state.completedRounds == state.settings.totalRounds) {
      try {
        await _foregroundService.stopService();
      } catch (e) {
        AppLogger.timer.e('Foreground Service 정지 실패: $e');
      }
    }
  }

  void _stopTimer() async {
    // 모든 타이머 인스턴스를 확실히 정리
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.timer.i('📱 앱 복원됨 - 백그라운드에서 정상 복귀');

        // 타이머가 실행 중이었다면 백그라운드 플래그 설정 (정상 복귀)
        if (this.state.status == TimerStatus.running) {
          AppLogger.timer.i('   타이머 실행 중 - app_in_background = true 설정');
          _setBackgroundFlag();
          _syncTimerOnResume();
        }
        break;
      case AppLifecycleState.paused:
        AppLogger.timer.i('📱 앱 일시정지(paused) - 백그라운드 플래그 제거');
        // paused 상태에서 플래그 제거 (detached는 타이밍 문제로 신뢰할 수 없음)
        _clearBackgroundFlag();

        if (this.state.status == TimerStatus.running) {
          AppLogger.timer.i('   타이머 실행 중 - 상태 저장');
          _saveState();
        }
        break;
      case AppLifecycleState.inactive:
        // inactive는 일시적 상태 (전화, 알림 등) - 아무 처리 안함
        AppLogger.timer.d('📱 앱 inactive 상태');
        break;
      case AppLifecycleState.detached:
        AppLogger.timer.w('📱 앱 종료(detached) 감지');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _syncTimerOnResume() {
    if (state.status != TimerStatus.running) return;

    final now = DateTime.now();

    AppLogger.timer.i('🔄 시간 동기화 중');
    AppLogger.timer.d('   현재 시간: ${now.hour}:${now.minute}:${now.second}');

    // 뽀모도로는 목표 시간 기준으로 체크
    if (state.mode == TimerMode.pomodoro && _targetEndTime != null) {
      final remainingTime = _targetEndTime!.difference(now);

      AppLogger.timer.d(
        '   목표 시간: ${_targetEndTime!.hour}:${_targetEndTime!.minute}:${_targetEndTime!.second}',
      );
      AppLogger.timer.d(
        '   남은 시간: ${remainingTime.inSeconds}초 (${remainingTime.inMilliseconds}ms)',
      );

      if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
        // 백그라운드에서 타이머가 완료됨
        AppLogger.timer.i('✅ 백그라운드에서 완료됨');
        state = state.copyWith(currentTime: Duration.zero);
        _handleTimerComplete();
      } else {
        // 남은 시간으로 상태 업데이트
        AppLogger.timer.i('⏰ 남은 시간으로 업데이트됨');
        state = state.copyWith(currentTime: remainingTime);

        // 타이머가 멈췄을 수 있으므로 재시작
        if (_timer == null || !_timer!.isActive) {
          AppLogger.timer.w('⚠️ 타이머가 비활성화됨 - 재시작');
          _startTimer();
        }
      }
    } else if (state.mode == TimerMode.stopwatch) {
      // 스톱워치는 타이머만 재시작
      if (_timer == null || !_timer!.isActive) {
        AppLogger.timer.w('⚠️ 스톱워치 타이머가 비활성화됨 - 재시작');
        _startTimer();
      }
    }
  }

  void _setBackgroundFlag() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_in_background', true);
  }

  void _clearBackgroundFlag() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_in_background', false);
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _targetEndTime = null;
    try {
      await _foregroundService.stopService();
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      AppLogger.timer.e('서비스 정리 실패: $e');
    }
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});
