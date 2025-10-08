import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import 'f_todo_list.dart';
import 'f_time_record.dart';

class TodoCurrentViewFragment extends ConsumerWidget {
  final int viewIndex;
  final DateTime selectedDate;

  const TodoCurrentViewFragment({
    super.key,
    required this.viewIndex,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final filteredTodos = _getFilteredTodosByDate(todoState.allTodos);

    switch (viewIndex) {
      case 0:
        return TodoListFragment(
          filteredTodos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      case 1:
        return TimeRecordFragment(
          todos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      default:
        return TodoListFragment(
          filteredTodos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
    }
  }

  // 선택된 날짜에 따라 할일 필터링
  List<TodoItemVo> _getFilteredTodosByDate(List<TodoItemVo> todos) {
    return todos.where((todo) {
      return todo.scheduledDate.year == selectedDate.year &&
          todo.scheduledDate.month == selectedDate.month &&
          todo.scheduledDate.day == selectedDate.day;
    }).toList();
  }
}
