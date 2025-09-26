import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';
import 'category_order_provider.dart';
import '../../../../common/constant/app_constants.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  List<Map<String, dynamic>> _categories = [];

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final categoryOrder = ref.watch(categoryOrderProvider); // watch로 변경해서 실시간 갱신
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    // 실제 할일에서 사용 중인 카테고리 추출
    final extractedCategories = _extractCategoriesFromTodos(todoState.allTodos);

    // 저장된 순서에 따라 카테고리 정렬
    final categories = categoryOrderNotifier.sortCategoriesByOrder(extractedCategories);

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
          '카테고리',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '5 / 5',
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: categories.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }

                // 현재 카테고리 순서를 리스트로 만들기
                final List<String> newOrder = categories.map((category) => category['name'] as String).toList();

                // 순서 변경
                final item = newOrder.removeAt(oldIndex);
                newOrder.insert(newIndex, item);

                // provider에 저장
                await categoryOrderNotifier.updateCategoryOrder(newOrder);
              },
              itemBuilder: (context, index) {
                final category = categories[index];
                final todoCount = _getTodoCountForCategory(todoState.allTodos, category['name'] as String);

                return _buildCategoryItem(
                  key: ValueKey(category['name']),
                  category: category,
                  todoCount: todoCount,
                  index: index,
                );
              },
            ),
          ),

          // 하단 버튼 영역
          Container(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 잠금 버튼
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: 잠금 기능 구현
                      },
                      icon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 추가 버튼
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: 카테고리 추가 기능 구현
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required Key key,
    required Map<String, dynamic> category,
    required int todoCount,
    required int index,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Icon(
              Icons.drag_handle,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            // 카테고리 색상
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: category['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${category['name']} ($todoCount)',
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 할일이 있는 경우 할일 미리보기
            if (todoCount > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildTodoPreview(category['name'] as String),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.grey.shade600,
            size: 20,
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCategoryDialog(category, index);
                break;
              case 'delete':
                _showDeleteCategoryDialog(category, index);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('수정'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16),
                  SizedBox(width: 8),
                  Text('삭제'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoPreview(String categoryName) {
    final todoState = ref.watch(todoProvider);
    final categoryTodos = todoState.allTodos
        .where((todo) => todo.category == categoryName)
        .take(1)
        .toList();

    if (categoryTodos.isEmpty) return const SizedBox.shrink();

    final todo = categoryTodos.first;
    return Text(
      todo.title,
      style: TextStyle(
        fontFamily: 'OmyuPretty',
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  int _getTodoCountForCategory(List<dynamic> todos, String categoryName) {
    return todos.where((todo) => todo.category == categoryName).length;
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, int index) {
    final TextEditingController nameController = TextEditingController(text: category['name'] as String);
    Color selectedColor = category['color'] as Color;
    final String originalName = category['name'] as String;

    final List<Color> colors = [
      const Color(0xFF6366F1),
      const Color(0xFFD9B5FF),
      const Color(0xFFB6D6FF),
      const Color(0xFFFFBDD0),
      const Color(0xFFB8E6B8),
      const Color(0xFFFFE4B5),
      const Color(0xFFE1BEE7),
      const Color(0xFFFF6B9D),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    '카테고리 수정',
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                // 카테고리 이름 입력
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: nameController,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      hintText: '카테고리 이름...',
                      hintStyle: const TextStyle(
                        fontFamily: 'OmyuPretty',
                        color: Color(0xFF9CA3AF),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 색상 선택 영역
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '색상 선택',
                          style: TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: colors.map((color) {
                          final isSelected = color == selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF111827),
                                        width: 2,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 하단 버튼 영역
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              '취소',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (nameController.text.trim().isNotEmpty) {
                              final newName = nameController.text.trim();
                              await _updateCategoryName(originalName, newName, selectedColor);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              '저장',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 카테고리 이름과 색상 업데이트
  Future<void> _updateCategoryName(String originalName, String newName, Color newColor) async {
    final todoState = ref.read(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);

    // 해당 카테고리의 모든 할일 업데이트
    final todosToUpdate = todoState.allTodos
        .where((todo) => todo.category == originalName)
        .toList();

    for (var todo in todosToUpdate) {
      final updatedTodo = todo.copyWith(
        category: newName,
        color: newColor,
        accentColor: newColor.withOpacity(0.8),
      );
      await todoNotifier.updateTodo(updatedTodo);
    }

    // 카테고리 순서에서도 이름 변경
    if (originalName != newName) {
      final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);
      final currentOrder = ref.read(categoryOrderProvider);
      final newOrder = currentOrder.map((name) => name == originalName ? newName : name).toList();
      await categoryOrderNotifier.updateCategoryOrder(newOrder);
    }

    // 수정 완료 메시지
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$originalName 카테고리가 $newName으로 수정되었습니다.',
            style: const TextStyle(fontFamily: 'OmyuPretty'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category, int index) {
    final todoState = ref.read(todoProvider);
    final categoryName = category['name'] as String;
    final todoCount = _getTodoCountForCategory(todoState.allTodos, categoryName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '카테고리 삭제',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '$categoryName 카테고리를 삭제하시겠습니까?\n이 카테고리에 속한 $todoCount개의 할일도 함께 삭제됩니다.',
          style: const TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // 해당 카테고리의 모든 할일 삭제
              final todoNotifier = ref.read(todoProvider.notifier);
              final todosToDelete = todoState.allTodos
                  .where((todo) => todo.category == categoryName)
                  .toList();

              // 모든 할일 삭제
              for (var todo in todosToDelete) {
                await todoNotifier.deleteTodo(todo.id);
              }

              // 카테고리 순서에서도 제거
              final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);
              await categoryOrderNotifier.removeCategoryFromOrder(categoryName);

              Navigator.of(context).pop();

              // 삭제 완료 메시지
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$categoryName 카테고리와 ${todosToDelete.length}개의 할일이 삭제되었습니다.',
                      style: const TextStyle(fontFamily: 'OmyuPretty'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 할일 목록에서 실제 사용 중인 카테고리 추출
  List<Map<String, dynamic>> _extractCategoriesFromTodos(List<dynamic> todos) {
    final Map<String, Map<String, dynamic>> categoryMap = {};

    for (var todo in todos) {
      final categoryName = todo.category ?? '카테고리 없음';
      final categoryColor = todo.color ?? const Color(0xFF6366F1);

      if (!categoryMap.containsKey(categoryName)) {
        categoryMap[categoryName] = {
          'name': categoryName,
          'color': categoryColor,
        };
      }
    }

    // 카테고리가 없으면 기본 카테고리 추가
    if (categoryMap.isEmpty) {
      categoryMap['일반'] = {
        'name': '일반',
        'color': const Color(0xFF6366F1),
      };
    }

    return categoryMap.values.toList();
  }
}