import 'package:flutter/material.dart';
import 'vo_todo_item.dart';

final List<TodoItemVo> dummyTodoItems = [
  TodoItemVo(
    id: 'todo_1',
    title: '영어 단어 50개 외우기',
    description: 'TOEIC 기출 문제집의 핵심 단어 암기하기',
    category: '영어',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFF9B59E5),
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
      FocusTimeRecord(
        id: 'focus_2',
        startTime: DateTime(2025, 9, 24, 7, 12),
        endTime: DateTime(2025, 9, 24, 7, 58),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_2',
    title: '리스닝 5강 듣기',
    description: 'CNN 뉴스 리스닝 연습',
    category: '영어',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFF9B59E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_3',
        startTime: DateTime(2025, 9, 24, 12, 5),
        endTime: DateTime(2025, 9, 24, 13, 12),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_3',
    title: '수학의 정석 2단원 풀기',
    description: '미분 문제 10개 완료하기',
    category: '수학',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFF4A9EFF),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    isCompleted: true,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_4',
        startTime: DateTime(2025, 9, 24, 8, 3),
        endTime: DateTime(2025, 9, 24, 9, 34),
        focusType: FocusType.pomodoro,
      ),
      FocusTimeRecord(
        id: 'focus_5',
        startTime: DateTime(2025, 9, 24, 15, 8),
        endTime: DateTime(2025, 9, 24, 15, 37),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_4',
    title: '오답노트 복습하기',
    description: '지난주 모의고사 틀린 문제들 정리',
    category: '수학',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFF4A9EFF),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    isCompleted: true,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_6',
        startTime: DateTime(2025, 9, 24, 16, 15),
        endTime: DateTime(2025, 9, 24, 17, 27),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_5',
    title: '러닝 30분 뛰기',
    description: '체력 증진을 위한 유산소 운동',
    category: '운동',
    color: const Color(0xFFFFBDD0),
    accentColor: const Color(0xFFFF6B9D),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    isCompleted: true,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_7',
        startTime: DateTime(2025, 9, 24, 19, 7),
        endTime: DateTime(2025, 9, 24, 19, 37),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),

  TodoItemVo(
    id: 'todo_6',
    title: '독서 - 자기계발서 읽기',
    description: '아토믹 해빗 3장까지 읽기',
    category: '독서',
    color: const Color(0xFFB8E6B8),
    accentColor: const Color(0xFF4CAF50),
    scheduledDate: DateTime.now().add(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    isCompleted: false,
    focusTimeRecords: [],
  ),

  TodoItemVo(
    id: 'todo_7',
    title: '과제 제출하기',
    description: '물리학 레포트 작성 완료',
    category: '과제',
    color: const Color(0xFFFFE4B5),
    accentColor: const Color(0xFFFFA726),
    scheduledDate: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    isCompleted: false,
    focusTimeRecords: [],
  ),

  TodoItemVo(
    id: 'todo_8',
    title: '기타 연습하기',
    description: '새로운 곡 코드 연습',
    category: '취미',
    color: const Color(0xFFE1BEE7),
    accentColor: const Color(0xFF9C27B0),
    scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_8',
        startTime: DateTime(2025, 9, 23, 20, 0),
        endTime: DateTime(2025, 9, 23, 20, 45),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),
];