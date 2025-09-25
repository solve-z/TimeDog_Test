import 'package:flutter/material.dart';
import 'vo/todo_items_dummy.dart';
import 'f_todo_list.dart';
import 'f_time_record.dart';
import '../../../../common/constant/app_constants.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int _viewIndex = 0; // 0: 할일리스트, 1: 타임레코드

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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                        const Text(
                          '4H 30M',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
    switch (_viewIndex) {
      case 0:
        return TodoListFragment(todos: dummyTodoItems);
      case 1:
        return TimeRecordFragment(todos: dummyTodoItems);
      default:
        return TodoListFragment(todos: dummyTodoItems);
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