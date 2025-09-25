import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'vo/todo_items_dummy.dart';

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState(
    selectedTodo: null,
    allTodos: dummyTodoItems,
  ));

  void selectTodo(TodoItemVo? todo) {
    state = state.copyWith(selectedTodo: todo);
  }

  void addTodo(TodoItemVo todo) {
    final updatedTodos = [...state.allTodos, todo];
    state = state.copyWith(allTodos: updatedTodos);
  }

  void updateTodo(TodoItemVo updatedTodo) {
    final updatedTodos = state.allTodos
        .map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo)
        .toList();
    state = state.copyWith(allTodos: updatedTodos);
  }

  void deleteTodo(String todoId) {
    final updatedTodos = state.allTodos.where((todo) => todo.id != todoId).toList();
    TodoItemVo? newSelectedTodo = state.selectedTodo;

    if (state.selectedTodo?.id == todoId) {
      newSelectedTodo = null;
    }

    state = state.copyWith(
      allTodos: updatedTodos,
      selectedTodo: newSelectedTodo,
    );
  }

  void addFocusTimeToSelectedTodo(FocusTimeRecord record) {
    if (state.selectedTodo == null) return;

    final updatedTodo = state.selectedTodo!.addFocusTimeRecord(record);
    updateTodo(updatedTodo);

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