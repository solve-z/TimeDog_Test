import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vo_todo_item.dart';
import '../providers/todo_provider.dart';
import '../providers/daily_objective_provider.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/dialogs/d_objective_edit.dart';

class TodoInfoCardFragment extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const TodoInfoCardFragment({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  ConsumerState<TodoInfoCardFragment> createState() =>
      _TodoInfoCardFragmentState();
}

class _TodoInfoCardFragmentState extends ConsumerState<TodoInfoCardFragment>
    with TickerProviderStateMixin {
  bool _isInfoCardExpanded = true;
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
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          // Header with collapse/expand button
          IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 8),
                // Date 앞쪽 강조선
                Container(width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Row(
                    children: [
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
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${widget.selectedDate.year}.${widget.selectedDate.month.toString().padLeft(2, '0')}.${widget.selectedDate.day.toString().padLeft(2, '0')}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                      Container(width: 1, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Time.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Center(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final todoState = ref.watch(todoProvider);
                                  final filteredTodos = _getFilteredTodosByDate(
                                    todoState.allTodos,
                                  );
                                  final totalMinutes = filteredTodos.fold<int>(
                                    0,
                                    (sum, todo) =>
                                        sum + todo.totalFocusTimeInMinutes,
                                  );
                                  final totalTime = _formatTotalTime(
                                    totalMinutes,
                                  );

                                  return Text(
                                    totalTime,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Collapse/Expand 버튼
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Material(
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
                                    angle:
                                        _animation.value * 3.14159, // 180도 회전
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
                      ),
                    ],
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
                      Container(width: 1, color: Colors.grey.shade300),
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
                                  Align(
                                    alignment: Alignment.center,
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        ref.watch(dailyObjectiveProvider);
                                        final objective = ref
                                            .read(
                                              dailyObjectiveProvider.notifier,
                                            )
                                            .getObjective(widget.selectedDate);
                                        return Text(
                                          objective.isEmpty
                                              ? '목표를 설정해주세요'
                                              : objective,
                                          textAlign: TextAlign.center,
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

  // 선택된 날짜에 따라 할일 필터링
  List<TodoItemVo> _getFilteredTodosByDate(List<TodoItemVo> todos) {
    return todos.where((todo) {
      return todo.scheduledDate.year == widget.selectedDate.year &&
          todo.scheduledDate.month == widget.selectedDate.month &&
          todo.scheduledDate.day == widget.selectedDate.day;
    }).toList();
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

  // 날짜 선택 다이얼로그
  void _showDatePicker() async {
    DateTime selectedDate = widget.selectedDate;
    // 캘린더 재생성을 위한 키
    Key calendarKey = UniqueKey();

    final DateTime? result = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                dividerColor: Colors.transparent,
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  headerBackgroundColor: AppColors.primary,
                  headerForegroundColor: Colors.white,
                  dividerColor: Colors.transparent,
                  dayStyle: const TextStyle(fontSize: 14),
                  yearStyle: const TextStyle(fontSize: 14),
                  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey.shade400;
                    }
                    return Colors.black87;
                  }),
                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return null;
                  }),
                  todayForegroundColor: WidgetStateProperty.resolveWith((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.primary;
                  }),
                  todayBackgroundColor: WidgetStateProperty.resolveWith((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return Colors.transparent;
                  }),
                  todayBorder: BorderSide(color: AppColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 캘린더
                      CalendarDatePicker(
                        key: calendarKey,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        currentDate: DateTime.now(),
                        onDateChanged: (date) {
                          widget.onDateChanged(date);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      const SizedBox(height: 8),
                      // 오늘 버튼
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final today = DateTime.now();
                            widget.onDateChanged(today);
                            Navigator.of(dialogContext).pop();
                          },
                          icon: const Icon(Icons.today, size: 18),
                          label: const Text('오늘'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result != widget.selectedDate) {
      widget.onDateChanged(result);
    }
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
        .getObjective(widget.selectedDate);

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => ObjectiveEditDialog(
            initialText: currentObjective,
            selectedDate: widget.selectedDate,
          ),
    );

    if (result != null) {
      await ref
          .read(dailyObjectiveProvider.notifier)
          .setObjective(widget.selectedDate, result);
    }
  }
}
