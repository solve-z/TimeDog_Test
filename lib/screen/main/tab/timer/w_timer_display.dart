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

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // 타이머 표시 (모드, 타이머)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

              const SizedBox(width: 12),

              // 중앙: 타이머 표시
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TimerSettingsDialog(),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final fontSize = screenWidth > 600 ? 90.0 : 80.0;
                    final charWidth = screenWidth > 600 ? 50.0 : 38.0;
                    final spacing = screenWidth > 600 ? 8.0 : 5.0;

                    final chars = timerState.formattedTime
                        .replaceAll(' ', '')
                        .split('');
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < chars.length; i++) ...[
                          SizedBox(
                            width: charWidth,
                            child: Text(
                              chars[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          if (i < chars.length - 1) SizedBox(width: spacing),
                        ],
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // 오른쪽: 빈 공간 (밸런스용 - 클릭하면 디버그 정보)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => _TimerDebugDialog(timerState: timerState),
                  );
                },
                child: const SizedBox(
                  width: 52, // 28 + (12 * 2) padding
                  height: 52,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 디버그 정보 모달
class _TimerDebugDialog extends StatelessWidget {
  final TimerState timerState;

  const _TimerDebugDialog({required this.timerState});

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Timer Debug Info',
        style: TextStyle(fontFamily: 'OmyuPretty', fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (timerState.startTime != null) ...[
            Text(
              '시작: ${_formatTime(timerState.startTime!)}',
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (timerState.endTime != null) ...[
            Text(
              '종료: ${_formatTime(timerState.endTime!)}',
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (timerState.startTime != null && timerState.endTime != null) ...[
            Text(
              '소요: ${_formatDuration(timerState.endTime!.difference(timerState.startTime!))}',
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (timerState.startTime == null && timerState.endTime == null)
            const Text(
              '타이머 정보 없음',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기', style: TextStyle(fontFamily: 'OmyuPretty')),
        ),
      ],
    );
  }
}
