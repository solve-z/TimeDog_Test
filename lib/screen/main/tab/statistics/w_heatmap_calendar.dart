import 'package:flutter/material.dart';
import 'w_tooltip_bubble.dart';

class HeatmapCalendar extends StatefulWidget {
  final int year;
  final Map<DateTime, int> data; //날짜별 집중시간(분)
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
  DateTime? _selectedDate;
  Offset? _tooltipPosition;
  final GlobalKey _tooltipKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gridWidth = 7 * 30.0;
        const monthLabelWidth = 32.0;
        final totalContentWidth = monthLabelWidth + gridWidth;
        final leftPadding = (constraints.maxWidth - totalContentWidth) / 2;

        return GestureDetector(
          onTap: () {
            // 외부 탭 시 말풍선 닫기
            if (_selectedDate != null) {
              setState(() {
                _selectedDate = null;
                _tooltipPosition = null;
              });
            }
          },
          child: Stack(
            key: _stackKey,
            children: [
              // 캘린더 본체
              Row(
                children: [
                  SizedBox(width: leftPadding.clamp(16.0, double.infinity)),
                  _buildMonthLabelsWithGrid(),
                  SizedBox(width: leftPadding.clamp(16.0, double.infinity)),
                ],
              ),
              // 말풍선 오버레이
              if (_selectedDate != null && _tooltipPosition != null)
                Positioned(
                  left: _tooltipPosition!.dx,
                  top: _tooltipPosition!.dy - 60, // 말풍선 높이 + 여백
                  child: FractionalTranslation(
                    translation: const Offset(
                      -0.5,
                      0,
                    ), // 자신의 너비 절반만큼 왼쪽으로 (중앙 정렬)
                    child: TooltipBubble(
                      key: _tooltipKey,
                      date: _selectedDate!,
                      minutes: widget.data[_selectedDate] ?? 0,
                    ),
                  ),
                ),
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
      children: [const SizedBox(height: 8), Column(children: rows)],
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
                  final stackBox =
                      _stackKey.currentContext?.findRenderObject()
                          as RenderBox?;

                  if (cellBox != null && stackBox != null) {
                    // 스크롤 시에도 정확한 위치를 위해 매번 재계산
                    final cellGlobal = cellBox.localToGlobal(Offset.zero);
                    final stackGlobal = stackBox.localToGlobal(Offset.zero);

                    // Stack 기준 상대 좌표
                    final relativeX = cellGlobal.dx - stackGlobal.dx;
                    final relativeY = cellGlobal.dy - stackGlobal.dy;

                    // 셀 상단 중앙 (셀 너비 26의 중앙 = +13)
                    final cellTopCenter = Offset(relativeX + 13, relativeY);

                    setState(() {
                      _selectedDate = date;
                      _tooltipPosition = cellTopCenter;
                    });
                    widget.onDayTap?.call(date);
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

  Color _getColor(int minutes) {
    if (minutes == 0) return Colors.grey[200]!;
    if (minutes <= 120) return Colors.green[200]!; // 0~2시간
    if (minutes <= 360) return Colors.green[400]!; // 3~6시간
    if (minutes <= 600) return Colors.green[600]!; // 7~10시간
    return Colors.green[800]!; // 10시간+
  }
}
