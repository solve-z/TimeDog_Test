import 'package:flutter/material.dart';

class TooltipBubble extends StatelessWidget {
  final DateTime date;
  final int minutes;

  const TooltipBubble({
    super.key,
    required this.date,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 말풍선 본체
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${date.year}. ${date.month}. ${date.day}.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // 아래 삼각형 화살표
        CustomPaint(
          size: const Size(16, 8),
          painter: _TrianglePainter(),
        ),
      ],
    );
  }
}

// 삼각형 화살표 그리기
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // 아래 중앙 (뾰족한 부분)
      ..lineTo(0, 0) // 왼쪽 위
      ..lineTo(size.width, 0) // 오른쪽 위
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}