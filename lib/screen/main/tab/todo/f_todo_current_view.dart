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

class _TodoCurrentViewFragmentState extends ConsumerState<TodoCurrentViewFragment>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
      end: Offset.zero, // 제자리로
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.viewIndex == 1) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(TodoCurrentViewFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewIndex == 1 && oldWidget.viewIndex == 0) {
      _animationController.forward();
    } else if (widget.viewIndex == 0 && oldWidget.viewIndex == 1) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            child: ClipRect(
              child: SlideTransition(
                position: _slideAnimation,
                child: TimeRecordFragment(
                  todos: filteredTodos,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  selectedCategory: widget.selectedCategory,
                ),
              ),
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
