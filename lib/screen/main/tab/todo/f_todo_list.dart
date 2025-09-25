import 'package:flutter/material.dart';
import 'vo/vo_todo_item.dart';
import '../../../../common/constant/app_constants.dart';

class TodoListFragment extends StatefulWidget {
  final List<TodoItemVo> todos;

  const TodoListFragment({
    super.key,
    required this.todos,
  });

  @override
  State<TodoListFragment> createState() => _TodoListFragmentState();
}

class _TodoListFragmentState extends State<TodoListFragment> {
  // 카테고리별로 할일들을 그룹화
  Map<String, List<TodoItemVo>> _groupTodosByCategory() {
    Map<String, List<TodoItemVo>> grouped = {};
    for (var todo in widget.todos) {
      String category = todo.category ?? '기타';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(todo);
    }
    return grouped;
  }

  Widget _buildCategoryHeader(String categoryName, List<TodoItemVo> todos) {
    // 완료된 할일 개수 계산
    int completedCount = todos.where((todo) => todo.isCompleted).length;
    double progress = todos.isNotEmpty ? completedCount / todos.length : 0.0;

    // 총 집중 시간 계산
    int totalMinutes = todos.fold(0, (sum, todo) => sum + todo.totalFocusTimeInMinutes);
    String totalTime = _formatTotalTime(totalMinutes);

    // 카테고리의 대표 색상 (첫 번째 할일의 색상 사용)
    Color categoryColor = todos.isNotEmpty ? todos.first.color : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          // 진행바 추가
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              totalTime,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItemVo todo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) {
              setState(() {
                todo.isCompleted = value ?? false;
              });
            },
            activeColor: AppColors.primary,
            side: BorderSide(color: Colors.grey.shade400),
          ),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 14,
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Text(
            _formatTotalTime(todo.totalFocusTimeInMinutes),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTodos = _groupTodosByCategory();

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: groupedTodos.length * 2 + groupedTodos.values.fold(0, (sum, todos) => sum + todos.length),
      itemBuilder: (context, index) {
        int currentIndex = 0;

        for (var entry in groupedTodos.entries) {
          // 카테고리 헤더
          if (currentIndex == index) {
            return _buildCategoryHeader(entry.key, entry.value);
          }
          currentIndex++;

          // 해당 카테고리의 할일들
          for (var todo in entry.value) {
            if (currentIndex == index) {
              return _buildTodoItem(todo);
            }
            currentIndex++;
          }

          // 카테고리 구분선 (마지막 카테고리가 아닌 경우)
          if (entry.key != groupedTodos.keys.last) {
            if (currentIndex == index) {
              return Container(
                width: double.infinity,
                height: 2,
                color: Colors.grey.shade300,
              );
            }
            currentIndex++;
          }
        }

        return const SizedBox.shrink();
      },
    );
  }
}