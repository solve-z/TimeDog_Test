import 'package:flutter/material.dart';
import 'vo/vo_todo_category.dart';
import 'vo/vo_todo_item.dart';

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
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  String _getTimeLabel(int index) {
    final time = timeSlots[index];
    if (index == 0) return '🌅$time'; // 아침 6시 (일출 아이콘)
    if (index == 6) return '☀️$time'; // 정오 12시 (해 아이콘)
    if (index == 12) return '🌇$time'; // 저녁 6시 (일몰 아이콘)
    if (index == 18) return '🌠$time'; // 자정 12시 (별똥별 아이콘, 다음날 시작)
    return time;
  }

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
        children: [
          const SizedBox(height: 8), // 카테고리 시작 지점을 아래로 내리기 위한 여백
          ...widget.categories.map((category) {
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
          }),
        ],
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
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(12));
    } else if (timeIndex == timeSlots.length - 1) {
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
                bottom:
                    timeIndex == timeSlots.length - 1
                        ? BorderSide(color: const Color(0xFF656565), width: 1)
                        : BorderSide.none,
              ),
              borderRadius: borderRadius,
            ),
            child: Center(
              child: Text(
                _getTimeLabel(timeIndex),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ...List.generate(6, (dayIndex) {
            final progressData = _getCellProgressData(timeIndex, dayIndex);
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child:
                    progressData != null
                        ? Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progressData.progress,
                            child: Container(
                              height: double.infinity,
                              color: progressData.color,
                            ),
                          ),
                        )
                        : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  CellProgressData? _getCellProgressData(int timeIndex, int columnIndex) {
    double maxProgress = 0.0;
    Color? resultColor;

    // 해당 시간 슬롯과 10분 단위에서 집중 진행률 계산
    for (final category in widget.categories) {
      for (final todo in category.todos) {
        for (final record in todo.focusTimeRecords) {
          final progress = _calculateProgress(record, timeIndex, columnIndex);
          if (progress > maxProgress) {
            maxProgress = progress;
            resultColor = category.backgroundColor;
          }
        }
      }
    }

    if (maxProgress > 0 && resultColor != null) {
      return CellProgressData(progress: maxProgress, color: resultColor);
    }
    return null;
  }

  double _calculateProgress(
    FocusTimeRecord record,
    int timeIndex,
    int columnIndex,
  ) {
    final targetHour = _getHourFromIndex(timeIndex);
    if (targetHour == -1) return 0.0;

    final targetMinute = columnIndex * 10; // 0, 10, 20, 30, 40, 50
    final slotStart = DateTime(2025, 9, 19, targetHour, targetMinute);
    final slotEnd = slotStart.add(Duration(minutes: 10));

    // 집중 시간과 슬롯의 겹치는 부분 계산
    final overlapStart = _laterTime(record.startTime, slotStart);
    final overlapEnd = _earlierTime(record.endTime, slotEnd);

    if (overlapStart.isBefore(overlapEnd)) {
      final overlapMinutes = overlapEnd.difference(overlapStart).inMinutes;
      return (overlapMinutes / 10.0).clamp(0.0, 1.0); // 10분 기준으로 진행률 계산
    }

    return 0.0;
  }

  DateTime _laterTime(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
  DateTime _earlierTime(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  int _getHourFromIndex(int index) {
    // 인덱스를 실제 시간으로 변환 (6AM~다음날 5AM)
    // 6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5
    // 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,0,1,2,3,4,5

    if (index >= 0 && index < 6) {
      // 6,7,8,9,10,11 AM
      return index + 6;
    } else if (index >= 6 && index < 12) {
      // 12,1,2,3,4,5 PM (정오~오후5시)
      return index == 6 ? 12 : index + 6; // 12시는 12, 1~5는 13~17
    } else if (index >= 12 && index < 18) {
      // 6,7,8,9,10,11 PM (오후6시~오후11시)
      return index + 6; // 18~23
    } else if (index >= 18 && index < 24) {
      // 12,1,2,3,4,5 AM 다음날 (자정~새벽5시)
      return index == 18 ? 0 : index - 18; // 12시는 0(자정), 1~5는 1~5
    }
    return -1;
  }
}

class CellProgressData {
  final double progress; // 0.0 ~ 1.0
  final Color color;

  CellProgressData({required this.progress, required this.color});
}
