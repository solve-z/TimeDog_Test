import 'package:flutter/material.dart';
import 'f_character_animation.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 할일
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Text(
            '영어단어 외우기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),

        // 타이머&스톱워치
        Column(
          children: [
            const Text(
              '21:00',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '00:00:00',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),

        // 캐릭터 애니메이션 영역
        const CharacterAnimationFragment(),
        const Spacer(),

        // 액션버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.hourglass_empty),
              iconSize: 32,
              tooltip: '모래시계',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              iconSize: 32,
              tooltip: '시작',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              iconSize: 32,
              tooltip: '리셋',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close),
              iconSize: 32,
              tooltip: '취소',
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
