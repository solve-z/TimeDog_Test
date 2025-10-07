import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_category.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState(categories: [])) {
    _loadCategories();
  }

  static const String _categoriesKey = 'categories_key';

  // 기본 카테고리 3개
  List<CategoryVo> get _defaultCategories => [
    CategoryVo(
      name: '업무',
      color: const Color(0xFF6366F1),
      accentColor: const Color(0xFF4F46E5),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryVo(
      name: '공부',
      color: const Color(0xFFD9B5FF),
      accentColor: const Color(0xFF9B59E5),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryVo(
      name: '일상',
      color: const Color(0xFFB6D6FF),
      accentColor: const Color(0xFF4A9EFF),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // 카테고리 목록 로드
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_categoriesKey);

      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        final categories = categoriesList.map((json) => CategoryVo.fromJson(json)).toList();
        state = state.copyWith(categories: categories);
      } else {
        // 처음 실행시 기본 카테고리로 초기화
        state = state.copyWith(categories: _defaultCategories);
        await _saveCategories();
      }
    } catch (e) {
      // 로드 실패시 기본 카테고리로 초기화
      state = state.copyWith(categories: _defaultCategories);
      await _saveCategories();
    }
  }

  // 카테고리 목록 저장
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(state.categories.map((category) => category.toJson()).toList());
      await prefs.setString(_categoriesKey, categoriesJson);
    } catch (e) {
      print('Failed to save categories: $e');
    }
  }

  // 카테고리 추가
  Future<void> addCategory(CategoryVo category) async {
    final updatedCategories = [...state.categories, category];
    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }

  // 카테고리 수정
  Future<void> updateCategory(String oldName, CategoryVo updatedCategory) async {
    final updatedCategories = state.categories
        .map((category) => category.name == oldName ? updatedCategory : category)
        .toList();
    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }

  // 카테고리 삭제
  Future<void> deleteCategory(String categoryName) async {
    final updatedCategories = state.categories.where((category) => category.name != categoryName).toList();
    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }

  // 카테고리 보관
  Future<bool> archiveCategory(String categoryName) async {
    // 보관되지 않은 카테고리가 1개만 남았는지 확인
    final activeCategories = state.categories.where((c) => !c.isArchived).toList();
    if (activeCategories.length <= 1) {
      return false; // 보관 불가
    }

    final updatedCategories = state.categories.map((category) {
      if (category.name == categoryName) {
        return category.copyWith(isArchived: true);
      }
      return category;
    }).toList();

    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
    return true;
  }

  // 카테고리 보관 해제
  Future<void> unarchiveCategory(String categoryName) async {
    final updatedCategories = state.categories.map((category) {
      if (category.name == categoryName) {
        return category.copyWith(isArchived: false);
      }
      return category;
    }).toList();

    state = state.copyWith(categories: updatedCategories);
    await _saveCategories();
  }

  // 활성 카테고리 목록 (보관되지 않은 카테고리)
  List<CategoryVo> getActiveCategories() {
    return state.categories.where((category) => !category.isArchived).toList();
  }

  // 보관된 카테고리 목록
  List<CategoryVo> getArchivedCategories() {
    return state.categories.where((category) => category.isArchived).toList();
  }

  // 카테고리 이름으로 조회
  CategoryVo? getCategoryByName(String name) {
    try {
      return state.categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // 카테고리가 없으면 자동으로 추가
  Future<void> ensureCategoryExists(String name, Color color, Color accentColor) async {
    final existing = getCategoryByName(name);
    if (existing == null) {
      final newCategory = CategoryVo(
        name: name,
        color: color,
        accentColor: accentColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await addCategory(newCategory);
    }
  }
}

class CategoryState {
  final List<CategoryVo> categories;

  CategoryState({required this.categories});

  CategoryState copyWith({List<CategoryVo>? categories}) {
    return CategoryState(
      categories: categories ?? this.categories,
    );
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});
