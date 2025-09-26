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
    return CustomScrollView(
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
