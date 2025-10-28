import 'package:flutter/material.dart';

class HeatmapCalendar extends StatefulWidget {
  final int year;
  final Map<DateTime, int> data; //날짜별 집중시간(분)
  final Function(DateTime date, int minutes, Offset position)? onDayTap;

  const HeatmapCalendar({
    super.key,
    required this.year,
    required this.data,
    this.onDayTap,
  });

  @override
  State<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends State<HeatmapCalendar> {
  final GlobalKey _containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gridWidth = 7 * 30.0;
        const monthLabelWidth = 32.0;
        final totalContentWidth = monthLabelWidth + gridWidth;
        final leftPadding = (constraints.maxWidth - totalContentWidth) / 2;

        return Row(
          key: _containerKey,
          children: [
            SizedBox(width: leftPadding.clamp(16.0, double.infinity)),
            _buildMonthLabelsWithGrid(),
            SizedBox(width: leftPadding.clamp(16.0, double.infinity)),
          ],
        );
      },
    );
  }

  Widget _buildMonthLabelsWithGrid() {
    // 현재 날짜가 포함된 주까지만 표시 (역순)
    final rows = <Widget>[];

    // 현재 날짜 (또는 해당 연도의 마지막 날)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 현재 연도가 선택된 연도보다 크면 12월 31일까지, 같으면 오늘까지
    DateTime endDate;
    if (today.year > widget.year) {
      endDate = DateTime(widget.year, 12, 31);
    } else if (today.year == widget.year) {
      endDate = today;
    } else {
      // 미래 연도면 아무것도 표시 안함
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SizedBox(height: 8)],
      );
    }

    // endDate가 속한 주의 일요일 찾기
    final endDayWeekday = endDate.weekday % 7;
    DateTime weekStart = endDate.subtract(Duration(days: endDayWeekday));

    // 1월 1일
    final firstDayOfYear = DateTime(widget.year, 1, 1);

    // 1월 1일이 속한 주의 일요일까지 반복
    while (weekStart.year >= widget.year ||
        weekStart.isBefore(firstDayOfYear.add(const Duration(days: 7)))) {
      // 이 주에 해당 월의 1일이 있는지 확인
      String? monthLabel;
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (date.year == widget.year && date.day == 1) {
          monthLabel = '${date.month}월';
          break;
        }
      }

      rows.add(_buildWeekRow(weekStart, monthLabel));

      weekStart = weekStart.subtract(const Duration(days: 7));

      if (weekStart.year < widget.year &&
          weekStart.add(const Duration(days: 6)).year < widget.year) {
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekdayLabels(),
        const SizedBox(height: 8),
        Column(children: rows),
      ],
    );
  }

  Widget _buildWeekRow(DateTime weekStart, String? monthLabel) {
    return SizedBox(
      height: 30, // 그리드 위아래 간격 조절
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월 라벨 영역
          SizedBox(
            width: 28,
            height: 26,
            child:
                monthLabel != null
                    ? Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          monthLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
          ),
          // 7개 요일 셀
          ...List.generate(7, (i) {
            final date = weekStart.add(Duration(days: i));
            final isInYear = date.year == widget.year;

            if (isInYear) {
              final minutes = widget.data[date] ?? 0;
              final cellKey = GlobalKey();

              return GestureDetector(
                key: cellKey,
                onTap: () {
                  final cellBox =
                      cellKey.currentContext?.findRenderObject() as RenderBox?;
                  final containerBox =
                      _containerKey.currentContext?.findRenderObject()
                          as RenderBox?;

                  if (cellBox != null && containerBox != null) {
                    // 셀과 컨테이너의 전역 좌표
                    final cellGlobal = cellBox.localToGlobal(Offset.zero);
                    final containerGlobal = containerBox.localToGlobal(
                      Offset.zero,
                    );

                    // 컨테이너 기준 상대 좌표 (Stack에서 사용)
                    final relativeX = cellGlobal.dx - containerGlobal.dx;
                    final relativeY = cellGlobal.dy - containerGlobal.dy;

                    // 셀 상단 중앙 (셀 너비 26의 중앙 = +13)
                    final cellTopCenter = Offset(relativeX + 13, relativeY);

                    widget.onDayTap?.call(date, minutes, cellTopCenter);
                  }
                },
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: _getColor(minutes),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            } else {
              return Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 4),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: [
        const SizedBox(width: 28), // 월 라벨 영역과 동일
        ...List.generate(weekdays.length, (index) {
          final day = weekdays[index];
          Color dayColor;

          if (index == 0) {
            dayColor = Colors.red; // 일요일
          } else if (index == 6) {
            dayColor = Colors.blue; // 토요일
          } else {
            dayColor = Colors.grey[600]!;
          }

          return Container(
            width: 26, // 셀과 동일한 너비
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 4), // 셀과 동일한 margin
            child: Text(
              day,
              style: TextStyle(
                fontSize: 11,
                color: dayColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getColor(int minutes) {
    if (minutes == 0) return Colors.grey[200]!;
    if (minutes <= 120) return Colors.green[200]!; // 0~2시간
    if (minutes <= 360) return Colors.green[400]!; // 3~6시간
    if (minutes <= 600) return Colors.green[600]!; // 7~10시간
    return Colors.green[800]!; // 10시간+
  }
}
