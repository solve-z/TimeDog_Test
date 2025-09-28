import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/constant/app_constants.dart';
import '../../screen/main/tab/todo/todo_provider.dart';
import '../../screen/main/tab/todo/vo/vo_todo_item.dart';
import '../../screen/main/tab/todo/category_order_provider.dart';
import 'd_category_selection.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  final DateTime? selectedDate;

  const AddTodoDialog({
    super.key,
    this.selectedDate,
  });

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  late TextEditingController titleController;
  String selectedCategory = '일반';
  Color selectedColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '할일 추가',
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            // 텍스트 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: '할일 추가...',
                  hintStyle: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // 카테고리와 완료 버튼
            Row(
              children: [
                // 카테고리 선택
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCategorySelection(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedCategory,
                            style: const TextStyle(
                              fontFamily: 'OmyuPretty',
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 완료 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (titleController.text.trim().isNotEmpty) {
                        _addNewTodo();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        '완료',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SafeArea(child: const SizedBox(height: 10)),
          ],
        ),
      ),
    );
  }

  void _showCategorySelection() async {
    final result = await showDialog<Map<String, Color>>(
      context: context,
      builder: (context) => CategorySelectionDialog(currentCategory: selectedCategory),
    );

    if (result != null) {
      setState(() {
        selectedCategory = result.keys.first;
        selectedColor = result.values.first;
      });
    }
  }

  void _addNewTodo() {
    final todoNotifier = ref.read(todoProvider.notifier);
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    final newTodo = TodoItemVo(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim(),
      description: null,
      category: selectedCategory,
      color: selectedColor,
      accentColor: selectedColor.withOpacity(0.8),
      scheduledDate: widget.selectedDate ?? DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: false,
      focusTimeRecords: [],
    );

    todoNotifier.addTodo(newTodo);

    // 카테고리 순서에 추가 (새로운 카테고리인 경우)
    categoryOrderNotifier.addCategoryToOrder(selectedCategory);
  }
}

void showAddTodoDialog(BuildContext context, {DateTime? selectedDate}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddTodoDialog(selectedDate: selectedDate),
  );
}