import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timedog_test/common/constant/app_constants.dart';
import 'f_character_animation.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';
import 'd_timer_settings.dart';
import '../todo/todo_provider.dart';
import '../todo/vo/vo_todo_item.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final todoState = ref.watch(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 모드, 할일, 설정 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: 모드 선택
                  GestureDetector(
                    onTap: () => timerNotifier.toggleMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timerState.mode == TimerMode.pomodoro ? '뽀모도로' : '스톱워치',
                        style: const TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),

                  // 중앙: 할일 표시 영역
                  Flexible(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _showTodoSelectionDialog(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                todoState.selectedTodo?.color.withOpacity(
                                  0.1,
                                ) ??
                                const Color(0xFFF9FAFB),
                            border: Border.all(
                              color:
                                  todoState.selectedTodo?.color.withOpacity(
                                    0.3,
                                  ) ??
                                  const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (todoState.selectedTodo != null) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: todoState.selectedTodo!.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  todoState.selectedTodo!.title,
                                  style: const TextStyle(
                                    fontFamily: 'OmyuPretty',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '할일 선택',
                                  style: TextStyle(
                                    fontFamily: 'OmyuPretty',
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 오른쪽: 설정 아이콘
                  Container(
                    width: 70, // 왼쪽 모드 버튼과 대칭을 위한 최소 너비
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 설정 화면으로 이동
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          'assets/images/icons/setting.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6B7280),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 타이머 표시
            Stack(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const TimerSettingsDialog(),
                        );
                      },
                      child: Text(
                        timerState.formattedTime,
                        style: const TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF6B7280),
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    if (timerState.startTime != null &&
                        timerState.status == TimerStatus.running)
                      Text(
                        '시작: ${_formatTime(timerState.startTime!)}',
                        style: const TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    if (timerState.endTime != null &&
                        timerState.status == TimerStatus.paused)
                      Column(
                        children: [
                          if (timerState.startTime != null) ...[
                            Text(
                              '시작: ${_formatTime(timerState.startTime!)}',
                              style: const TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              '종료: ${_formatTime(timerState.endTime!)}',
                              style: const TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              '소요: ${_formatDuration(timerState.endTime!.difference(timerState.startTime!))}',
                              style: const TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 12,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 라운드 진행 상태 (뽀모도로 모드에서만)
            if (timerState.mode == TimerMode.pomodoro)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    timerState.roundProgress
                        .asMap()
                        .entries
                        .map(
                          (entry) => [
                            if (entry.key > 0) const SizedBox(width: 12),
                            _buildProgressCircle(entry.value),
                          ],
                        )
                        .expand((widgets) => widgets)
                        .toList(),
              ),
            const SizedBox(height: 30),

            // 캐릭터 애니메이션 영역
            const CharacterAnimationFragment(),
            const SizedBox(height: 15),

            // 컨트롤 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    timerState.status == TimerStatus.running
                        ? 'assets/images/icons/pause.svg'
                        : 'assets/images/icons/play.svg',
                    () {
                      if (timerState.status == TimerStatus.running) {
                        timerNotifier.pause();
                      } else {
                        timerNotifier.start();
                      }
                    },
                    timerState.status == TimerStatus.running ? '일시정지' : '시작',
                  ),
                  const SizedBox(width: 20),
                  if (timerState.mode == TimerMode.pomodoro) ...[
                    _buildControlButton(
                      'assets/images/icons/x.svg',
                      () => timerNotifier.stop(),
                      '중지',
                    ),
                    const SizedBox(width: 20),
                  ],
                  _buildControlButton(
                    'assets/images/icons/rotate.svg',
                    () => timerNotifier.reset(),
                    '리셋',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTodoSelectionDialog(BuildContext context, WidgetRef ref) {
    bool showDateSelection = false;
    String selectedDateFilter = '오늘';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
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
                                onTap: () => _showAddTodoDialog(context, ref),
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
                                  ? _buildDateSelectionContent(
                                    context,
                                    ref,
                                    selectedDateFilter,
                                    (filter) {
                                      setState(() {
                                        selectedDateFilter = filter;
                                        showDateSelection = false;
                                      });
                                    },
                                  )
                                  : _buildFilteredTodoList(todoState, todoNotifier, selectedDateFilter),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
            },
          ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final todoNotifier = ref.read(todoProvider.notifier);
    final TextEditingController titleController = TextEditingController();

    String selectedCategory = '일반';
    Color selectedColor = AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Padding(
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
                                onTap:
                                    () => _showCategorySelection(
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
      scheduledDate: DateTime.now(),
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350),
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

  Widget _buildProgressCircle(bool isCompleted) {
    return SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.asset(
        isCompleted
            ? 'assets/images/icons/check_circle.svg'
            : 'assets/images/icons/circle.svg',
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildControlButton(
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF666666),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildDateSelectionContent(
    BuildContext context,
    WidgetRef ref,
    String currentFilter,
    Function(String) onFilterSelected,
  ) {
    final dateOptions = [
      {'title': '오늘', 'icon': Icons.wb_sunny_outlined},
      {'title': '내일', 'icon': Icons.wb_twilight_outlined},
      {'title': '이번 주', 'icon': Icons.calendar_today_outlined},
    ];

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
          }).toList(),

          // 카테고리 목록 (날짜 옵션 바로 아래 이어서)
          ..._globalCategories.map((category) {
            final isSelected = category['name'] == currentFilter;
            return _buildCategoryFilterOption(
              category['name'] as String,
              category['color'] as Color,
              isSelected,
              () => onFilterSelected(category['name'] as String),
            );
          }).toList(),
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

  Widget _buildFilteredTodoList(TodoState todoState, TodoNotifier todoNotifier, String filter) {
    final filteredTodos = _getFilteredTodos(todoState.allTodos, filter);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTodos.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFE5E7EB),
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
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
    switch (filter) {
      case '오늘':
        return todos.where((todo) => _isToday(todo.scheduledDate)).toList();
      case '내일':
        return todos.where((todo) => _isTomorrow(todo.scheduledDate)).toList();
      case '이번 주':
        return todos.where((todo) => _isThisWeek(todo.scheduledDate)).toList();
      default:
        // 카테고리 필터
        return todos.where((todo) => todo.category == filter).toList();
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}
