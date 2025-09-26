import 'package:flutter/material.dart';
import 'vo/vo_todo_item.dart';

class TimeRecordFragment extends StatefulWidget {
  final List<TodoItemVo> todos;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const TimeRecordFragment({super.key, required this.todos, this.physics, this.shrinkWrap = false});

  @override
  State<TimeRecordFragment> createState() => _TimeRecordFragmentState();
}

class _TimeRecordFragmentState extends State<TimeRecordFragment> {
  String? _selectedCategory; // 선택된 카테고리 (null이면 전체 표시)

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
    if (index == 6) return '🌞$time'; // 정오 12시
    if (index == 18) return '🌙$time'; // 자정 12시
    return time;
  }

  // 텍스트를 세로로 배치하기 위해 각 글자 사이에 개행 추가
  String _formatVerticalText(String text) {
    return text.split('').join('\n');
  }

  // 카테고리 텍스트 포맷팅 (너비가 늘어났으므로 2줄로 표시)
  String _formatCategoryText(String text) {
    if (text.length <= 4) {
      return text;
    } else if (text.length <= 8) {
      // 4글자씩 나누어 2줄로
      int mid = (text.length / 2).ceil();
      return text.substring(0, mid) + '\n' + text.substring(mid);
    } else {
      // 8글자 초과시 7글자까지 표시하고 ...
      return text.substring(0, 3) + '\n' + text.substring(3, 6) + '...';
    }
  }

  // 카테고리 이름 길이에 따른 폰트 크기 조정
  double _getCategoryFontSize(String text) {
    if (text.length <= 4) {
      return 10.0;
    } else if (text.length <= 8) {
      return 9.0;
    } else {
      return 8.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shrinkWrap) {
      // shrinkWrap이 true일 때는 고정 높이 사용
      return SizedBox(
        height: 700, // 충분한 높이 설정
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryList(),
            Expanded(child: _buildTimeGrid()),
          ],
        ),
      );
    } else {
      // 기본 구조
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryList(),
          Expanded(child: _buildTimeGrid()),
        ],
      );
    }
  }

  Widget _buildCategoryList() {
    // 카테고리별로 그룹화
    Map<String, List<TodoItemVo>> grouped = {};
    for (var todo in widget.todos) {
      String category = todo.category ?? '기타';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(todo);
    }

    return SizedBox(
      width: 30,
      child: widget.shrinkWrap
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ...grouped.entries.map((entry) {
                    String categoryName = entry.key;
                    List<TodoItemVo> todos = entry.value;
                    Color categoryColor = todos.first.color;
                    Color accentColor = todos.first.accentColor;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedCategory == categoryName) {
                            _selectedCategory = null;
                          } else {
                            _selectedCategory = categoryName;
                          }
                        });
                      },
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedCategory == categoryName
                              ? categoryColor.withOpacity(0.7)
                              : categoryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                  child: Text(
                                    _formatCategoryText(categoryName),
                                    style: TextStyle(
                                      color: _selectedCategory == categoryName
                                          ? Colors.black
                                          : const Color(0xFF303030),
                                      fontSize: _getCategoryFontSize(categoryName),
                                      fontWeight: _selectedCategory == categoryName
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      height: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            )
          : ListView(
              physics: widget.physics,
              children: [
          const SizedBox(height: 8),
          ...grouped.entries.map((entry) {
            String categoryName = entry.key;
            List<TodoItemVo> todos = entry.value;
            Color categoryColor = todos.first.color;
            Color accentColor = todos.first.accentColor;

            return GestureDetector(
              onTap: () {
                setState(() {
                  // 같은 카테고리를 다시 클릭하면 전체 보기로 변경
                  if (_selectedCategory == categoryName) {
                    _selectedCategory = null;
                  } else {
                    _selectedCategory = categoryName;
                  }
                });
              },
              child: Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: _selectedCategory == categoryName
                    ? categoryColor.withOpacity(0.7)  // 선택된 카테고리는 더 진한 색
                    : categoryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Text(
                            _formatCategoryText(categoryName),
                            style: TextStyle(
                              color: _selectedCategory == categoryName
                                ? Colors.black
                                : const Color(0xFF303030),
                              fontSize: _getCategoryFontSize(categoryName),
                              fontWeight: _selectedCategory == categoryName
                                ? FontWeight.w600
                                : FontWeight.w500,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
                const SizedBox(height: 8),
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
            child: widget.shrinkWrap
                ? Expanded(
                    child: Column(
                      children: timeSlots.asMap().entries.map((entry) {
                        return Expanded(
                          child: _buildTimeRow(entry.value, entry.key),
                        );
                      }).toList(),
                    ),
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
    BorderRadius? borderRadius;
    if (timeIndex == 0) {
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(12));
    } else if (timeIndex == timeSlots.length - 1) {
      borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(12));
    }

    return Container(
      height: widget.shrinkWrap ? null : 28, // shrinkWrap일 때는 높이 제한 없음
      child: Row(
        children: [
          Container(
            width: 42,
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
              child: GestureDetector(
                onTap: () {
                  if (progressData != null && progressData.todo != null && progressData.focusRecord != null) {
                    _showFocusRecordDialog(progressData.todo!, progressData.focusRecord!);
                  }
                },
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
    TodoItemVo? selectedTodo;
    FocusTimeRecord? selectedRecord;

    // 해당 시간 슬롯과 10분 단위에서 집중 진행률 계산
    for (final todo in widget.todos) {
      // 카테고리 필터링: 선택된 카테고리가 있으면 해당 카테고리만 표시
      final todoCategory = todo.category ?? '기타';
      if (_selectedCategory != null && _selectedCategory != todoCategory) {
        continue; // 선택된 카테고리가 아니면 건너뛰기
      }

      for (final record in todo.focusTimeRecords) {
        final progress = _calculateProgress(record, timeIndex, columnIndex);

        if (progress > maxProgress) {
          maxProgress = progress;
          resultColor = todo.color.withOpacity(0.7);
          selectedTodo = todo;
          selectedRecord = record;
        }
      }
    }

    if (maxProgress > 0 && resultColor != null && selectedTodo != null && selectedRecord != null) {
      return CellProgressData(
        progress: maxProgress,
        color: resultColor,
        todo: selectedTodo,
        focusRecord: selectedRecord
      );
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

    // 실제 기록의 날짜를 기준으로 슬롯 시간 계산
    final recordDate = record.startTime;
    final slotStart = DateTime(
      recordDate.year,
      recordDate.month,
      recordDate.day,
      targetHour,
      targetMinute,
    );
    final slotEnd = slotStart.add(Duration(minutes: 10));

    // 집중 시간과 슬롯의 겹치는 부분 계산
    final overlapStart = _laterTime(record.startTime, slotStart);
    final overlapEnd = _earlierTime(record.endTime, slotEnd);

    if (overlapStart.isBefore(overlapEnd)) {
      final overlapMinutes = overlapEnd.difference(overlapStart).inMinutes;
      return (overlapMinutes / 10.0).clamp(0.0, 1.0);
    }

    return 0.0;
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
      return index == 18 ? 0 : index - 17; // 12시는 0(자정), 1~5는 1~5
    }
    return -1;
  }

  // 집중 기록 정보를 보여주는 다이얼로그
  void _showFocusRecordDialog(TodoItemVo todo, FocusTimeRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              Text(
                '설명: ${todo.description}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
  final double progress; // 0.0 ~ 1.0
  final Color color;
  final TodoItemVo? todo;
  final FocusTimeRecord? focusRecord;

  CellProgressData({
    required this.progress,
    required this.color,
    this.todo,
    this.focusRecord,
  });
}
