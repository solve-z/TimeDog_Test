import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_timer.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(const TimerState()) {
    _loadSettings();
  }

  Timer? _timer;
  static const String _settingsKey = 'timer_settings';

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
    final newMode = state.mode == TimerMode.pomodoro
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

  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == TimerMode.pomodoro) {
        _updatePomodoroTimer();
      } else {
        _updateStopwatchTimer();
      }
    });
  }

  void pause() {
    if (state.status != TimerStatus.running) return;

    _stopTimer();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void stop() {
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
  }

  void reset() {
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
    } else {
      _handlePomodoroRoundComplete();
    }
  }

  void _updateStopwatchTimer() {
    state = state.copyWith(
      currentTime: Duration(seconds: state.currentTime.inSeconds + 1),
    );
  }

  void _handlePomodoroRoundComplete() {
    if (state.round == PomodoroRound.focus) {
      final isLongBreak = state.currentRound % 4 == 0;
      final nextRound = isLongBreak
          ? PomodoroRound.longBreak
          : PomodoroRound.shortBreak;

      state = state.copyWith(
        round: nextRound,
        currentTime: nextRound == PomodoroRound.longBreak
            ? state.settings.longBreakTime
            : state.settings.shortBreakTime,
      );
    } else {
      if (state.currentRound < state.settings.totalRounds) {
        state = state.copyWith(
          currentRound: state.currentRound + 1,
          round: PomodoroRound.focus,
          currentTime: state.settings.focusTime,
        );
      } else {
        _stopTimer();
        state = state.copyWith(status: TimerStatus.stopped);
      }
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});