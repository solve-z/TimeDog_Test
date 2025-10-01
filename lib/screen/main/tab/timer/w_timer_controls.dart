import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class TimerControlsWidget extends ConsumerWidget {
  const TimerControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 초기상태(stopped): play만
          if (timerState.status == TimerStatus.stopped) ...[
            _buildControlButton(
              'assets/images/icons/play.svg',
              () => timerNotifier.start(),
              '시작',
            ),
          ]
          // 시작상태(running): pause만
          else if (timerState.status == TimerStatus.running) ...[
            _buildControlButton(
              'assets/images/icons/pause.svg',
              () => timerNotifier.pause(),
              '일시정지',
            ),
          ]
          // 일시정지상태(paused): play, rotate, x
          else if (timerState.status == TimerStatus.paused) ...[
            _buildControlButton(
              'assets/images/icons/play.svg',
              () => timerNotifier.start(),
              '시작',
            ),
            _buildControlButton(
              'assets/images/icons/rotate.svg',
              () => timerNotifier.stop(),
              '재시작',
            ),
            _buildControlButton(
              'assets/images/icons/x.svg',
              () => timerNotifier.reset(),
              '종료',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 38,
            height: 38,
            colorFilter: const ColorFilter.mode(
              Color(0xFF666666),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
