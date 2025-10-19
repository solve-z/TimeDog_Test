import 'dart:async';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'vo/vo_timer.dart';
import '../todo/vo/vo_todo_item.dart';

/// 타이머 동작을 정의하는 추상 전략 클래스
abstract class TimerStrategy {
  /// 초기 시간 설정
  Duration getInitialTime(TimerSettings settings);

  /// 타이머가 시작될 때 초기 상태 생성
  TimerState getInitialState(TimerSettings settings);

  /// stop 시 초기화할 시간
  Duration getResetTime(TimerSettings settings);

  /// 타이머 업데이트 로직
  void updateTimer(
    TimerState currentState,
    DateTime? targetEndTime,
    Function(TimerState) setState,
  );

  /// 타이머 완료 여부 확인
  bool shouldComplete(DateTime now, DateTime? targetEndTime);

  /// 완료 시 처리
  Future<void> handleComplete(
    TimerState currentState,
    DateTime actualEndTime,
    Function(TimerState) setState,
    Function() stopTimer,
    Future<void> Function() playCompletionSound,
    Future<void> Function(FocusTimeRecord) addFocusTime,
  );

  /// 시작 시 목표 종료 시간 계산 (Stopwatch는 null 반환)
  DateTime? calculateTargetEndTime(DateTime now, Duration currentTime);

  /// 일시정지/정지 시 집중시간 기록 여부
  bool shouldRecordFocusTime(TimerState state);
}

/// 뽀모도로 타이머 전략
class PomodoroStrategy extends TimerStrategy {
  @override
  Duration getInitialTime(TimerSettings settings) {
    return settings.focusTime;
  }

  @override
  TimerState getInitialState(TimerSettings settings) {
    return TimerState(
      mode: TimerMode.pomodoro,
      settings: settings,
      currentTime: settings.focusTime,
      status: TimerStatus.stopped,
      currentRound: 1,
      round: PomodoroRound.focus,
    );
  }

  @override
  Duration getResetTime(TimerSettings settings) {
    return settings.focusTime;
  }

  @override
  void updateTimer(
    TimerState currentState,
    DateTime? targetEndTime,
    Function(TimerState) setState,
  ) {
    if (targetEndTime == null) return;

    final now = DateTime.now();
    final remainingTime = targetEndTime.difference(now);

    // 남은 시간이 음수이면 0으로 설정
    if (remainingTime.isNegative) {
      setState(currentState.copyWith(currentTime: Duration.zero));
    } else {
      setState(currentState.copyWith(currentTime: remainingTime));
    }
  }

  @override
  bool shouldComplete(DateTime now, DateTime? targetEndTime) {
    if (targetEndTime == null) return false;
    return now.isAfter(targetEndTime) || now.isAtSameMomentAs(targetEndTime);
  }

