import 'package:flutter/material.dart';
import 'vo_todo_item.dart';

final List<TodoItemVo> dummyTodoItems = [
  TodoItemVo(
    id: 'todo_1',
    title: '회의 자료 준비',
    description: '월요일 팀 회의 발표 자료 작성',
    category: '업무',
    color: const Color(0xFF6366F1),
    accentColor: const Color(0xFF4F46E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_1',
        startTime: DateTime(2025, 9, 24, 6, 3),
        endTime: DateTime(2025, 9, 24, 6, 47),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_2',
    title: '영어 단어 50개 외우기',
    description: 'TOEIC 기출 문제집의 핵심 단어 암기하기',
    category: '공부',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFF9B59E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_2',
        startTime: DateTime(2025, 9, 24, 7, 12),
        endTime: DateTime(2025, 9, 24, 7, 58),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_3',
    title: '수학의 정석 2단원 풀기',
    description: '미분 문제 10개 완료하기',
    category: '공부',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFF9B59E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    isCompleted: true,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_3',
        startTime: DateTime(2025, 9, 24, 8, 3),
        endTime: DateTime(2025, 9, 24, 9, 34),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_4',
    title: '장보기',
    description: '주말 식재료 구매하기',
    category: '일상',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFF4A9EFF),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    isCompleted: false,
    focusTimeRecords: [],
  ),

  TodoItemVo(
    id: 'todo_5',
    title: '운동 30분',
    description: '체력 증진을 위한 유산소 운동',
    category: '일상',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFF4A9EFF),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    isCompleted: true,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_4',
        startTime: DateTime(2025, 9, 24, 19, 7),
        endTime: DateTime(2025, 9, 24, 19, 37),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),
];