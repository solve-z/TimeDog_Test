import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/constant/app_constants.dart';
import '../../screen/main/tab/todo/todo_provider.dart';
import '../../screen/main/tab/todo/category_order_provider.dart';
import '../../screen/main/tab/todo/vo/vo_todo_item.dart';
import '../util/category_utils.dart';
import 'd_add_todo.dart';

class TodoSelectionDialog extends ConsumerStatefulWidget {
  const TodoSelectionDialog({super.key});

  @override
  ConsumerState<TodoSelectionDialog> createState() =>
      _TodoSelectionDialogState();
}

class _TodoSelectionDialogState extends ConsumerState<TodoSelectionDialog> {
  bool showDateSelection = false;
  String selectedDateFilter = '전체';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final todoState = ref.watch(todoProvider);
          final todoNotifier = ref.read(todoProvider.notifier);

          return Column(
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

              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDateSelection = !showDateSelection;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedDateFilter,
                              style: const TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final newCategory = await showAddTodoDialog(
                          context,
                          selectedCategory: selectedDateFilter,
                        );

                        // 필터가 전체가 아닌 경우, 추가된 할일의 카테고리로 필터 변경
                        if (newCategory != null && selectedDateFilter != '전체') {
                          setState(() {
                            selectedDateFilter = newCategory;
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 내용 영역 (날짜 선택 또는 할일 목록)
              Expanded(
                child:
                    showDateSelection
                        ? _buildDateSelectionContent(selectedDateFilter, (
                          filter,
                        ) {
                          setState(() {
                            selectedDateFilter = filter;
                            showDateSelection = false;
                          });
                        })
                        : _buildFilteredTodoList(
                          todoState,
                          todoNotifier,
                          selectedDateFilter,
                        ),
              ),

              // 닫기 버튼
              Container(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelectionContent(
    String currentFilter,
    Function(String) onFilterSelected,
  ) {
    final todoState = ref.watch(todoProvider);
    final categoryOrder = ref.watch(categoryOrderProvider);
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    final dateOptions = [
      {'title': '전체', 'icon': Icons.list_outlined},
    ];

    // 실제 할일에서 사용 중인 카테고리 추출
    final extractedCategories = CategoryUtils.extractCategoriesFromTodos(
      todoState.allTodos,
    );

    // 저장된 순서에 따라 카테고리 정렬
    final categories = categoryOrderNotifier.sortCategoriesByOrder(
      extractedCategories,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // 날짜 옵션들
          ...dateOptions.map((option) {
            final isSelected = option['title'] == currentFilter;
            return _buildFilterOption(
              option['title'] as String,
              option['icon'] as IconData,
              isSelected,
              () => onFilterSelected(option['title'] as String),
            );
          }),

          // 카테고리 목록 (날짜 옵션 바로 아래 이어서)
          ...categories.map((category) {
            final isSelected = category['name'] == currentFilter;
            return _buildCategoryFilterOption(
              category['name'] as String,
              category['color'] as Color,
              isSelected,
              () => onFilterSelected(category['name'] as String),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF6366F1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterOption(
    String title,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF6366F1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredTodoList(
    TodoState todoState,
    TodoNotifier todoNotifier,
    String filter,
  ) {
    final filteredTodos = _getFilteredTodos(todoState.allTodos, filter);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTodos.length,
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        final isSelected = todoState.selectedTodo?.id == todo.id;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // 카테고리 색상 원형
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
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? todo.color : const Color(0xFF374151),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  todoNotifier.selectTodo(isSelected ? null : todo);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? todo.color : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isSelected ? '선택됨' : '실행',
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<TodoItemVo> _getFilteredTodos(List<TodoItemVo> todos, String filter) {
    final incompleteTodos = todos.where((todo) => !todo.isCompleted).toList();
    final todayTodos =
        incompleteTodos.where((todo) => _isToday(todo.scheduledDate)).toList();

    switch (filter) {
      case '전체':
        return todayTodos;
      default:
        return todayTodos.where((todo) => todo.category == filter).toList();
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

void showTodoSelectionDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const TodoSelectionDialog(),
  );
}
