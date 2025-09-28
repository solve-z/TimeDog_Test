import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class ProgressIndicatorWidget extends ConsumerWidget {
  const ProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    // 포모도로 모드가 아니면 표시하지 않음
    if (timerState.mode != TimerMode.pomodoro) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: timerState.roundProgress
          .asMap()
          .entries
          .map(
            (entry) => [
              if (entry.key > 0) const SizedBox(width: 12),
              _buildProgressCircle(entry.value),
            ],
          )
          .expand((widgets) => widgets)
          .toList(),
    );
  }

  Widget _buildProgressCircle(bool isCompleted) {
    return SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.asset(
        isCompleted
            ? 'assets/images/icons/check_circle.svg'
            : 'assets/images/icons/circle.svg',
        width: 24,
        height: 24,
      ),
    );
  }
}