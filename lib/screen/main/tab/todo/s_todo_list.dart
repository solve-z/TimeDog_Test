import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import 's_category_management.dart';
import '../../../../common/constant/app_constants.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  bool _showCompletedTodos = false;

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);

    // 미완료 할일을 오늘/나머지로 분리
    final incompleteTodos = todoState.allTodos.where((todo) => !todo.isCompleted).toList();
    final todayTodos = _getTodayTodos(incompleteTodos);
    final otherTodos = _getOtherTodos(incompleteTodos);

    // 완료된 할일을 완료 시점별로 그룹화
    final completedTodos = todoState.allTodos.where((todo) => todo.isCompleted).toList();
    final groupedCompletedTodos = _groupCompletedTodosByDate(completedTodos);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          '전체 할 일 목록',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 할일 섹션
            if (todayTodos.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.grey.shade100,
                child: Text(
                  '오늘 할 일',
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...todayTodos.map((todo) => _buildTodoItem(context, todo, todoNotifier)),
            ],

            // 나머지 할일 섹션
            if (otherTodos.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.grey.shade100,
                child: Text(
                  otherTodos.length > 0 ? '나머지' : '',
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...otherTodos.map((todo) => _buildTodoItem(context, todo, todoNotifier)),
            ],

            // 빈 상태
            if (todayTodos.isEmpty && otherTodos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '등록된 할일이 없습니다',
                      style: TextStyle(
                        fontFamily: 'OmyuPretty',
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

            // 완료된 작업 보기/숨기기 버튼
            if (completedTodos.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCompletedTodos = !_showCompletedTodos;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showCompletedTodos ? '완료된 작업 숨기기' : '완료된 작업 보기',
                          style: TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showCompletedTodos
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 완료된 할일 목록 (그룹화됨) - 애니메이션 추가
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showCompletedTodos && completedTodos.isNotEmpty
                  ? Column(
                      children: groupedCompletedTodos.entries.map((entry) {
                        final dateLabel = entry.key;
                        final todos = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              color: Colors.grey.shade100,
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontFamily: 'OmyuPretty',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ...todos.map((todo) => _buildTodoItem(context, todo, todoNotifier)),
                          ],
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 100), // FAB 공간
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategoryManagementScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, TodoItemVo todo, TodoNotifier todoNotifier) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: todo.color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: todo.isCompleted ? Colors.grey.shade400 : Colors.black87,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.category ?? '카테고리 없음',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${todo.scheduledDate.year}.${todo.scheduledDate.month.toString().padLeft(2, '0')}.${todo.scheduledDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 8),
                if (todo.totalFocusTimeInMinutes > 0) ...[
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatTotalTime(todo.totalFocusTimeInMinutes),
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            todoNotifier.toggleTodoComplete(todo.id);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: todo.isCompleted ? todo.color : Colors.transparent,
              border: Border.all(
                color: todo.color,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: todo.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  List<TodoItemVo> _getTodayTodos(List<TodoItemVo> todos) {
    final now = DateTime.now();
    return todos.where((todo) {
      return todo.scheduledDate.year == now.year &&
          todo.scheduledDate.month == now.month &&
          todo.scheduledDate.day == now.day;
    }).toList();
  }

  List<TodoItemVo> _getOtherTodos(List<TodoItemVo> todos) {
    final now = DateTime.now();
    return todos.where((todo) {
      return !(todo.scheduledDate.year == now.year &&
          todo.scheduledDate.month == now.month &&
          todo.scheduledDate.day == now.day);
    }).toList();
  }

  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}H ${mins}M';
    } else {
      return '${mins}M';
    }
  }

  // 완료된 할일을 완료 시점별로 그룹화
  Map<String, List<TodoItemVo>> _groupCompletedTodosByDate(List<TodoItemVo> completedTodos) {
    final Map<String, List<TodoItemVo>> grouped = {};
    final now = DateTime.now();

    for (var todo in completedTodos) {
      if (todo.completedAt == null) continue;

      final completedDate = todo.completedAt!;
      final dateLabel = _getDateLabel(completedDate, now);

      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(todo);
    }

    // 최신 완료 시점 순으로 정렬
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // 각 그룹의 가장 최신 완료 시점으로 정렬
        final aLatest = a.value.map((todo) => todo.completedAt!).reduce((a, b) => a.isAfter(b) ? a : b);
        final bLatest = b.value.map((todo) => todo.completedAt!).reduce((a, b) => a.isAfter(b) ? a : b);
        return bLatest.compareTo(aLatest);
      });

    // 각 그룹 내에서도 완료 시점 순으로 정렬
    for (var entry in sortedEntries) {
      entry.value.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    }

    return Map.fromEntries(sortedEntries);
  }

  // 날짜 라벨 생성 (어제, 9월 13일(토요일) 등)
  String _getDateLabel(DateTime completedDate, DateTime now) {
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(completedDate.year, completedDate.month, completedDate.day))
        .inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else {
      final weekdays = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      final weekday = weekdays[completedDate.weekday];
      return '${completedDate.month}월 ${completedDate.day}일($weekday)';
    }
  }
}