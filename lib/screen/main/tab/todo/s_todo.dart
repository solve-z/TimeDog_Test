import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import 'daily_objective_provider.dart';
import 'f_todo_list.dart';
import 'f_time_record.dart';
import '../../../../common/constant/app_constants.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen>
    with TickerProviderStateMixin {
  int _viewIndex = 0; // 0: 할일리스트, 1: 타임레코드
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  bool _isInfoCardExpanded = true; // InfoCard 펼침/접힘 상태
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isInfoCardExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildInfoCard(),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                _buildViewHeader(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: _viewIndex == 0 ? 24 : 48),
              child: _buildCurrentView(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // SafeArea 공간
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header with collapse/expand button
          IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 8),
                // Date 앞쪽 강조선
                Container(width: 1, color: Colors.grey.shade400),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showDatePicker(),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Date.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 10,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                // Total Time 앞쪽 강조선
                Container(width: 1, color: Colors.grey.shade400),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Time.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Consumer(
                          builder: (context, ref, child) {
                            final todoState = ref.watch(todoProvider);
                            final filteredTodos = _getFilteredTodosByDate(
                              todoState.allTodos,
                            );
                            final totalMinutes = filteredTodos.fold<int>(
                              0,
                              (sum, todo) => sum + todo.totalFocusTimeInMinutes,
                            );
                            final totalTime = _formatTotalTime(totalMinutes);

                            return Text(
                              totalTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Collapse/Expand 버튼
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleInfoCard,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value * 3.14159, // 180도 회전
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Collapsible content
          SizeTransition(
            sizeFactor: _animation,
            child: Column(
              children: [
                // 전체 너비 Divider (패딩 영향 안받음)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                // Object 행
                IntrinsicHeight(
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      // Object 앞쪽 강조선
                      Container(width: 1, color: Colors.grey.shade400),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showObjectiveEditDialog(),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Object.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit,
                                        size: 10,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      ref.watch(dailyObjectiveProvider);
                                      final objective = ref
                                          .read(dailyObjectiveProvider.notifier)
                                          .getObjective(_selectedDate);
                                      return Text(
                                        objective.isEmpty
                                            ? '목표를 설정해주세요'
                                            : objective,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              objective.isEmpty
                                                  ? Colors.grey.shade400
                                                  : Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    final todoState = ref.watch(todoProvider);
    final filteredTodos = _getFilteredTodosByDate(todoState.allTodos);

    switch (_viewIndex) {
      case 0:
        return TodoListFragment(
          filteredTodos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      case 1:
        return TimeRecordFragment(
          todos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      default:
        return TodoListFragment(
          filteredTodos: filteredTodos,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
    }
  }

  // 선택된 날짜에 따라 할일 필터링
  List<TodoItemVo> _getFilteredTodosByDate(List<TodoItemVo> todos) {
    return todos.where((todo) {
      return todo.scheduledDate.year == _selectedDate.year &&
          todo.scheduledDate.month == _selectedDate.month &&
          todo.scheduledDate.day == _selectedDate.day;
    }).toList();
  }

  // 날짜 선택 다이얼로그
  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 총 시간 포맷팅
  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}H ${mins}M';
    } else {
      return '${mins}M';
    }
  }

  Widget _buildViewHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _viewIndex == 0 ? 'Task' : 'Time Record',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _viewIndex = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _viewIndex == 0
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: _viewIndex == 0 ? AppColors.primary : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _viewIndex = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _viewIndex == 1
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: _viewIndex == 1 ? AppColors.primary : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // InfoCard 접기/펼치기 토글
  void _toggleInfoCard() {
    setState(() {
      _isInfoCardExpanded = !_isInfoCardExpanded;
    });

    if (_isInfoCardExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // 목표 수정 다이얼로그
  void _showObjectiveEditDialog() async {
    final currentObjective = ref
        .read(dailyObjectiveProvider.notifier)
        .getObjective(_selectedDate);

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => _ObjectiveEditDialog(
            initialText: currentObjective,
            selectedDate: _selectedDate,
          ),
    );

    if (result != null) {
      await ref
          .read(dailyObjectiveProvider.notifier)
          .setObjective(_selectedDate, result);
    }
  }

  // 할일 추가 다이얼로그
  void _showAddTodoDialog() {
    final todoNotifier = ref.read(todoProvider.notifier);
    final TextEditingController titleController = TextEditingController();

    String selectedCategory = '일반';
    Color selectedColor = AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
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
                        onTap: () => _showCategorySelection(
                          context,
                          selectedCategory,
                          (category, color) {
                            setState(() {
                              selectedCategory = category;
                              selectedColor = color;
                            });
                          },
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
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
                            _addNewTodo(
                              todoNotifier,
                              titleController.text.trim(),
                              selectedCategory,
                              selectedColor,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
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

                SafeArea(child: const SizedBox(height: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNewTodo(todoNotifier, String title, String category, Color color) {
    final newTodo = TodoItemVo(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: null,
      category: category,
      color: color,
      accentColor: color.withOpacity(0.8),
      scheduledDate: _selectedDate, // 선택된 날짜 사용
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: false,
      focusTimeRecords: [],
    );

    todoNotifier.addTodo(newTodo);
  }

  // 전역 카테고리 목록 (새 카테고리가 여기에 저장됨)
  static List<Map<String, dynamic>> _globalCategories = [
    {'name': '일반', 'color': const Color(0xFF6366F1)},
    {'name': '영어', 'color': const Color(0xFFD9B5FF)},
    {'name': '수학', 'color': const Color(0xFFB6D6FF)},
    {'name': '운동', 'color': const Color(0xFFFFBDD0)},
    {'name': '독서', 'color': const Color(0xFFB8E6B8)},
    {'name': '과제', 'color': const Color(0xFFFFE4B5)},
    {'name': '취미', 'color': const Color(0xFFE1BEE7)},
  ];

  void _showCategorySelection(
    BuildContext context,
    String currentCategory,
    Function(String, Color) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
              maxWidth: 350,
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
                        ..._globalCategories.map((category) {
                          final isSelected =
                              currentCategory == category['name'];
                          return GestureDetector(
                            onTap: () {
                              onSelected(
                                category['name'] as String,
                                category['color'] as Color,
                              );
                              Navigator.of(context).pop();
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
                            final result = await _showNewCategoryDialog(
                              context,
                            );
                            if (result != null) {
                              setState(() {
                                _globalCategories.add({
                                  'name': result['name'],
                                  'color': result['color'],
                                });
                              });
                              onSelected(
                                result['name'] as String,
                                result['color'] as Color,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showNewCategoryDialog(
    BuildContext context,
  ) async {
    final TextEditingController categoryController = TextEditingController();
    Color selectedColor = const Color(0xFF6366F1);

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

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                        children: colors.map((color) {
                          final isSelected = color == selectedColor;
                          return GestureDetector(
                            onTap: () => setState(
                              () => selectedColor = color,
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
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

class _ObjectiveEditDialog extends StatefulWidget {
  final String initialText;
  final DateTime selectedDate;

  const _ObjectiveEditDialog({
    required this.initialText,
    required this.selectedDate,
  });

  @override
  State<_ObjectiveEditDialog> createState() => _ObjectiveEditDialogState();
}

class _ObjectiveEditDialogState extends State<_ObjectiveEditDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.selectedDate.year}.${widget.selectedDate.month.toString().padLeft(2, '0')}.${widget.selectedDate.day.toString().padLeft(2, '0')} 목표',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '오늘의 목표를 입력해주세요',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
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
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.of(context).pop(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
