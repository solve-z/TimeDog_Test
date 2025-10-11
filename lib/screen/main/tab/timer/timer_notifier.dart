import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'vo/vo_timer.dart';
import 'notification_service.dart';
import '../todo/todo_provider.dart';
import '../todo/vo/vo_todo_item.dart';
import 'music_player_service.dart';
import 'music_provider.dart';

class TimerNotifier extends StateNotifier<TimerState>
    with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _timer;
  DateTime? _targetEndTime;
  final NotificationService _notificationService = NotificationService();
  static const String _settingsKey = 'timer_settings';
  static const String _stateKey = 'timer_state';
  bool _backgroundPermissionsInitialized = false;

  TimerNotifier(this._ref) : super(const TimerState()) {
    _initializeState(); // 저장된 타이머 상태 복원
    _initializeNotifications(); // 알림 초기화
    WidgetsBinding.instance.addObserver(this); // 생명주기 감지 등록
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _initializeBackgroundPermissions();
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

        if (isInBackground) {
          // 백그라운드에서 복귀 → 정상 복원 (running 유지)
          final restoredState = _restoreTimerState(savedState, settings);
          state = restoredState;

          if (restoredState.status == TimerStatus.running) {
            _startTimer();
          }
        } else {
          // 앱 재실행 → paused로 변경
          final restoredState = _restoreTimerState(savedState, settings);

          if (restoredState.status == TimerStatus.running) {
            state = restoredState.copyWith(status: TimerStatus.paused);
          } else {
            state = restoredState;
          }
        }

        // 플래그 초기화
        prefs.setBool('app_in_background', false);

      } catch (e) {
        print('상태 복원 실패: $e');
        state = TimerState(settings: settings, currentTime: settings.focusTime);
      }
    } else {
      // 저장된 상태가 없으면 기본 상태
      state = TimerState(settings: settings, currentTime: settings.focusTime);
    }
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
      // 첫 번째 업데이트 실행
      if (state.mode == TimerMode.pomodoro) {
        _updatePomodoroTimer();
      } else {
        _updateStopwatchTimer();
      }
      _updateRunningNotification();

      // 그 후 정확히 1초마다 주기적 업데이트를 위한 새로운 타이머 시작
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.mode == TimerMode.pomodoro) {
          _updatePomodoroTimer();
        } else {
          _updateStopwatchTimer();
        }
        _updateRunningNotification();
      });
    });
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

    // 완료 상태에서 시작하면 새로운 사이클 시작
    if (state.status == TimerStatus.stopped &&
        state.completedRounds == state.settings.totalRounds) {
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
        roundStatusList: List.generate(
          state.settings.totalRounds,
          (_) => RoundStatus.notStarted,
        ),
      );
    } else {
      // 새로운 타이머 시작 또는 일시정지에서 재개
      _targetEndTime = now.add(state.currentTime);

      // 일시정지에서 재개하는 경우 startTime을 현재 시간으로 새로 설정
      state = state.copyWith(
        status: TimerStatus.running,
        startTime: now, // 항상 현재 시간으로 설정
        endTime: _targetEndTime,
      );
    }

    // 상태 저장
    _saveState();

    try {
      // 백그라운드 실행 활성화
      final enabled = await _notificationService.enableBackgroundExecution();
      if (!enabled) {
        print('백그라운드 실행 활성화 실패. 상태 저장으로 대체됩니다.');
      }
    } catch (e) {
      print('백그라운드 실행 활성화 실패: $e');
    }

    AppLogger.timer.i('타이머 시작 - 현재 시간: ${state.currentTime.inSeconds}초');
    AppLogger.timer.d(
      '목표 종료 시간: ${_targetEndTime!.hour}:${_targetEndTime!.minute}:${_targetEndTime!.second}',
    );
    AppLogger.timer.d('라운드: ${state.round}, 상태: ${state.status}');

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

  void pause() async {
    if (state.status != TimerStatus.running) return;

    // 음악 일시정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.pauseMusic();

    final pauseTime = DateTime.now();

    // 일시정지할 때 집중시간 기록 (뽀모도로는 집중 시간만, 스톱워치는 항상)
    if (state.startTime != null) {
      final todoNotifier = _ref.read(todoProvider.notifier);
      final todoState = _ref.read(todoProvider);
      if (todoState.selectedTodo != null) {
        bool shouldRecord = false;
        FocusType focusType = FocusType.pomodoro;

        if (state.mode == TimerMode.stopwatch) {
          shouldRecord = true;
          focusType = FocusType.stopwatch;
        } else {
          // 뽀모도로 모드에서는 집중 시간일 때만 기록
          if (state.round == PomodoroRound.focus) {
            shouldRecord = true;
            focusType = FocusType.pomodoro;
          }
        }

        if (shouldRecord) {
          final focusRecord = FocusTimeRecord(
            id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
            startTime: state.startTime!,
            endTime: pauseTime,
            focusType: focusType,
          );
          await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);
        }
      }
    }

    // 완전히 타이머 정지
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
      // 백그라운드 실행 비활성화 (알림은 일시정지 상태 표시를 위해 유지)
      await _notificationService.disableBackgroundExecution();
      // 일시정지 상태 알림 표시
      _updatePausedNotification();
    } catch (e) {
      print('백그라운드 실행 비활성화 실패: $e');
    }
  }

  void stop() async {
    // 음악 정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.stopMusic();

    final stopTime = DateTime.now();

    // 실행 중일 때 중지하면 집중시간 기록 (휴식 시간 제외)
    if (state.status == TimerStatus.running && state.startTime != null) {
      final todoNotifier = _ref.read(todoProvider.notifier);
      final todoState = _ref.read(todoProvider);
      if (todoState.selectedTodo != null) {
        bool shouldRecord = false;
        FocusType focusType = FocusType.pomodoro;

        if (state.mode == TimerMode.stopwatch) {
          shouldRecord = true;
          focusType = FocusType.stopwatch;
        } else {
          // 뽀모도로 모드에서는 집중 시간일 때만 기록 (휴식 시간은 제외)
          if (state.round == PomodoroRound.focus) {
            shouldRecord = true;
            focusType = FocusType.pomodoro;
          }
        }

        if (shouldRecord) {
          final focusRecord = FocusTimeRecord(
            id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
            startTime: state.startTime!,
            endTime: stopTime,
            focusType: focusType,
          );
          await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);
        }
      }
    }

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
    // 음악 정지
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);
    await musicPlayerService.stopMusic();

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
    // 이미 완료 처리 중이면 중복 실행 방지
    if (state.status != TimerStatus.running) {
      AppLogger.timer.w('이미 완료 처리됨 - 중복 호출 방지');
      return;
    }

    // ✅ 정확한 완료 시각 = _targetEndTime (타이머 시작 시 계산한 목표 시각)
    final actualEndTime = _targetEndTime ?? DateTime.now();
    final endTime = DateTime.now();  // state.endTime용 (UI 디버그 정보)

    AppLogger.timer.i('========== 라운드 완료 처리 시작 ==========');
    AppLogger.timer.i('완료된 라운드: ${state.round}');
    AppLogger.timer.d('목표 완료 시각: ${actualEndTime.hour}:${actualEndTime.minute}:${actualEndTime.second}');
    AppLogger.timer.d('실제 처리 시각: ${endTime.hour}:${endTime.minute}:${endTime.second}');

    // 타이머 즉시 정지 (중복 호출 방지)
    _stopTimer();
    _targetEndTime = null;

    // 완료 사운드 재생 (내부에서 배경 음악 정지 처리)
    final musicPlayerService = _ref.read(musicPlayerServiceProvider);

    AppLogger.timer.d('완료 사운드 재생 요청...');
    await musicPlayerService.playCompletionSound();
    AppLogger.timer.d('완료 사운드 재생 요청 완료');

    if (state.round == PomodoroRound.focus) {
      // 집중 시간 완료 → 휴식으로 전환
      await _notificationService.cancelRunningNotification(); // 실행 중 알림 취소
      await _notificationService.showTimerCompleteNotification(
        title: '집중 시간 완료!',
        message: '휴식 시간으로 전환합니다. 시작 버튼을 눌러주세요.',
      );

      // 집중 시간 기록 추가 (선택된 할일이 있는 경우에만)
      final todoNotifier = _ref.read(todoProvider.notifier);
      final todoState = _ref.read(todoProvider);
      if (todoState.selectedTodo != null && state.startTime != null) {
        final focusRecord = FocusTimeRecord(
          id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
          startTime: state.startTime!,
          endTime: actualEndTime,  // ✅ 정확한 완료 시각 사용
          focusType: FocusType.pomodoro,
        );
        await todoNotifier.addFocusTimeToSelectedTodo(focusRecord);

        AppLogger.timer.i(
          '집중 시간 기록: ${state.startTime!.hour}:${state.startTime!.minute}:${state.startTime!.second} ~ '
          '${actualEndTime.hour}:${actualEndTime.minute}:${actualEndTime.second} '
          '(${focusRecord.focusDurationInMinutes}분)',
        );
      }

      // roundStatusList 업데이트: 현재 라운드를 집중 완료로 표시
      final updatedStatusList = List<RoundStatus>.from(
        state.roundStatusList.isEmpty
            ? List.generate(
              state.settings.totalRounds,
              (_) => RoundStatus.notStarted,
            )
            : state.roundStatusList,
      );
      if ((state.currentRound - 1) < updatedStatusList.length) {
        updatedStatusList[state.currentRound - 1] = RoundStatus.focusCompleted;
      }

      final isLongBreak = state.currentRound == state.settings.totalRounds;
      final nextRound =
          isLongBreak ? PomodoroRound.longBreak : PomodoroRound.shortBreak;

      final nextTime =
          nextRound == PomodoroRound.longBreak
              ? state.settings.longBreakTime
              : state.settings.shortBreakTime;

      AppLogger.timer.i('휴식 전환 - 다음 라운드: $nextRound');
      AppLogger.timer.i('휴식 시간: ${nextTime.inSeconds}초');

      state = state.copyWith(
        status: TimerStatus.paused,
        round: nextRound,
        currentTime: nextTime,
        endTime: endTime,
        targetEndTime: actualEndTime,  // 목표 완료 시각 저장
        startTime: null,
        completedRounds: state.currentRound, // 집중 시간 완료 시 라운드 완료 카운트
        roundStatusList: updatedStatusList,
      );

      AppLogger.timer.i('휴식 전환 완료 - 현재 시간: ${state.currentTime.inSeconds}초');

      // 상태 저장
      _saveState();
    } else {
      // 휴식 시간 완료
      if (state.currentRound < state.settings.totalRounds) {
        // 아직 더 해야할 라운드가 있음 → 다음 집중 시간으로
        await _notificationService.cancelRunningNotification(); // 실행 중 알림 취소
        await _notificationService.showTimerCompleteNotification(
          title: '휴식 시간 완료!',
          message: '다음 집중 시간으로 전환합니다. 시작 버튼을 눌러주세요.',
        );

        // roundStatusList 업데이트: 현재 라운드를 휴식 완료로 표시
        final updatedStatusList = List<RoundStatus>.from(
          state.roundStatusList.isEmpty
              ? List.generate(
                state.settings.totalRounds,
                (_) => RoundStatus.notStarted,
              )
              : state.roundStatusList,
        );
        if ((state.currentRound - 1) < updatedStatusList.length) {
          updatedStatusList[state.currentRound - 1] =
              RoundStatus.breakCompleted;
        }

        state = state.copyWith(
          status: TimerStatus.paused,
          currentRound: state.currentRound + 1,
          round: PomodoroRound.focus,
          currentTime: state.settings.focusTime,
          endTime: endTime,
          startTime: null,
          roundStatusList: updatedStatusList,
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

        // roundStatusList 업데이트: 마지막 라운드를 휴식 완료로 표시
        final updatedStatusList = List<RoundStatus>.from(
          state.roundStatusList.isEmpty
              ? List.generate(
                state.settings.totalRounds,
                (_) => RoundStatus.notStarted,
              )
              : state.roundStatusList,
        );
        if ((state.currentRound - 1) < updatedStatusList.length) {
          updatedStatusList[state.currentRound - 1] =
              RoundStatus.breakCompleted;
        }

        state = TimerState(
          mode: TimerMode.pomodoro,
          status: TimerStatus.stopped,
          settings: state.settings,
          currentTime: state.settings.focusTime,
          currentRound: 1,
          round: PomodoroRound.focus,
          endTime: endTime,
          completedRounds: state.settings.totalRounds, // 모든 라운드 완료 표시
          roundStatusList: updatedStatusList,
        );

        // 상태 저장 (완료 상태로)
        _saveState();
        await _notificationService.disableBackgroundExecution();
        await _notificationService.cancelRunningNotification();
      }
    }
  }

  void _updateRunningNotification() async {
    // 타이머가 실행 중일 때만 진행 상황 알림 표시
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

    // 진행 상황과 모드/라운드 정보를 표시하는 지속적 알림
    await _notificationService.showTimerRunningNotification(
      timeRemaining: state.formattedTime,
      phase: phase,
    );
  }

  void _updatePausedNotification() async {
    // 일시정지 상태에서만 일시정지 알림 표시
    if (state.status != TimerStatus.paused) return;

    String phase;
    if (state.mode == TimerMode.pomodoro) {
      switch (state.round) {
        case PomodoroRound.focus:
          phase =
              '집중 시간 (${state.currentRound}/${state.settings.totalRounds}) - 일시정지';
          break;
        case PomodoroRound.shortBreak:
          phase = '짧은 휴식 - 일시정지';
          break;
        case PomodoroRound.longBreak:
          phase = '긴 휴식 - 일시정지';
          break;
      }
    } else {
      phase = '스톱워치 - 일시정지';
    }

    // 일시정지 상태 표시 알림
    await _notificationService.showTimerPausedNotification(
      timeRemaining: state.formattedTime,
      phase: phase,
    );
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
        print('📱 앱 복원됨 - 시간 동기화 시작');
        _syncTimerOnResume();
        _clearBackgroundFlag();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('📱 앱 백그라운드로 이동');
        if (this.state.status == TimerStatus.running) {
          print('   타이머 실행 중 - 상태 저장');
          _saveState();
          _setBackgroundFlag();
        }
        break;
      case AppLifecycleState.detached:
        _clearBackgroundFlag();
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
    print(
      '   목표 시간: ${_targetEndTime!.hour}:${_targetEndTime!.minute}:${_targetEndTime!.second}',
    );
    print(
      '   남은 시간: ${remainingTime.inSeconds}초 (${remainingTime.inMilliseconds}ms)',
    );

    if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
      // 백그라운드에서 타이머가 완료됨
      print('✅ 백그라운드에서 완료됨');
      state = state.copyWith(currentTime: Duration.zero);
      _handlePomodoroRoundComplete();
    } else {
      // 남은 시간으로 상태 업데이트
      print('⏰ 남은 시간으로 업데이트됨');
      state = state.copyWith(currentTime: remainingTime);

      // 타이머가 멈췄을 수 있으므로 재시작
      if (_timer == null || !_timer!.isActive) {
        print('⚠️ 타이머가 비활성화됨 - 재시작');
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
      await _notificationService.disableBackgroundExecution();
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      print('NotificationService 정리 실패: $e');
    }
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});
