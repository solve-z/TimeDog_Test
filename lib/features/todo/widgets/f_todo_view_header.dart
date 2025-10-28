import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/constants/app_constants.dart';
import '../screens/s_todo_list.dart';

class TodoViewHeaderFragment extends StatelessWidget {
  final int viewIndex;
  final DateTime selectedDate;
  final Function(int) onViewChanged;
  final VoidCallback onTodayPressed;
  final VoidCallback onAddTodoPressed;

  const TodoViewHeaderFragment({
    super.key,
    required this.viewIndex,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onTodayPressed,
    required this.onAddTodoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 오늘 날짜로 돌아가기 버튼
          GestureDetector(
            onTap: onTodayPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.today, color: Colors.grey.shade700, size: 16),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              // 할일 추가 버튼
              GestureDetector(
                onTap: onAddTodoPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              // 할일리스트 화면 이동 버튼
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TodoListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AssetPaths.listIcon,
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
