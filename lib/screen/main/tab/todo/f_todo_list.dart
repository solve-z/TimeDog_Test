import 'package:flutter/material.dart';
import 'vo/vo_todo_category.dart';
import 'vo/vo_todo_item.dart';
import '../../../../common/constant/app_constants.dart';

class TodoListFragment extends StatefulWidget {
  final List<TodoCategoryVo> categories;

  const TodoListFragment({
    super.key,
    required this.categories,
  });

  @override
  State<TodoListFragment> createState() => _TodoListFragmentState();
}

class _TodoListFragmentState extends State<TodoListFragment> {
  int _getTotalItemCount() {
    int count = 0;
    for (var category in widget.categories) {
      count += 1; // category header
      count += category.todos.length; // todo items
    }
    return count;
  }

  Widget _buildListItem(int index) {
    int currentIndex = 0;

    for (var category in widget.categories) {
      if (currentIndex == index) {
        return _buildCategoryHeader(category);
      }
      currentIndex++;

      for (var todo in category.todos) {
        if (currentIndex == index) {
          return _buildTodoItem(todo, category.color);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryHeader(TodoCategoryVo category) {
    // 완료된 할일 개수 계산
    int completedCount = category.todos.where((todo) => todo.isCompleted).length;
    double progress = category.todos.isNotEmpty ? completedCount / category.todos.length : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category.name,
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
                  color: category.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.totalTime,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItemVo todo, Color categoryColor) {
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
            todo.time,
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _getTotalItemCount(),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 2,
        color: Colors.grey.shade300,
      ),
      itemBuilder: (context, index) {
        return _buildListItem(index);
      },
    );
  }
}