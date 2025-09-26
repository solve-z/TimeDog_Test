import 'dart:convert';
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

  // 할일 목록 로드
  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosKey);

      if (todosJson != null) {
        final List<dynamic> todosList = json.decode(todosJson);
        final todos = todosList.map((json) => TodoItemVo.fromJson(json)).toList();
        state = state.copyWith(allTodos: todos);
      } else {
        // 처음 실행시 더미 데이터로 초기화
        state = state.copyWith(allTodos: List.from(dummyTodoItems));
        await _saveTodos();
      }
    } catch (e) {
      // 로드 실패시 더미 데이터로 초기화
      state = state.copyWith(allTodos: List.from(dummyTodoItems));
      await _saveTodos();
    }
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

  void selectTodo(TodoItemVo? todo) {
    state = state.copyWith(selectedTodo: todo);
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

  // 내일로 미루기
  Future<void> postponeToTomorrow(String todoId) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final updatedTodos = state.allTodos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(
          scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );
      }
      return todo;
    }).toList();

    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();
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

    state = state.copyWith(allTodos: updatedTodos);
    await _saveTodos();
  }

  Future<void> addFocusTimeToSelectedTodo(FocusTimeRecord record) async {
    if (state.selectedTodo == null) return;

    final updatedTodo = state.selectedTodo!.addFocusTimeRecord(record);
    await updateTodo(updatedTodo);

    state = state.copyWith(selectedTodo: updatedTodo);
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