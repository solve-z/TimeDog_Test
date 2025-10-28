import 'package:flutter/material.dart';
import 'vo_todo_item.dart';

final List<TodoItemVo> dummyTodoItems = [
  // 새벽 6시 (타임라인 시작)
  TodoItemVo(
    id: 'todo_1',
    title: '아침 운동',
    description: '타임라인 시작 시간 테스트',
    category: '일상',
    color: const Color(0xFF6366F1),
    accentColor: const Color(0xFF4F46E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_1',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 3),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 47),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  // 오전 중간
  TodoItemVo(
    id: 'todo_2',
    title: '영어 공부',
    description: '오전 시간대 테스트',
    category: '공부',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFF9B59E5),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_2',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 26),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 38),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  // 점심 시간대
  TodoItemVo(
    id: 'todo_3',
    title: '업무 회의',
    description: '낮 시간대 테스트',
    category: '업무',
    color: const Color(0xFFFF9800),
    accentColor: const Color(0xFFF57C00),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_3',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 15),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 22),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  // 저녁 시간대
  TodoItemVo(
    id: 'todo_4',
    title: '저녁 운동',
    description: '저녁 시간대 테스트',
    category: '일상',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFF4A9EFF),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_4',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 19, 7),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 15),
        focusType: FocusType.stopwatch,
      ),
    ],
  ),

  // 자정 넘어가는 시간대 (같은 날 23시~다음날 1시)
  TodoItemVo(
    id: 'todo_5',
    title: '야간 공부',
    description: '자정 넘어가는 시간대 테스트',
    category: '공부',
    color: const Color(0xFF9C27B0),
    accentColor: const Color(0xFF7B1FA2),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_5',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 45),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 1, 20),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),

  // 새벽 2시~4시 (다음날 새벽, 같은 타임라인)
  TodoItemVo(
    id: 'todo_6',
    title: '새벽 작업',
    description: '새벽 시간대 테스트 (타임라인 끝부분)',
    category: '업무',
    color: const Color(0xFF00BCD4),
    accentColor: const Color(0xFF0097A7),
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isCompleted: false,
    focusTimeRecords: [
      FocusTimeRecord(
        id: 'focus_6',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 2, 10),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 4, 35),
        focusType: FocusType.pomodoro,
      ),
    ],
  ),
];