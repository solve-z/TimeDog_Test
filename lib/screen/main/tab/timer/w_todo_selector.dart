import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../todo/todo_provider.dart';
import '../../../../common/dialog/d_todo_selection.dart';

class TodoSelectorWidget extends ConsumerWidget {
  const TodoSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 700 : double.infinity),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
          child: GestureDetector(
            onTap: () => showTodoSelectionDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    todoState.selectedTodo?.color.withOpacity(0.1) ??
                    const Color(0xFFF9FAFB),
                border: Border.all(
                  color:
                      todoState.selectedTodo?.color.withOpacity(0.3) ??
                      const Color(0xFFE5E7EB),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (todoState.selectedTodo != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: todoState.selectedTodo!.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        todoState.selectedTodo!.title,
                        style: const TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '할일 선택',
                      style: TextStyle(
                        fontFamily: 'OmyuPretty',
                        fontSize: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
