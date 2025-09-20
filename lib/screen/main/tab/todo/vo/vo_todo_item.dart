class TodoItemVo {
  final String title;
  final String time;
  bool isCompleted;
  final List<FocusTimeRecord> focusTimeRecords;

  TodoItemVo({
    required this.title,
    required this.time,
    required this.isCompleted,
    this.focusTimeRecords = const [],
  });
}

class FocusTimeRecord {
  final DateTime startTime;
  final DateTime endTime;

  FocusTimeRecord({
    required this.startTime,
    required this.endTime,
  });

  // 집중 시간 (분 단위, 초는 버림)
  int get focusDurationInMinutes {
    final duration = endTime.difference(startTime);
    return duration.inMinutes;
  }
}