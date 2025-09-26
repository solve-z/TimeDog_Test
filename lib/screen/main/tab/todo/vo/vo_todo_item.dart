import 'package:flutter/material.dart';

class TodoItemVo {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final Color color;
  final Color accentColor;
  final DateTime scheduledDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isCompleted;
  final List<FocusTimeRecord> focusTimeRecords;

  TodoItemVo({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.color,
    required this.accentColor,
    required this.scheduledDate,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.focusTimeRecords = const [],
  });

  // 총 집중 시간 (분 단위)
  int get totalFocusTimeInMinutes {
    return focusTimeRecords.fold(0, (sum, record) => sum + record.focusDurationInMinutes);
  }

  // 할일 복사 (수정용)
  TodoItemVo copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    Color? color,
    Color? accentColor,
    DateTime? scheduledDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    List<FocusTimeRecord>? focusTimeRecords,
  }) {
    return TodoItemVo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      accentColor: accentColor ?? this.accentColor,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isCompleted: isCompleted ?? this.isCompleted,
      focusTimeRecords: focusTimeRecords ?? this.focusTimeRecords,
    );
  }

  // 집중 시간 기록 추가
  TodoItemVo addFocusTimeRecord(FocusTimeRecord record) {
    return copyWith(
      focusTimeRecords: [...focusTimeRecords, record],
      updatedAt: DateTime.now(),
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color': color.value,
      'accentColor': accentColor.value,
      'scheduledDate': scheduledDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'focusTimeRecords': focusTimeRecords.map((record) => record.toJson()).toList(),
    };
  }

  // JSON 역직렬화
  factory TodoItemVo.fromJson(Map<String, dynamic> json) {
    return TodoItemVo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      color: Color(json['color']),
      accentColor: Color(json['accentColor']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCompleted: json['isCompleted'],
      focusTimeRecords: (json['focusTimeRecords'] as List)
          .map((record) => FocusTimeRecord.fromJson(record))
          .toList(),
    );
  }
}

class FocusTimeRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final FocusType focusType;

  FocusTimeRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.focusType,
  });

  // 집중 시간 (분 단위, 초는 내림)
  int get focusDurationInMinutes {
    final duration = endTime.difference(startTime);
    return duration.inMinutes;
  }

  // 집중 시간을 시:분 형태로 반환
  String get formattedDuration {
    final minutes = focusDurationInMinutes;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    } else {
      return '${mins}분';
    }
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'focusType': focusType.toString(),
    };
  }

  // JSON 역직렬화
  factory FocusTimeRecord.fromJson(Map<String, dynamic> json) {
    return FocusTimeRecord(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      focusType: FocusType.values.firstWhere(
        (type) => type.toString() == json['focusType'],
        orElse: () => FocusType.pomodoro,
      ),
    );
  }
}

enum FocusType {
  pomodoro,
  stopwatch,
}