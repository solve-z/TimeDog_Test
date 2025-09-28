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
          _buildControlButton(
            timerState.status == TimerStatus.running
                ? 'assets/images/icons/pause.svg'
                : 'assets/images/icons/play.svg',
            () {
              if (timerState.status == TimerStatus.running) {
                timerNotifier.pause();
              } else {
                timerNotifier.start();
              }
            },
            timerState.status == TimerStatus.running ? '일시정지' : '시작',
          ),
          const SizedBox(width: 30),
          if (timerState.mode == TimerMode.pomodoro) ...[
            _buildControlButton(
              'assets/images/icons/x.svg',
              () => timerNotifier.stop(),
              '중지',
            ),
            const SizedBox(width: 30),
          ],
          _buildControlButton(
            'assets/images/icons/rotate.svg',
            () => timerNotifier.reset(),
            '리셋',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(35),
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
            width: 32,
            height: 32,
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