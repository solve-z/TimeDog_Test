import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';
import 'category_order_provider.dart';
import 'category_provider.dart';
import '../../../../common/constant/app_constants.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _categories = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 화면 로드 후 카테고리 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCategories();
    });
  }

  // 할일에서 카테고리 추출하여 CategoryProvider에 동기화
  Future<void> _syncCategories() async {
    final todoState = ref.read(todoProvider);
    final categoryNotifier = ref.read(categoryProvider.notifier);

    // 할일에서 사용 중인 카테고리 추출
    final usedCategories = <String, Map<String, dynamic>>{};
    for (var todo in todoState.allTodos) {
      if (todo.category != null && !usedCategories.containsKey(todo.category)) {
        usedCategories[todo.category!] = {
          'name': todo.category!,
          'color': todo.color,
          'accentColor': todo.accentColor,
        };
      }
    }

    // 각 카테고리를 CategoryProvider에 등록
    for (var category in usedCategories.values) {
      await categoryNotifier.ensureCategoryExists(
        category['name'] as String,
        category['color'] as Color,
        category['accentColor'] as Color,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final categoryState = ref.watch(categoryProvider);
    final categoryOrder = ref.watch(categoryOrderProvider);
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    // 실제 할일에서 사용 중인 카테고리 추출
    final extractedCategories = _extractCategoriesFromTodos(todoState.allTodos);

    // 저장된 순서에 따라 카테고리 정렬
    final allCategories = categoryOrderNotifier.sortCategoriesByOrder(
      extractedCategories,
    );

    // 카테고리 Provider에서 보관 상태 확인하여 분리
    final activeCategories =
        allCategories.where((cat) {
          try {
            final categoryVo = categoryState.categories.firstWhere(
              (c) => c.name == cat['name'],
            );
            return !categoryVo.isArchived;
          } catch (e) {
            // 카테고리가 없으면 활성으로 간주
            return true;
          }
        }).toList();

    final archivedCategories =
        allCategories.where((cat) {
          try {
            final categoryVo = categoryState.categories.firstWhere(
              (c) => c.name == cat['name'],
            );
            return categoryVo.isArchived;
          } catch (e) {
            // 카테고리가 없으면 보관되지 않음
            return false;
          }
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: '활성 (${activeCategories.length})'),
            Tab(text: '보관 (${archivedCategories.length})'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // 활성 카테고리 탭
          _buildCategoryList(activeCategories, todoState.allTodos, false),
          // 보관된 카테고리 탭
          _buildCategoryList(archivedCategories, todoState.allTodos, true),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    List<Map<String, dynamic>> categories,
    List<dynamic> allTodos,
    bool isArchived,
  ) {
    final categoryOrderNotifier = ref.read(categoryOrderProvider.notifier);

    return Column(
      children: [
        // 보관 탭 안내 메시지
        if (isArchived)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '메뉴에서 보관 해제 또는 삭제할 수 있습니다',
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child:
              isArchived
                  // 보관된 카테고리는 순서 변경 불가능한 일반 리스트
                  ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final todoCount = _getTodoCountForCategory(
                        allTodos,
                        category['name'] as String,
                      );

                      return _buildCategoryItem(
                        key: ValueKey(category['name']),
                        category: category,
                        todoCount: todoCount,
                        index: index,
                        isArchived: true,
                      );
                    },
                  )
                  // 활성 카테고리는 순서 변경 가능한 ReorderableListView
                  : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: categories.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }

                      // 현재 카테고리 순서를 리스트로 만들기
                      final List<String> newOrder =
                          categories
                              .map((category) => category['name'] as String)
                              .toList();

                      // 순서 변경
                      final item = newOrder.removeAt(oldIndex);
                      newOrder.insert(newIndex, item);

                      // provider에 저장
                      await categoryOrderNotifier.updateCategoryOrder(newOrder);
                    },
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final todoCount = _getTodoCountForCategory(
                        allTodos,
                        category['name'] as String,
                      );

                      return _buildCategoryItem(
                        key: ValueKey(category['name']),
                        category: category,
                        todoCount: todoCount,
                        index: index,
                        isArchived: false,
                      );
                    },
                  ),
        ),

        // 하단 버튼 영역 (활성 탭에서만 표시)
        if (!isArchived)
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
    );
  }

  Widget _buildCategoryItem({
    required Key key,
    required Map<String, dynamic> category,
    required int todoCount,
    required int index,
    required bool isArchived,
  }) {
    final categoryName = category['name'] as String;
    final todoState = ref.watch(todoProvider);

    // 활성: 미완료 할일, 보관: 완료된 할일
    final categoryTodos =
        isArchived
            ? todoState.allTodos
                .where(
                  (todo) => todo.category == categoryName && todo.isCompleted,
                )
                .toList()
            : todoState.allTodos
                .where(
                  (todo) => todo.category == categoryName && !todo.isCompleted,
                )
                .toList();

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildCategoryCard(
        category,
        todoCount,
        isArchived,
        index,
        categoryTodos,
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    int todoCount,
    bool isArchived,
    int index,
    List<dynamic> categoryTodos,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 12,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들 (활성 카테고리만)
              if (!isArchived)
                Icon(Icons.drag_handle, color: Colors.grey.shade400, size: 20),
              if (!isArchived) const SizedBox(width: 12),
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
          title: Text(
            isArchived
                ? '${category['name']} (완료: ${categoryTodos.length})'
                : '${category['name']} (미완료: $todoCount)',
            style: const TextStyle(
              fontFamily: 'OmyuPretty',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 확장 아이콘은 자동으로 추가되므로 PopupMenu만
              PopupMenuButton<String>(
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
                    case 'move':
                      _showMoveTodosDialog(category['name'] as String);
                      break;
                    case 'archive':
                      _archiveCategory(category['name'] as String);
                      break;
                    case 'unarchive':
                      _showUnarchiveDialog(category['name'] as String);
                      break;
                    case 'delete':
                      _showDeleteCategoryDialog(category, index);
                      break;
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      if (!isArchived)
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
                      if (!isArchived && todoCount > 0)
                        const PopupMenuItem<String>(
                          value: 'move',
                          child: Row(
                            children: [
                              Icon(Icons.drive_file_move, size: 16),
                              SizedBox(width: 8),
                              Text('할일 이동'),
                            ],
                          ),
                        ),
                      if (!isArchived)
                        const PopupMenuItem<String>(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive, size: 16),
                              SizedBox(width: 8),
                              Text('보관'),
                            ],
                          ),
                        ),
                      if (isArchived)
                        const PopupMenuItem<String>(
                          value: 'unarchive',
                          child: Row(
                            children: [
                              Icon(Icons.unarchive, size: 16),
                              SizedBox(width: 8),
                              Text('보관 해제'),
                            ],
                          ),
                        ),
                      if (isArchived)
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
            ],
          ),
          children: [
            if (categoryTodos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isArchived ? '완료된 할일이 없습니다' : '할일이 없습니다',
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            else
              ...categoryTodos.map((todo) {
                final dateText =
                    isArchived
                        ? _formatCompletedDate(todo.completedAt)
                        : _formatScheduledDate(todo.scheduledDate);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isArchived
                            ? Icons.check_box
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: isArchived ? Colors.green : category['color'] as Color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 14,
                                color: Colors.black87,
                                decoration:
                                    isArchived
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateText,
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // 요일 반환
  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  // 완료 날짜 포맷팅
  String _formatCompletedDate(DateTime? completedAt) {
    if (completedAt == null) return '완료 날짜 없음';

    final weekday = _getWeekday(completedAt);
    return '${completedAt.year}-${completedAt.month.toString().padLeft(2, '0')}-${completedAt.day.toString().padLeft(2, '0')} ($weekday) 완료';
  }

  // 예정 날짜 포맷팅
  String _formatScheduledDate(DateTime scheduledDate) {
    final weekday = _getWeekday(scheduledDate);
    return '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')} ($weekday) 등록';
  }

  Widget _buildTodoPreview(String categoryName) {
    final todoState = ref.watch(todoProvider);
    final categoryTodos =
        todoState.allTodos
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
    // 미완료된 할일만 카운트
    return todos
        .where((todo) => todo.category == categoryName && !todo.isCompleted)
        .length;
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, int index) {
    final TextEditingController nameController = TextEditingController(
      text: category['name'] as String,
    );
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
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
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
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
                                      final newName =
                                          nameController.text.trim();

                                      // 이름이 변경되지 않았으면 그냥 색상만 업데이트
                                      if (newName == originalName) {
                                        await _updateCategoryName(
                                          originalName,
                                          newName,
                                          selectedColor,
                                        );
                                        Navigator.of(context).pop();
                                        return;
                                      }

                                      // 중복 검사
                                      final categoryState = ref.read(
                                        categoryProvider,
                                      );
                                      final existingCategory =
                                          categoryState.categories
                                              .where(
                                                (c) =>
                                                    c.name == newName &&
                                                    c.name != originalName,
                                              )
                                              .firstOrNull;

                                      if (existingCategory != null) {
                                        // 중복된 카테고리가 있음
                                        Navigator.of(context).pop();

                                        final statusMessage =
                                            existingCategory.isArchived
                                                ? '보관함에 "$newName" 카테고리가 이미 존재합니다.'
                                                : '"$newName" 카테고리가 이미 존재합니다.';

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              statusMessage,
                                              style: const TextStyle(
                                                fontFamily: 'OmyuPretty',
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      await _updateCategoryName(
                                        originalName,
                                        newName,
                                        selectedColor,
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
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
  Future<void> _updateCategoryName(
    String originalName,
    String newName,
    Color newColor,
  ) async {
    final todoState = ref.read(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);

    // 해당 카테고리의 모든 할일 업데이트
    final todosToUpdate =
        todoState.allTodos
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
      final newOrder =
          currentOrder
              .map((name) => name == originalName ? newName : name)
              .toList();
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

  // 카테고리 보관
  Future<void> _archiveCategory(String categoryName) async {
    final todoState = ref.read(todoProvider);

    // 해당 카테고리의 미완료 할일 확인
    final incompleteTodos =
        todoState.allTodos
            .where((todo) => todo.category == categoryName && !todo.isCompleted)
            .toList();

    if (incompleteTodos.isNotEmpty) {
      // 미완료 할일이 있으면 보관 불가
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$categoryName 카테고리에 미완료된 할일이 ${incompleteTodos.length}개 있습니다.\n모든 할일을 완료한 후 보관해주세요.',
              style: const TextStyle(fontFamily: 'OmyuPretty'),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final categoryNotifier = ref.read(categoryProvider.notifier);
    final success = await categoryNotifier.archiveCategory(categoryName);

    if (!success) {
      // 보관 실패 (활성 카테고리가 1개만 남음)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '카테고리가 최소 1개 이상 필요합니다.',
              style: TextStyle(fontFamily: 'OmyuPretty'),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // 보관 성공
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$categoryName 카테고리가 보관되었습니다.',
              style: const TextStyle(fontFamily: 'OmyuPretty'),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  // 카테고리 보관 해제 다이얼로그
  void _showUnarchiveDialog(String categoryName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              '카테고리 복원',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              '$categoryName 카테고리를 복원하시겠습니까?',
              style: const TextStyle(fontFamily: 'OmyuPretty', fontSize: 14),
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
                  await _unarchiveCategory(categoryName);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '복원',
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // 카테고리 보관 해제
  Future<void> _unarchiveCategory(String categoryName) async {
    final categoryNotifier = ref.read(categoryProvider.notifier);
    await categoryNotifier.unarchiveCategory(categoryName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$categoryName 카테고리가 복원되었습니다.',
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

    // 미완료된 할일만 체크
    final incompleteTodoCount =
        todoState.allTodos
            .where((todo) => todo.category == categoryName && !todo.isCompleted)
            .length;

    // 미완료 할일이 있으면 삭제 불가
    if (incompleteTodoCount > 0) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                '카테고리 삭제 불가',
                style: TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                '$categoryName 카테고리에 미완료된 할일이 $incompleteTodoCount개 남아 있습니다.\n모든 할일을 완료하거나 삭제한 후 카테고리를 삭제해주세요.',
                style: const TextStyle(fontFamily: 'OmyuPretty', fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              '카테고리 삭제',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              '$categoryName 카테고리를 삭제하시겠습니까?',
              style: const TextStyle(fontFamily: 'OmyuPretty', fontSize: 14),
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
                  // 카테고리 삭제
                  final categoryNotifier = ref.read(categoryProvider.notifier);
                  await categoryNotifier.deleteCategory(categoryName);

                  // 카테고리 순서에서도 제거
                  final categoryOrderNotifier = ref.read(
                    categoryOrderProvider.notifier,
                  );
                  await categoryOrderNotifier.removeCategoryFromOrder(
                    categoryName,
                  );

                  Navigator.of(context).pop();

                  // 삭제 완료 메시지
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$categoryName 카테고리가 삭제되었습니다.',
                          style: const TextStyle(fontFamily: 'OmyuPretty'),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  '삭제',
                  style: TextStyle(fontFamily: 'OmyuPretty', color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // 할일 이동 다이얼로그
  void _showMoveTodosDialog(String fromCategory) async {
    final categoryState = ref.read(categoryProvider);
    final todoState = ref.read(todoProvider);

    // 이동 가능한 카테고리 목록 (현재 카테고리 제외, 보관되지 않은 것만)
    final availableCategories = categoryState.categories
        .where((cat) => cat.name != fromCategory && !cat.isArchived)
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '이동 가능한 다른 카테고리가 없습니다.',
            style: TextStyle(fontFamily: 'OmyuPretty'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 이동할 할일 개수
    final todoCount = todoState.allTodos
        .where((todo) => todo.category == fromCategory && !todo.isCompleted)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '할일 이동',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$fromCategory 카테고리의 미완료 할일 $todoCount개를\n다른 카테고리로 이동합니다.',
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '이동할 카테고리를 선택하세요:',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...availableCategories.map((category) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _moveTodosToCategory(fromCategory, category.name, category.color, category.accentColor);
                },
              );
            }).toList(),
          ],
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
        ],
      ),
    );
  }

  // 카테고리의 모든 미완료 할일을 다른 카테고리로 이동
  Future<void> _moveTodosToCategory(
    String fromCategory,
    String toCategory,
    Color toColor,
    Color toAccentColor,
  ) async {
    final todoState = ref.read(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);

    // 이동할 할일 목록 (미완료만)
    final todosToMove = todoState.allTodos
        .where((todo) => todo.category == fromCategory && !todo.isCompleted)
        .toList();

    // 모든 할일 이동
    for (var todo in todosToMove) {
      await todoNotifier.moveTodoToCategory(
        todo.id,
        toCategory,
        toColor,
        toAccentColor,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$fromCategory → $toCategory 카테고리로 ${todosToMove.length}개의 할일이 이동되었습니다.',
            style: const TextStyle(fontFamily: 'OmyuPretty'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
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
      categoryMap['일반'] = {'name': '일반', 'color': const Color(0xFF6366F1)};
    }

    return categoryMap.values.toList();
  }
}
