import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import '../../../../common/constant/app_constants.dart';

class TodoListFragment extends ConsumerStatefulWidget {
  final List<TodoItemVo>? filteredTodos; // 필터된 할일 목록 (선택적)

  const TodoListFragment({super.key, this.filteredTodos});

  @override
  ConsumerState<TodoListFragment> createState() => _TodoListFragmentState();
}

class _TodoListFragmentState extends ConsumerState<TodoListFragment> {
  // 카테고리별로 할일들을 그룹화
  Map<String, List<TodoItemVo>> _groupTodosByCategory(List<TodoItemVo> todos) {
    Map<String, List<TodoItemVo>> grouped = {};
    for (var todo in todos) {
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
    int totalMinutes = todos.fold(
      0,
      (sum, todo) => sum + todo.totalFocusTimeInMinutes,
    );
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
      child: InkWell(
        onTap: () {
          _showTodoActionBottomSheet(todo);
        },
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (value) async {
                await ref
                    .read(todoProvider.notifier)
                    .toggleTodoComplete(todo.id);
              },
              activeColor: AppColors.primary,
              side: BorderSide(color: Colors.grey.shade400),
            ),
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 14,
                  decoration:
                      todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Text(
              _formatTotalTime(todo.totalFocusTimeInMinutes),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            PopupMenuButton<String>(
              offset: const Offset(-20, 40),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmDialog(todo);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
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

  void _showEditTodoDialog(TodoItemVo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(
      text: todo.description ?? '',
    );
    final categoryController = TextEditingController(text: todo.category ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('할일 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  final updatedTodo = todo.copyWith(
                    title: titleController.text.trim(),
                    description:
                        descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                    category:
                        categoryController.text.trim().isEmpty
                            ? null
                            : categoryController.text.trim(),
                  );

                  await ref.read(todoProvider.notifier).updateTodo(updatedTodo);

                  Navigator.of(context).pop();
                }
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );
  }

  void _showTodoActionBottomSheet(TodoItemVo todo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 할일 제목
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (todo.description != null && todo.description!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      todo.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                const Divider(),
                const SizedBox(height: 10),

                // 액션 버튼들
                _buildActionItem(
                  icon: Icons.schedule,
                  title: '내일로 미루기',
                  onTap: () {
                    Navigator.of(context).pop();
                    _postponeToTomorrow(todo);
                  },
                ),

                _buildActionItem(
                  icon: Icons.edit,
                  title: '수정',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditTodoDialog(todo);
                  },
                ),

                _buildActionItem(
                  icon: Icons.delete,
                  title: '삭제',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmDialog(todo);
                  },
                ),

                const SizedBox(height: 20),

                // 닫기 버튼
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor ?? Colors.grey[600]),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: textColor ?? Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void _postponeToTomorrow(TodoItemVo todo) async {
    await ref.read(todoProvider.notifier).postponeToTomorrow(todo.id);
  }

  void _showDeleteConfirmDialog(TodoItemVo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('할일 삭제'),
          content: Text('${todo.title}을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await ref.read(todoProvider.notifier).deleteTodo(todo.id);
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final todosToShow = widget.filteredTodos ?? todoState.allTodos;
    final groupedTodos = _groupTodosByCategory(todosToShow);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount:
          groupedTodos.length * 2 +
          groupedTodos.values.fold(0, (sum, todos) => sum + todos.length),
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
