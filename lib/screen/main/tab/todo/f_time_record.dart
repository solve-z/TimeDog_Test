import 'package:flutter/material.dart';
import 'vo/vo_todo_category.dart';

class TimeRecordFragment extends StatefulWidget {
  final List<TodoCategoryVo> categories;

  const TimeRecordFragment({super.key, required this.categories});

  @override
  State<TimeRecordFragment> createState() => _TimeRecordFragmentState();
}

class _TimeRecordFragmentState extends State<TimeRecordFragment> {
  final List<String> timeSlots = [
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  // 더미 데이터: 시간대별로 어떤 카테고리가 활성화되었는지
  final Map<String, List<int>> categoryTimeData = {
    '영어': [6, 7],
    '수능특강': [8, 9],
    '수학': [10, 11, 12, 1, 2, 3, 4],
    '문학': [7, 8, 9, 10, 11, 12],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCategoryList(), Expanded(child: _buildTimeGrid())],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      width: 80,
      child: Column(
        children:
            widget.categories.map((category) {
              return Container(
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: category.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16, // 20% of 80px width
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: category.accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: [
          // _buildTimeHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                return _buildTimeRow(timeSlots[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, int timeIndex) {
    BorderRadius? borderRadius;
    if (timeIndex == 0) {
      // 첫 번째 행 - 상단 왼쪽 모서리만 둥글게
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(12));
    } else if (timeIndex == timeSlots.length - 1) {
      // 마지막 행 - 하단 왼쪽 모서리만 둥글게
      borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(12));
    }

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Container(
            width: 38,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFF656565), width: 1),
                left: BorderSide(color: const Color(0xFF656565), width: 1),
                right: BorderSide(color: const Color(0xFF656565), width: 1),
              ),
              borderRadius: borderRadius,
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ...List.generate(6, (dayIndex) {
            Color? cellColor = _getCellColor(timeIndex);
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color? _getCellColor(int timeIndex) {
    // 더미 데이터를 기반으로 해당 시간대에 활성화된 카테고리의 색상 반환
    for (int i = 0; i < widget.categories.length; i++) {
      final category = widget.categories[i];
      final timeData = categoryTimeData[category.name];
      if (timeData != null && timeData.contains(timeIndex)) {
        return category.backgroundColor;
      }
    }
    return null;
  }
}
