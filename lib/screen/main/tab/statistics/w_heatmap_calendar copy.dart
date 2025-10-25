import 'package:flutter/material.dart';

class HeatmapCalendar extends StatefulWidget {
  final int year;
  final Map<DateTime, int> data; // 날짜별 집중시간(분)
  final Function(DateTime)? onDayTap;

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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gridWidth = 7 * 28.0;
        const monthLabelWidth = 42.0;
        final totalContentWidth = monthLabelWidth + 12 + gridWidth;
        final leftPadding = (constraints.maxWidth - totalContentWidth) / 2 - 8;
        final rightPadding = (constraints.maxWidth - totalContentWidth) / 2;

        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: leftPadding.clamp(16.0, double.infinity)),
              _buildMonthLabelsWithGrid(),
              SizedBox(width: rightPadding.clamp(16.0, double.infinity)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthLabelsWithGrid() {
    // 1년 전체를 주 단위로 계산 (12월 31일부터 역순)
    final rows = <Widget>[];

    // 12월 31일부터 시작
    DateTime currentDate = DateTime(widget.year, 12, 31);

    // 12월 31일이 속한 주의 일요일 찾기
    final lastDayWeekday = currentDate.weekday % 7;
    DateTime weekStart = currentDate.subtract(Duration(days: lastDayWeekday));

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
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월 라벨 영역
          SizedBox(
            width: 42,
            child:
                monthLabel != null
                    ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          monthLabel,
                          style: TextStyle(
                            fontSize: 12,
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
              return GestureDetector(
                onTap: () => widget.onDayTap?.call(date),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: _getColor(minutes),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            } else {
              return Container(
                width: 24,
                height: 24,
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
        const SizedBox(width: 42), // 월 라벨 영역
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
            width: 24,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 4),
            child: Text(day, style: TextStyle(fontSize: 11, color: dayColor)),
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
