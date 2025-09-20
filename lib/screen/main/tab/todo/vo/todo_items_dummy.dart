import 'package:flutter/material.dart';
import 'vo_todo_category.dart';
import 'vo_todo_item.dart';

final List<TodoCategoryVo> todoItems = [
  TodoCategoryVo(
    name: '영어',
    color: const Color(0xFFD9B5FF),
    accentColor: const Color(0xFFD9B5FF),
    backgroundColor: const Color(0xFFF4EAFF),
    totalTime: '2h 30m',
    todos: [
      TodoItemVo(
        title: '영어 단어 50개 외우기',
        time: '1h 30m',
        isCompleted: false,
        focusTimeRecords: [
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 6, 3), // 6:03-6:47
            endTime: DateTime(2025, 9, 19, 6, 47),
          ),
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 7, 12), // 7:12-7:58
            endTime: DateTime(2025, 9, 19, 7, 58),
          ),
        ],
      ),
      TodoItemVo(
        title: '리스닝 5강 듣기',
        time: '1h 00m',
        isCompleted: false,
        focusTimeRecords: [
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 12, 5), // 12:05-13:12
            endTime: DateTime(2025, 9, 19, 13, 12),
          ),
        ],
      ),
    ],
  ),
  TodoCategoryVo(
    name: '수학',
    color: const Color(0xFFB6D6FF),
    accentColor: const Color(0xFFB6D6FF),
    backgroundColor: const Color(0xFFE7F2FF),
    totalTime: '3h 20m',
    todos: [
      TodoItemVo(
        title: '수학의 정석 2단원 풀기',
        time: '2h 00m',
        isCompleted: true,
        focusTimeRecords: [
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 8, 3), // 8:03-9:34
            endTime: DateTime(2025, 9, 19, 9, 34),
          ),
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 15, 8), // 15:08-15:37
            endTime: DateTime(2025, 9, 19, 15, 37),
          ),
        ],
      ),
      TodoItemVo(
        title: '오답노트 복습하기',
        time: '1h 20m',
        isCompleted: true,
        focusTimeRecords: [
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 16, 15), // 16:15-17:27
            endTime: DateTime(2025, 9, 19, 17, 27),
          ),
        ],
      ),
    ],
  ),
  TodoCategoryVo(
    name: '운동',
    color: const Color(0xFFFFBDD0),
    accentColor: const Color(0xFFFFBDD0),
    backgroundColor: const Color(0xFFFFE7EE),
    totalTime: '1h 00m',
    todos: [
      TodoItemVo(
        title: '러닝 30분 뛰기',
        time: '1h 00m',
        isCompleted: true,
        focusTimeRecords: [
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 19, 19, 7), // 19:07-20:23
            endTime: DateTime(2025, 9, 19, 20, 23),
          ),
          FocusTimeRecord(
            startTime: DateTime(2025, 9, 20, 3, 0), // 새벽 3:00-4:00 (다음날이지만 이전날로 기록)
            endTime: DateTime(2025, 9, 20, 4, 0),
          ),
        ],
      ),
    ],
  ),
];