enum TimerMode { pomodoro, stopwatch }

enum TimerStatus { stopped, running, paused }

enum PomodoroRound { focus, shortBreak, longBreak }

class TimerSettings {
  final int totalRounds;
  final Duration focusTime;
  final Duration shortBreakTime;
  final Duration longBreakTime;

  const TimerSettings({
    this.totalRounds = 4,
    this.focusTime = const Duration(minutes: 25),
    this.shortBreakTime = const Duration(minutes: 5),
    this.longBreakTime = const Duration(minutes: 15),
  });

  TimerSettings copyWith({
    int? totalRounds,
    Duration? focusTime,
    Duration? shortBreakTime,
    Duration? longBreakTime,
  }) {
    return TimerSettings(
      totalRounds: totalRounds ?? this.totalRounds,
      focusTime: focusTime ?? this.focusTime,
      shortBreakTime: shortBreakTime ?? this.shortBreakTime,
      longBreakTime: longBreakTime ?? this.longBreakTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRounds': totalRounds,
      'focusTimeMinutes': focusTime.inMinutes,
      'shortBreakTimeMinutes': shortBreakTime.inMinutes,
      'longBreakTimeMinutes': longBreakTime.inMinutes,
    };
  }

  factory TimerSettings.fromJson(Map<String, dynamic> json) {
    return TimerSettings(
      totalRounds: json['totalRounds'] ?? 4,
      focusTime: Duration(minutes: json['focusTimeMinutes'] ?? 25),
      shortBreakTime: Duration(minutes: json['shortBreakTimeMinutes'] ?? 5),
      longBreakTime: Duration(minutes: json['longBreakTimeMinutes'] ?? 15),
    );
  }
}

class TimerState {
  final TimerMode mode;
  final TimerStatus status;
  final Duration currentTime;
  final int currentRound;
  final PomodoroRound round;
  final TimerSettings settings;
  final DateTime? startTime;
  final DateTime? endTime;
  final int completedRounds;

  const TimerState({
    this.mode = TimerMode.pomodoro,
    this.status = TimerStatus.stopped,
    this.currentTime = const Duration(minutes: 25),
    this.currentRound = 1,
    this.round = PomodoroRound.focus,
    this.settings = const TimerSettings(),
    this.startTime,
    this.endTime,
    this.completedRounds = 0,
  });

  TimerState copyWith({
    TimerMode? mode,
    TimerStatus? status,
    Duration? currentTime,
    int? currentRound,
    PomodoroRound? round,
    TimerSettings? settings,
    DateTime? startTime,
    DateTime? endTime,
    int? completedRounds,
    bool clearEndTime = false,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      currentTime: currentTime ?? this.currentTime,
      currentRound: currentRound ?? this.currentRound,
      round: round ?? this.round,
      settings: settings ?? this.settings,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      completedRounds: completedRounds ?? this.completedRounds,
    );
  }

  Duration get targetTime {
    switch (round) {
      case PomodoroRound.focus:
        return settings.focusTime;
      case PomodoroRound.shortBreak:
        return settings.shortBreakTime;
      case PomodoroRound.longBreak:
        return settings.longBreakTime;
    }
  }

  bool get isLastRound => currentRound >= settings.totalRounds;

  bool get isRoundCompleted => currentTime.inSeconds <= 0;

  String get formattedTime {
    final minutes = currentTime.inMinutes.toString().padLeft(2, '0');
    final seconds = (currentTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  List<bool> get roundProgress {
    return List.generate(settings.totalRounds, (index) => index < completedRounds);
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'status': status.name,
      'currentTimeSeconds': currentTime.inSeconds,
      'currentRound': currentRound,
      'round': round.name,
      'startTimeMillis': startTime?.millisecondsSinceEpoch,
      'endTimeMillis': endTime?.millisecondsSinceEpoch,
      'completedRounds': completedRounds,
      'settings': settings.toJson(),
    };
  }

  factory TimerState.fromJson(Map<String, dynamic> json) {
    return TimerState(
      mode: TimerMode.values.firstWhere((e) => e.name == json['mode'], orElse: () => TimerMode.pomodoro),
      status: TimerStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => TimerStatus.stopped),
      currentTime: Duration(seconds: json['currentTimeSeconds'] ?? 0),
      currentRound: json['currentRound'] ?? 1,
      round: PomodoroRound.values.firstWhere((e) => e.name == json['round'], orElse: () => PomodoroRound.focus),
      startTime: json['startTimeMillis'] != null ? DateTime.fromMillisecondsSinceEpoch(json['startTimeMillis']) : null,
      endTime: json['endTimeMillis'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endTimeMillis']) : null,
      completedRounds: json['completedRounds'] ?? 0,
      settings: TimerSettings.fromJson(json['settings'] ?? {}),
    );
  }
}