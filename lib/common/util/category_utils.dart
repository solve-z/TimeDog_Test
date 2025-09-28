import 'package:flutter/material.dart';

class CategoryUtils {
  // 할일 목록에서 실제 사용 중인 카테고리 추출
  static List<Map<String, dynamic>> extractCategoriesFromTodos(List<dynamic> todos) {
    final Map<String, Map<String, dynamic>> categoryMap = {};

    for (var todo in todos) {
      final categoryName = todo.category ?? '카테고리 없음';
      final categoryColor = todo.color ?? const Color(0xFF6366F1);

      if (!categoryMap.containsKey(categoryName)) {
        categoryMap[categoryName] = {
          'name': categoryName,
          'color': categoryColor,
        };
      }
    }

    // 카테고리가 없으면 기본 카테고리 추가
    if (categoryMap.isEmpty) {
      categoryMap['일반'] = {
        'name': '일반',
        'color': const Color(0xFF6366F1),
      };
    }

    return categoryMap.values.toList();
  }

  // 기본 카테고리 색상 목록
  static List<Color> getDefaultColors() {
    return [
      const Color(0xFF6366F1),
      const Color(0xFFD9B5FF),
      const Color(0xFFB6D6FF),
      const Color(0xFFFFBDD0),
      const Color(0xFFB8E6B8),
      const Color(0xFFFFE4B5),
      const Color(0xFFE1BEE7),
      const Color(0xFFFF6B9D),
    ];
  }

  // 특정 카테고리의 할일 개수 계산
  static int getTodoCountForCategory(List<dynamic> todos, String categoryName) {
    return todos.where((todo) => todo.category == categoryName).length;
  }
}