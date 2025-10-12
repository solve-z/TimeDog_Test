import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import '../../../../common/constant/app_constants.dart';
import '../../../../common/dialog/d_add_todo.dart';

class TodoListFragment extends ConsumerStatefulWidget {
  final List<TodoItemVo>? filteredTodos; // 필터된 할일 목록 (선택적)
  final ScrollPhysics? physics; // 스크롤 물리학 설정
  final bool shrinkWrap; // 내용 크기에 맞게 조정
  final bool isCompactMode; // 분할 뷰를 위한 컴팩트 모드
  final Function(String?)? onCategorySelected; // 카테고리 선택 콜백
  final String? selectedCategory; // 현재 선택된 카테고리

  const TodoListFragment({
    super.key,
    this.filteredTodos,
    this.physics,
    this.shrinkWrap = false,
    this.isCompactMode = false,
    this.onCategorySelected,
    this.selectedCategory,
  });

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

    // 선택된 카테고리인지 확인
    bool isSelected = widget.selectedCategory == categoryName;
    // 분할 뷰(컴팩트 모드)일 때만 클릭 가능
    bool isClickable =
        widget.isCompactMode && widget.onCategorySelected != null;

    return GestureDetector(
      onTap:
          isClickable
              ? () => widget.onCategorySelected!(categoryName)
              : () => _showAddTodoForCategory(categoryName),
      child: Container(
        margin: const EdgeInsets.all(2), // 테두리 공간 미리 확보
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected && isClickable
                  ? categoryColor.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected && isClickable ? categoryColor : Colors.transparent,
            width: 2,
          ),
        ),
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected && isClickable
                          ? FontWeight.w700
                          : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // 진행바 (일반 모드에서만 표시)
            if (!widget.isCompactMode) ...[
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
              const SizedBox(width: 8),
            ],
            // 시간 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isSelected && isClickable
                        ? categoryColor.withOpacity(0.5)
                        : categoryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                totalTime,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected && isClickable
                          ? FontWeight.w700
                          : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem(TodoItemVo todo) {
    return InkWell(
      onTap:
          todo.isMoved
              ? null
              : () async {
                await ref
                    .read(todoProvider.notifier)
                    .toggleTodoComplete(todo.id);
              },
      onLongPress:
          todo.isMoved
              ? null
              : () {
                _showTodoContextMenu(context, todo);
              },
      splashColor: Colors.transparent,
      highlightColor: todo.isMoved ? Colors.transparent : Colors.grey.shade100,
      child: Container(
        height: 36,
        padding: const EdgeInsets.fromLTRB(12, 2, 0, 2),
        child: Opacity(
          opacity: todo.isMoved ? 0.5 : 1.0,
          child: Row(
            children: [
              // 이동된 할일은 화살표 아이콘, 아니면 체크박스
              if (todo.isMoved)
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(todoProvider.notifier)
                        .toggleTodoComplete(todo.id);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) async {
                          await ref
                              .read(todoProvider.notifier)
                              .toggleTodoComplete(todo.id);
                        },
                        checkColor: AppColors.primary,
                        fillColor: MaterialStateProperty.all(Colors.white),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 13,
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor:
                          todo.isCompleted ? Colors.grey.shade600 : null,
                      color:
                          todo.isMoved
                              ? Colors.grey.shade500
                              : (todo.isCompleted ? Colors.grey : Colors.black),
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              // 시간 표시 (일반 모드에서만 표시)
              if (!widget.isCompactMode) ...[
                const SizedBox(width: 8),
                if (todo.isMoved) ...[
                  Text(
                    '${todo.scheduledDate.month}/${todo.scheduledDate.day}로 이동',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '•',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _formatTotalTime(todo.totalFocusTimeInMinutes),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              if (!widget.isCompactMode)
                PopupMenuButton<String>(
                  offset: const Offset(-20, 40),
                  padding: EdgeInsets.zero,
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
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
            ],
          ),
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
                  final navigator = Navigator.of(context);
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

                  navigator.pop();
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

  // 바텀시트 액션 메뉴 표시
  void _showTodoContextMenu(BuildContext context, TodoItemVo todo) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todoDate = DateTime(
      todo.scheduledDate.year,
      todo.scheduledDate.month,
      todo.scheduledDate.day,
    );

    // 과거 할일인지 확인
    final isPast = todoDate.isBefore(today);
    // 오늘 할일인지 확인
    final isToday = todoDate.isAtSameMomentAs(today);
    // 이미 이동된 할일인지 확인
    final isAlreadyMoved = todo.movedToDate != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 할일 제목
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: todo.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          todo.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 오늘로 이동 (과거 할일만, 이동되지 않은 경우만)
                if (isPast && !isAlreadyMoved)
                  ListTile(
                    leading: const Icon(Icons.today, color: Color(0xFF6366F1)),
                    title: const Text('오늘로 이동'),
                    onTap: () {
                      Navigator.pop(context);
                      _moveToToday(todo);
                    },
                  ),

                // 내일로 미루기 (오늘 할일만, 이동되지 않은 경우만)
                if (isToday && !isAlreadyMoved)
                  ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      color: Color(0xFF10B981),
                    ),
                    title: const Text('내일로 미루기'),
                    onTap: () {
                      Navigator.pop(context);
                      _postponeToTomorrow(todo);
                    },
                  ),

                // 수정
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF6B7280)),
                  title: const Text('수정'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditTodoDialog(todo);
                  },
                ),

                // 삭제
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('삭제', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(todo);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _moveToToday(TodoItemVo todo) async {
    await ref.read(todoProvider.notifier).moveToToday(todo.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${todo.title}을(를) 오늘로 이동했습니다'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _postponeToTomorrow(TodoItemVo todo) async {
    await ref.read(todoProvider.notifier).postponeToTomorrow(todo.id);
  }

  void _showAddTodoForCategory(String categoryName) {
    final todoState = ref.read(todoProvider);
    final categoryTodos = todoState.allTodos
        .where((todo) => (todo.category ?? '기타') == categoryName)
        .toList();

    final selectedDate =
        categoryTodos.isNotEmpty ? categoryTodos.first.scheduledDate : DateTime.now();

    showAddTodoDialog(
      context,
      selectedDate: selectedDate,
      selectedCategory: categoryName,
    );
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
                final navigator = Navigator.of(context);
                await ref.read(todoProvider.notifier).deleteTodo(todo.id);
                navigator.pop();
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
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
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
                margin: EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 1,
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
