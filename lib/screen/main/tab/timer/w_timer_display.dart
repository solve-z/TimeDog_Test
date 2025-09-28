import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';
import 'd_timer_settings.dart';

class TimerDisplayWidget extends ConsumerWidget {
  const TimerDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Column(
      children: [
        // 타이머 표시 (모드, 타이머)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 모드 선택
              GestureDetector(
                onTap: () => timerNotifier.toggleMode(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    timerState.mode == TimerMode.pomodoro
                        ? 'assets/images/icons/pomodoro.svg'
                        : 'assets/images/icons/stopwatch.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF6B7280),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // 중앙: 타이머 표시
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TimerSettingsDialog(),
                  );
                },
                child: Text(
                  timerState.formattedTime,
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B7280),
                    letterSpacing: 4,
                  ),
                ),
              ),

              // 오른쪽: 빈 공간 (균형을 위한 Spacer)
              const SizedBox(width: 52), // 모드 선택 버튼과 동일한 너비
            ],
          ),
        ),

        // 타이머 상태 정보
        Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                if (timerState.startTime != null &&
                    timerState.status == TimerStatus.running)
                  Text(
                    '시작: ${_formatTime(timerState.startTime!)}',
                    style: const TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                if (timerState.endTime != null &&
                    timerState.status == TimerStatus.paused)
                  Column(
                    children: [
                      if (timerState.startTime != null) ...[
                        Text(
                          '시작: ${_formatTime(timerState.startTime!)}',
                          style: const TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '종료: ${_formatTime(timerState.endTime!)}',
                          style: const TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '소요: ${_formatDuration(timerState.endTime!.difference(timerState.startTime!))}',
                          style: const TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 12,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}