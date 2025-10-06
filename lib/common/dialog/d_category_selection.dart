import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screen/main/tab/todo/todo_provider.dart';
import '../../screen/main/tab/todo/category_order_provider.dart';
import '../util/category_utils.dart';

class CategorySelectionDialog extends ConsumerStatefulWidget {
  final String? currentCategory;

  const CategorySelectionDialog({super.key, this.currentCategory});

  @override
  ConsumerState<CategorySelectionDialog> createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState
    extends ConsumerState<CategorySelectionDialog> {
  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final categoryOrder = ref.watch(categoryOrderProvider);
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    // 실제 할일에서 사용 중인 카테고리 추출
    final extractedCategories = CategoryUtils.extractCategoriesFromTodos(
      todoState.allTodos,
    );

    // 저장된 순서에 따라 카테고리 정렬
    final categories = categoryOrderNotifier.sortCategoriesByOrder(
      extractedCategories,
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 350),
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
                '카테고리를 선택하세요',
                style: TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            // 카테고리 목록 (스크롤 가능)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...categories.map((category) {
                      final isSelected =
                          widget.currentCategory == category['name'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop({
                            category['name'] as String:
                                category['color'] as Color,
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: category['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category['name'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'OmyuPretty',
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // 새 카테고리 추가 버튼
                    GestureDetector(
                      onTap: () async {
                        final result = await _showNewCategoryDialog();
                        if (result != null) {
                          // 새 카테고리를 순서에 추가
                          await ref
                              .read(categoryOrderProvider.notifier)
                              .addCategoryToOrder(result['name'] as String);

                          Navigator.of(context).pop({
                            result['name'] as String: result['color'] as Color,
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF6B7280),
                              size: 16,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '새 카테고리 추가',
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 닫기 버튼 영역
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    '닫기',
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
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showNewCategoryDialog() async {
    final TextEditingController categoryController = TextEditingController();
    Color selectedColor = const Color(0xFF6366F1);
    final colors = CategoryUtils.getDefaultColors();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  insetPadding: const EdgeInsets.all(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.8,
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
                            '새 카테고리',
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
                            controller: categoryController,
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
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 색상 선택 영역
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // 색상 선택 헤더
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

                              // 색상 선택 버튼들
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children:
                                    colors.map((color) {
                                      final isSelected = color == selectedColor;
                                      return GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => selectedColor = color,
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border:
                                                isSelected
                                                    ? Border.all(
                                                      color: const Color(
                                                        0xFF111827,
                                                      ),
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

                        const SizedBox(height: 10),

                        // 하단 버튼 영역
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // 취소
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
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

                              // 완료
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (categoryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      Navigator.of(context).pop({
                                        'name': categoryController.text.trim(),
                                        'color': selectedColor,
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
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
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
