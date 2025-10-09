import 'package:flutter/material.dart';
import '../../../../common/constant/app_constants.dart';

class TodoViewHeaderFragment extends StatelessWidget {
  final int viewIndex;
  final Function(int) onViewChanged;

  const TodoViewHeaderFragment({
    super.key,
    required this.viewIndex,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
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
    );
  }
}
