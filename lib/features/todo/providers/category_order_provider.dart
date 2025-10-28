import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryOrderNotifier extends StateNotifier<List<String>> {
  CategoryOrderNotifier() : super([]) {
    _loadCategoryOrder();
  }

  static const String _categoryOrderKey = 'category_order_key';

  // 카테고리 순서 로드
  Future<void> _loadCategoryOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_categoryOrderKey);

      if (orderJson != null) {
        final List<dynamic> orderList = json.decode(orderJson);
        state = orderList.cast<String>();
      }
    } catch (e) {
      print('Failed to load category order: $e');
    }
  }

  // 카테고리 순서 저장
  Future<void> _saveCategoryOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = json.encode(state);
      await prefs.setString(_categoryOrderKey, orderJson);
    } catch (e) {
      print('Failed to save category order: $e');
    }
  }

  // 카테고리 순서 업데이트
  Future<void> updateCategoryOrder(List<String> newOrder) async {
    state = newOrder;
    await _saveCategoryOrder();
  }

  // 새 카테고리 추가 시 순서에 포함
  Future<void> addCategoryToOrder(String categoryName) async {
    if (!state.contains(categoryName)) {
      state = [...state, categoryName];
      await _saveCategoryOrder();
    }
  }

  // 카테고리 삭제 시 순서에서 제거
  Future<void> removeCategoryFromOrder(String categoryName) async {
    state = state.where((name) => name != categoryName).toList();
    await _saveCategoryOrder();
  }

  // 저장된 순서에 따라 카테고리 목록 정렬
  List<Map<String, dynamic>> sortCategoriesByOrder(List<Map<String, dynamic>> categories) {
    if (state.isEmpty) return categories;

    final Map<String, Map<String, dynamic>> categoryMap = {
      for (var category in categories) category['name'] as String: category
    };

    final List<Map<String, dynamic>> sortedCategories = [];

    // 저장된 순서대로 추가
    for (String categoryName in state) {
      if (categoryMap.containsKey(categoryName)) {
        sortedCategories.add(categoryMap[categoryName]!);
        categoryMap.remove(categoryName);
      }
    }

    // 순서에 없는 새로운 카테고리들을 뒤에 추가
    sortedCategories.addAll(categoryMap.values);

    return sortedCategories;
  }
}

final categoryOrderProvider = StateNotifierProvider<CategoryOrderNotifier, List<String>>((ref) {
  return CategoryOrderNotifier();
});