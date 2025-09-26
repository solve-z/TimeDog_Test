import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vo/todo_items_dummy.dart';
import 'vo/vo_todo_item.dart';
import 'todo_provider.dart';
import 'f_todo_list.dart';
import 'f_time_record.dart';
import '../../../../common/constant/app_constants.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  int _viewIndex = 0; // 0: 할일리스트, 1: 타임레코드
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(),
        _buildActionButtons(),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCurrentView(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Date와 Total Time 행
          IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 8),
                // Date 앞쪽 강조선
                Container(width: 1, color: Colors.grey.shade400),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDatePicker(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Date.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          Text(
                            '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Time.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final todoState = ref.watch(todoProvider);
                            final filteredTodos = _getFilteredTodosByDate(todoState.allTodos);
                            final totalMinutes = filteredTodos.fold(0, (sum, todo) => sum + todo.totalFocusTimeInMinutes);
                            final totalTime = _formatTotalTime(totalMinutes);


                            return Text(
                              totalTime,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Object.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Text(
                          '토탈 타임 8시간 이상',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
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
        return TodoListFragment(filteredTodos: filteredTodos);
      case 1:
        return TimeRecordFragment(todos: filteredTodos);
      default:
        return TodoListFragment(filteredTodos: filteredTodos);
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _viewIndex = 0; // 할일리스트
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _viewIndex == 0 ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit,
              color: _viewIndex == 0 ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _viewIndex = 1; // 타임레코드
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _viewIndex == 1 ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              color: _viewIndex == 1 ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}