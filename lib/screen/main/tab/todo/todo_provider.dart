import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_todo_item.dart';
import 'vo/todo_items_dummy.dart';

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState(
    selectedTodo: null,
    allTodos: [],
  )) {
    _loadTodos();
  }

  static const String _todosKey = 'todos_key';
  static const String _selectedTodoKey = 'selected_todo_id';

  // 할일 목록 로드
  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosKey);

      List<TodoItemVo> todos = [];
      if (todosJson != null) {
        final List<dynamic> todosList = json.decode(todosJson);
        todos = todosList.map((json) => TodoItemVo.fromJson(json)).toList();
      } else {
        // 처음 실행시 빈 목록으로 시작
        todos = [];
      }

      // 선택된 할일 복원 및 검증
      final selectedTodoId = prefs.getString(_selectedTodoKey);
      TodoItemVo? selectedTodo;

      if (selectedTodoId != null) {
        try {
          selectedTodo = todos.firstWhere((todo) => todo.id == selectedTodoId);

          // 선택된 할일 검증
          if (!_isValidSelectedTodo(selectedTodo)) {
            print('⚠️ 선택된 할일이 유효하지 않음 - 선택 해제');
            selectedTodo = null;
            await prefs.remove(_selectedTodoKey);
          } else {
            print('✅ 선택된 할일 복원: ${selectedTodo.title}');
          }
        } catch (e) {
          // 할일을 찾지 못한 경우
          print('⚠️ 선택된 할일을 찾을 수 없음 - 선택 해제');
          selectedTodo = null;
          await prefs.remove(_selectedTodoKey);
        }
      }

      state = state.copyWith(
        allTodos: todos,
        selectedTodo: selectedTodo,
      );
    } catch (e) {
      // 로드 실패시 더미 데이터로 초기화
      state = state.copyWith(allTodos: List.from(dummyTodoItems));
      await _saveTodos();
    }
  }

  // 선택된 할일이 유효한지 검증
  bool _isValidSelectedTodo(TodoItemVo todo) {
    // 1. 완료된 할일은 유효하지 않음
    if (todo.isCompleted) {
      return false;
    }

    // 2. 하루가 지난 할일은 유효하지 않음
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(
      todo.scheduledDate.year,
      todo.scheduledDate.month,
      todo.scheduledDate.day,
    );

    // 오늘 날짜가 아니면 유효하지 않음
    return today.isAtSameMomentAs(scheduledDate);
  }

  // 할일 목록 저장
  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(state.allTodos.map((todo) => todo.toJson()).toList());
      await prefs.setString(_todosKey, todosJson);
    } catch (e) {
      print('Failed to save todos: $e');
    }
  }

  Future<void> selectTodo(TodoItemVo? todo) async {
    state = state.copyWith(selectedTodo: todo);

    // 선택된 할일 ID 저장
    final prefs = await SharedPreferences.getInstance();
    if (todo != null) {
      await prefs.setString(_selectedTodoKey, todo.id);
      print('💾 할일 선택 저장: ${todo.title}');
    } else {
      await prefs.remove(_selectedTodoKey);
      print('💾 할일 선택 해제');
    }
  }

  Future<void> addTodo(TodoItemVo todo) async {
    final updatedTodos = [...state.allTodos, todo];
    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();
  }

  Future<void> updateTodo(TodoItemVo updatedTodo) async {
    final updatedTodos = state.allTodos
        .map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo)
        .toList();
    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();
  }

  Future<void> deleteTodo(String todoId) async {
    final updatedTodos = state.allTodos.where((todo) => todo.id != todoId).toList();
    TodoItemVo? newSelectedTodo = state.selectedTodo;

    if (state.selectedTodo?.id == todoId) {
      newSelectedTodo = null;
    }

    state = state.copyWith(
      allTodos: updatedTodos,
      selectedTodo: newSelectedTodo,
    );
    await _saveTodos();
  }

  // 내일로 미루기 (복사 방식)
  Future<void> postponeToTomorrow(String todoId) async {
    final originalTodo = state.allTodos.firstWhere((todo) => todo.id == todoId);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    // 원본에 이동된 날짜 표시
    final updatedOriginal = originalTodo.copyWith(movedToDate: tomorrowDate);

    // 새로운 할일 생성 (집중시간 초기화)
    final newTodo = TodoItemVo(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      title: originalTodo.title,
      description: originalTodo.description,
      category: originalTodo.category,
      color: originalTodo.color,
      accentColor: originalTodo.accentColor,
      scheduledDate: tomorrowDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: false,
      focusTimeRecords: [], // 집중시간 초기화
    );

    // 원본 업데이트 + 새 할일 추가
    final updatedTodos = state.allTodos.map((todo) {
      return todo.id == todoId ? updatedOriginal : todo;
    }).toList();
    updatedTodos.add(newTodo);

    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();

    print('📅 할일을 내일로 미룸: ${originalTodo.title}');
  }

  // 오늘로 이동 (복사 방식)
  Future<void> moveToToday(String todoId) async {
    final originalTodo = state.allTodos.firstWhere((todo) => todo.id == todoId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 원본에 이동된 날짜 표시
    final updatedOriginal = originalTodo.copyWith(movedToDate: today);

    // 새로운 할일 생성 (집중시간 초기화)
    final newTodo = TodoItemVo(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      title: originalTodo.title,
      description: originalTodo.description,
      category: originalTodo.category,
      color: originalTodo.color,
      accentColor: originalTodo.accentColor,
      scheduledDate: today,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: false,
      focusTimeRecords: [], // 집중시간 초기화
    );

    // 원본 업데이트 + 새 할일 추가
    final updatedTodos = state.allTodos.map((todo) {
      return todo.id == todoId ? updatedOriginal : todo;
    }).toList();
    updatedTodos.add(newTodo);

    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();

    print('📅 할일을 오늘로 이동: ${originalTodo.title}');
  }

  // 할일 완료 상태 토글
  Future<void> toggleTodoComplete(String todoId) async {
    final updatedTodos = state.allTodos.map((todo) {
      if (todo.id == todoId) {
        final newIsCompleted = !todo.isCompleted;
        return todo.copyWith(
          isCompleted: newIsCompleted,
          completedAt: newIsCompleted ? DateTime.now() : null,
        );
      }
      return todo;
    }).toList();

    // 완료된 할일이 현재 선택된 할일이면 선택 해제
    TodoItemVo? newSelectedTodo = state.selectedTodo;
    if (state.selectedTodo?.id == todoId) {
      final completedTodo = updatedTodos.firstWhere((todo) => todo.id == todoId);
      if (completedTodo.isCompleted) {
        newSelectedTodo = null;
        print('✅ 할일 완료 - 선택 해제됨');

        // 저장소에서도 제거
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_selectedTodoKey);
      }
    }

    state = state.copyWith(
      allTodos: updatedTodos,
      selectedTodo: newSelectedTodo,
    );
    await _saveTodos();
  }

  Future<void> addFocusTimeToSelectedTodo(FocusTimeRecord record) async {
    if (state.selectedTodo == null) return;

    final updatedTodo = state.selectedTodo!.addFocusTimeRecord(record);
    await updateTodo(updatedTodo);

    state = state.copyWith(selectedTodo: updatedTodo);
  }

  // 할일을 다른 카테고리로 이동
  Future<void> moveTodoToCategory(String todoId, String newCategory, Color newColor, Color newAccentColor) async {
    final updatedTodos = state.allTodos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(
          category: newCategory,
          color: newColor,
          accentColor: newAccentColor,
        );
      }
      return todo;
    }).toList();

    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();
  }
}

class TodoState {
  final TodoItemVo? selectedTodo;
  final List<TodoItemVo> allTodos;

  TodoState({
    required this.selectedTodo,
    required this.allTodos,
  });

  TodoState copyWith({
    TodoItemVo? selectedTodo,
    List<TodoItemVo>? allTodos,
  }) {
    return TodoState(
      selectedTodo: selectedTodo ?? this.selectedTodo,
      allTodos: allTodos ?? this.allTodos,
    );
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});