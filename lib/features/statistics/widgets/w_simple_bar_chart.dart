import 'package:flutter/material.dart';

class SimpleBarChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final double maxValue;
  final Color barColor;
  final String unit;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.labels,
    required this.maxValue,
    this.barColor = Colors.blue,
    this.unit = '분',
  });

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 그리드 라인
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  maxValue: widget.maxValue,
                  unit: widget.unit,
                ),
              ),
            ),
            // 막대 차트
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.data.length, (index) {
                final value = widget.data[index];
                final label = widget.labels[index];
                final barHeight =
                    (value / widget.maxValue) * (constraints.maxHeight - 30);
                final isSelected = _selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = isSelected ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 값 표시
                          SizedBox(
                            height: constraints.maxHeight - 30,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // 막대
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? widget.barColor.withOpacity(0.7)
                                          : widget.barColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                // 툴팁
                                if (isSelected)
                                  Positioned(
                                    bottom: barHeight + 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${value.toInt()}${widget.unit}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 라벨
                          SizedBox(
                            height: 20,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double maxValue;
  final String unit;

  _GridPainter({required this.maxValue, required this.unit});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 5개의 가로선 그리기
    for (int i = 0; i <= 4; i++) {
      final y = (size.height - 30) * (1 - i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      // Y축 레이블
      final value = (maxValue * i / 4).toInt();
      textPainter.text = TextSpan(
        text: '$value$unit',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 9,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-35, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
