import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timedog_test/features/todo/models/vo_todo_item.dart';

class StatisticsDataService {
  // 특정 연도의 날짜별 집중 시간 데이터 조회
  Future<Map<DateTime, int>> getYearData(int year) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('todos_key') ?? '[]';
    final List<TodoItemVo> allTodos =
        (json.decode(todosJson) as List)
            .map((item) => TodoItemVo.fromJson(item))
            .toList();

    Map<DateTime, int> result = {};

    for (var todo in allTodos) {
      for (var record in todo.focusTimeRecords) {
        final date = DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );

        if (date.year == year) {
          result[date] = (result[date] ?? 0) + record.focusDurationInMinutes;
        }
      }
    }

    return result;
  }
}

// Provider 정의
final statisticsDataServiceProvider = Provider<StatisticsDataService>((ref) {
  return StatisticsDataService();
});