  @override
  Future<void> handleComplete(
    TimerState currentState,
    DateTime actualEndTime,
    Function(TimerState) setState,
    Function() stopTimer,
    Future<void> Function() playCompletionSound,
    Future<void> Function(FocusTimeRecord) addFocusTime,
  ) async {
    AppLogger.timer.i('========== 뽀모도로 라운드 완료 처리 시작 ==========');
    AppLogger.timer.i('완료된 라운드: ${currentState.round}');

    // 타이머 즉시 정지
    stopTimer();

    // 완료 사운드 재생
    await playCompletionSound();

    final endTime = DateTime.now();

    if (currentState.round == PomodoroRound.focus) {
      // 집중 시간 완료 → 휴식으로 전환

      // 집중 시간 기록 추가
      if (currentState.startTime != null) {
        final focusRecord = FocusTimeRecord(
          id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
          startTime: currentState.startTime!,
          endTime: actualEndTime,
          focusType: FocusType.pomodoro,
        );
        await addFocusTime(focusRecord);

        AppLogger.timer.i(
          '집중 시간 기록: ${currentState.startTime!.hour}:${currentState.startTime!.minute}:${currentState.startTime!.second} ~ '
          '${actualEndTime.hour}:${actualEndTime.minute}:${actualEndTime.second} '
          '(${focusRecord.focusDurationInMinutes}분)',
        );
      }

      // roundStatusList 업데이트
      final updatedStatusList = List<RoundStatus>.from(
        currentState.roundStatusList.isEmpty
            ? List.generate(
                currentState.settings.totalRounds,
                (_) => RoundStatus.notStarted,
              )
            : currentState.roundStatusList,
      );
      if ((currentState.currentRound - 1) < updatedStatusList.length) {
        updatedStatusList[currentState.currentRound - 1] =
            RoundStatus.focusCompleted;
      }

      final isLongBreak =
          currentState.currentRound == currentState.settings.totalRounds;
      final nextRound =
          isLongBreak ? PomodoroRound.longBreak : PomodoroRound.shortBreak;
      final nextTime =
          nextRound == PomodoroRound.longBreak
              ? currentState.settings.longBreakTime
              : currentState.settings.shortBreakTime;

      AppLogger.timer.i('휴식 전환 - 다음 라운드: $nextRound');

      setState(
        currentState.copyWith(
          status: TimerStatus.paused,
          round: nextRound,
          currentTime: nextTime,
          endTime: endTime,
          targetEndTime: actualEndTime,
          startTime: null,
          completedRounds: currentState.currentRound,
          roundStatusList: updatedStatusList,
        ),
      );
    } else {
      // 휴식 시간 완료
      if (currentState.currentRound < currentState.settings.totalRounds) {
        // 다음 집중 시간으로

        final updatedStatusList = List<RoundStatus>.from(
          currentState.roundStatusList.isEmpty
              ? List.generate(
                  currentState.settings.totalRounds,
                  (_) => RoundStatus.notStarted,
                )
              : currentState.roundStatusList,
        );
        if ((currentState.currentRound - 1) < updatedStatusList.length) {
          updatedStatusList[currentState.currentRound - 1] =
              RoundStatus.breakCompleted;
        }

        setState(
          currentState.copyWith(
            status: TimerStatus.paused,
            currentRound: currentState.currentRound + 1,
            round: PomodoroRound.focus,
            currentTime: currentState.settings.focusTime,
            endTime: endTime,
            startTime: null,
            roundStatusList: updatedStatusList,
          ),
        );
      } else {
        // 모든 라운드 완료

        final updatedStatusList = List<RoundStatus>.from(
          currentState.roundStatusList.isEmpty
              ? List.generate(
                  currentState.settings.totalRounds,
                  (_) => RoundStatus.notStarted,
                )
              : currentState.roundStatusList,
        );
        if ((currentState.currentRound - 1) < updatedStatusList.length) {
          updatedStatusList[currentState.currentRound - 1] =
              RoundStatus.breakCompleted;
        }

        setState(
          TimerState(
            mode: TimerMode.pomodoro,
            status: TimerStatus.stopped,
            settings: currentState.settings,
            currentTime: currentState.settings.focusTime,
            currentRound: 1,
            round: PomodoroRound.focus,
            endTime: endTime,
            completedRounds: currentState.settings.totalRounds,
            roundStatusList: updatedStatusList,
          ),
        );
      }
    }
  }

  @override
  DateTime? calculateTargetEndTime(DateTime now, Duration currentTime) {
    return now.add(currentTime);
  }

  @override
  bool shouldRecordFocusTime(TimerState state) {
    // 뽀모도로는 집중 시간일 때만 기록
    return state.round == PomodoroRound.focus;
  }
}

/// 스톱워치 타이머 전략
class StopwatchStrategy extends TimerStrategy {
  @override
  Duration getInitialTime(TimerSettings settings) {
    return Duration.zero;
  }

  @override
  TimerState getInitialState(TimerSettings settings) {
    return TimerState(
      mode: TimerMode.stopwatch,
      settings: settings,
      currentTime: Duration.zero,
      status: TimerStatus.stopped,
    );
  }

  @override
  Duration getResetTime(TimerSettings settings) {
    return Duration.zero;
  }

  @override
  void updateTimer(
    TimerState currentState,
    DateTime? targetEndTime,
    Function(TimerState) setState,
  ) {
    // 스톱워치는 1초씩 증가
    setState(
      currentState.copyWith(
        currentTime: Duration(seconds: currentState.currentTime.inSeconds + 1),
      ),
    );
  }

  @override
  bool shouldComplete(DateTime now, DateTime? targetEndTime) {
    // 스톱워치는 자동으로 완료되지 않음
    return false;
  }

  @override
  Future<void> handleComplete(
    TimerState currentState,
    DateTime actualEndTime,
    Function(TimerState) setState,
    Function() stopTimer,
    Future<void> Function() playCompletionSound,
    Future<void> Function(FocusTimeRecord) addFocusTime,
  ) async {
    // 스톱워치는 자동 완료 처리가 없음
    AppLogger.timer.w('스톱워치는 자동 완료되지 않습니다.');
  }

  @override
  DateTime? calculateTargetEndTime(DateTime now, Duration currentTime) {
    // 스톱워치는 목표 종료 시간이 없음
    return null;
  }

  @override
  bool shouldRecordFocusTime(TimerState state) {
    // 스톱워치는 항상 기록
    return true;
  }
}

/// 타이머 전략 팩토리
class TimerStrategyFactory {
  static TimerStrategy getStrategy(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return PomodoroStrategy();
      case TimerMode.stopwatch:
        return StopwatchStrategy();
    }
  }
}
