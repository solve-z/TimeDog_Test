import 'package:flutter/material.dart';
import 'vo/vo_todo_item.dart';

class TimeRecordFragment extends StatefulWidget {
  final List<TodoItemVo> todos;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final String? selectedCategory; // 외부에서 전달받는 선택된 카테고리

  const TimeRecordFragment({
    super.key,
    required this.todos,
    this.physics,
    this.shrinkWrap = false,
    this.selectedCategory,
  });

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
    return timeSlots[index];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shrinkWrap) {
      // shrinkWrap이 true일 때는 고정 높이 사용
      return SizedBox(
        height: 576, // 충분한 높이 설정
        child: _buildTimeGrid(),
      );
    } else {
      // 기본 구조
      return _buildTimeGrid();
    }
  }

  Widget _buildTimeGrid() {
    return Container(
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(
            child:
                widget.shrinkWrap
                    ? Column(
                      children:
                          timeSlots.asMap().entries.map((entry) {
                            return Expanded(
                              child: _buildTimeRow(entry.value, entry.key),
                            );
                          }).toList(),
                    )
                    : ListView.builder(
                      physics: widget.physics,
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
    return Container(
      height: widget.shrinkWrap ? null : 24, // shrinkWrap일 때는 높이 제한 없음
      child: Row(
        children: [
          // 시간 레이블 열 (정사각형)
          SizedBox(
            width: 24,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
              ),
              child: Center(
                child: Text(
                  _getTimeLabel(timeIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          ...List.generate(6, (dayIndex) {
            final progressData = _getCellProgressData(timeIndex, dayIndex);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (progressData != null &&
                      progressData.todo != null &&
                      progressData.focusRecord != null) {
                    _showFocusRecordDialog(
                      progressData.todo!,
                      progressData.focusRecord!,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child:
                      progressData != null
                          ? LayoutBuilder(
                            builder: (context, constraints) {
                              final cellWidth = constraints.maxWidth;
                              final startPosition =
                                  cellWidth * progressData.startOffset;
                              final endPosition =
                                  cellWidth * progressData.progress;

                              return Stack(
                                children: [
                                  Positioned(
                                    left: startPosition,
                                    right: cellWidth - endPosition,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(color: progressData.color),
                                  ),
                                ],
                              );
                            },
                          )
                          : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  CellProgressData? _getCellProgressData(int timeIndex, int columnIndex) {
    double maxProgress = 0.0;
    double resultStartOffset = 0.0;
    Color? resultColor;
    TodoItemVo? selectedTodo;
    FocusTimeRecord? selectedRecord;

    // 해당 시간 슬롯과 10분 단위에서 집중 진행률 계산
    for (final todo in widget.todos) {
      // 카테고리 필터링: 선택된 카테고리가 있으면 해당 카테고리만 표시
      final todoCategory = todo.category ?? '기타';
      if (widget.selectedCategory != null &&
          widget.selectedCategory != todoCategory) {
        continue; // 선택된 카테고리가 아니면 건너뛰기
      }

      for (final record in todo.focusTimeRecords) {
        final cellData = _calculateCellData(record, timeIndex, columnIndex);

        if (cellData != null && cellData.progress > maxProgress) {
          maxProgress = cellData.progress;
          resultStartOffset = cellData.startOffset;
          resultColor = todo.color.withOpacity(0.7);
          selectedTodo = todo;
          selectedRecord = record;
        }
      }
    }

    if (maxProgress > 0 &&
        resultColor != null &&
        selectedTodo != null &&
        selectedRecord != null) {
      return CellProgressData(
        progress: maxProgress,
        startOffset: resultStartOffset,
        color: resultColor,
        todo: selectedTodo,
        focusRecord: selectedRecord,
      );
    }

    return null;
  }

  ({double progress, double startOffset})? _calculateCellData(
    FocusTimeRecord record,
    int timeIndex,
    int columnIndex,
  ) {
    final targetHour = _getHourFromIndex(timeIndex);
    if (targetHour == -1) return null;

    final targetMinute = columnIndex * 10; // 0, 10, 20, 30, 40, 50

    // 기록의 타임라인 기준일 계산 (6시 기준)
    final recordHour = record.startTime.hour;
    final recordBaseDate =
        recordHour < 6
            ? DateTime(
              record.startTime.year,
              record.startTime.month,
              record.startTime.day - 1,
            )
            : DateTime(
              record.startTime.year,
              record.startTime.month,
              record.startTime.day,
            );

    // 슬롯 시간 계산 (0~5시는 타임라인 기준 다음날)
    final needsNextDay = targetHour >= 0 && targetHour <= 5;
    final slotStart = DateTime(
      recordBaseDate.year,
      recordBaseDate.month,
      recordBaseDate.day + (needsNextDay ? 1 : 0),
      targetHour,
      targetMinute,
    );
    final slotEnd = slotStart.add(Duration(minutes: 10));

    // 집중 시간과 슬롯의 겹치는 부분 계산
    final overlapStart = _laterTime(record.startTime, slotStart);
    final overlapEnd = _earlierTime(record.endTime, slotEnd);

    if (overlapStart.isBefore(overlapEnd)) {
      // 슬롯 내에서 시작 위치 계산 (10% 단위로 스냅)
      final startOffsetMinutes = overlapStart.difference(slotStart).inMinutes;
      final startOffset = (startOffsetMinutes / 10.0).clamp(0.0, 1.0);

      // 슬롯 내에서 종료 위치 계산 (10% 단위로 스냅)
      final endOffsetMinutes = overlapEnd.difference(slotStart).inMinutes;
      final endPosition = (endOffsetMinutes / 10.0).clamp(0.0, 1.0);

      return (progress: endPosition, startOffset: startOffset);
    }

    return null;
  }

  DateTime _laterTime(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
  DateTime _earlierTime(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  int _getHourFromIndex(int index) {
    // 인덱스를 실제 시간으로 변환 (6AM~다음날 5AM)
    // timeSlots: ['6','7','8','9','10','11','12','1','2','3','4','5','6','7','8','9','10','11','12','1','2','3','4','5']
    // 실제 시간: [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,0,1,2,3,4,5]

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

  // 집중 기록 정보를 보여주는 다이얼로그
  void _showFocusRecordDialog(TodoItemVo todo, FocusTimeRecord record) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '집중 기록 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: todo.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '할일: ${todo.title}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '카테고리: ${todo.category ?? "기타"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                if (todo.description != null &&
                    todo.description!.isNotEmpty) ...[
                  Text(
                    '설명: ${todo.description}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '집중 시간: ${record.formattedDuration}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatTime(record.startTime)} ~ ${_formatTime(record.endTime)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '집중 유형: ${record.focusType == FocusType.pomodoro ? "포모도로" : "스톱워치"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              Center(
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // 시간 포맷팅 헬퍼 함수
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class CellProgressData {
  final double progress; // 종료 위치 (0.0 ~ 1.0)
  final double startOffset; // 시작 위치 (0.0 ~ 1.0)
  final Color color;
  final TodoItemVo? todo;
  final FocusTimeRecord? focusRecord;

  CellProgressData({
    required this.progress,
    required this.startOffset,
    required this.color,
    this.todo,
    this.focusRecord,
  });
}
