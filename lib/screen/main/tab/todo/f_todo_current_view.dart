import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import 'f_todo_list.dart';
import 'f_time_record.dart';

class TodoCurrentViewFragment extends ConsumerStatefulWidget {
  final int viewIndex;
  final DateTime selectedDate;
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;

  const TodoCurrentViewFragment({
    super.key,
    required this.viewIndex,
    required this.selectedDate,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  ConsumerState<TodoCurrentViewFragment> createState() => _TodoCurrentViewFragmentState();
}

class _TodoCurrentViewFragmentState extends ConsumerState<TodoCurrentViewFragment> {
  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final filteredTodos = _getFilteredTodosByDate(todoState.allTodos);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 할일 리스트 (항상 표시, 고정)
        Expanded(
          child: TodoListFragment(
            filteredTodos: filteredTodos,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            isCompactMode: widget.viewIndex == 1,
            onCategorySelected: widget.viewIndex == 1 ? widget.onCategorySelected : null,
            selectedCategory: widget.viewIndex == 1 ? widget.selectedCategory : null,
          ),
        ),
        // 타임 레코드 (viewIndex == 1일 때만 표시)
        if (widget.viewIndex == 1) ...[
          const SizedBox(width: 8),
          Expanded(
            child: TimeRecordFragment(
              todos: filteredTodos,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              selectedCategory: widget.selectedCategory,
            ),
          ),
        ],
      ],
    );
  }

  // 선택된 날짜에 따라 할일 필터링
  List<TodoItemVo> _getFilteredTodosByDate(List<TodoItemVo> todos) {
    return todos.where((todo) {
      return todo.scheduledDate.year == widget.selectedDate.year &&
          todo.scheduledDate.month == widget.selectedDate.month &&
          todo.scheduledDate.day == widget.selectedDate.day;
    }).toList();
  }
}
