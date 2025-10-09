import 'package:flutter/material.dart';
import '../../../../common/constant/app_constants.dart';

class TodoViewHeaderFragment extends StatelessWidget {
  final int viewIndex;
  final DateTime selectedDate;
  final Function(int) onViewChanged;
  final VoidCallback onTodayPressed;

  const TodoViewHeaderFragment({
    super.key,
    required this.viewIndex,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onTodayPressed,
  });

  bool _isToday() {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            viewIndex == 0 ? 'Task' : 'Task & Record',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              // 오늘 날짜로 돌아가기 버튼 (오늘이 아닐 때만 표시)
              if (!_isToday())
                GestureDetector(
                  onTap: onTodayPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.today,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
                  ),
                ),
              if (!_isToday()) const SizedBox(width: 8),
              // 타임 레코드 보기 버튼
              GestureDetector(
                onTap: () => onViewChanged(viewIndex == 0 ? 1 : 0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        viewIndex == 1
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: viewIndex == 1 ? AppColors.primary : Colors.grey,
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
}
