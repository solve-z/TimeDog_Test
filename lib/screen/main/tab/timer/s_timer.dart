import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'f_character_animation.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 모드 및 할일 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => timerNotifier.toggleMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timerState.mode == TimerMode.pomodoro ? '뽀모도로' : '스톱워치',
                        style: const TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  if (timerState.mode == TimerMode.pomodoro)
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 27,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9B5FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timerState.round == PomodoroRound.focus
                              ? '집중 시간'
                              : timerState.round == PomodoroRound.shortBreak
                                  ? '짧은 휴식'
                                  : '긴 휴식',
                          style: const TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 50),
                ],
              ),
              const SizedBox(height: 20),

              // 타이머 표시
              Text(
                timerState.formattedTime,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF6B7280),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),

              // 라운드 진행 상태 (뽀모도로 모드에서만)
              if (timerState.mode == TimerMode.pomodoro)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: timerState.roundProgress
                      .asMap()
                      .entries
                      .map((entry) => [
                            if (entry.key > 0) const SizedBox(width: 12),
                            _buildProgressCircle(entry.value),
                          ])
                      .expand((widgets) => widgets)
                      .toList(),
                ),
              const SizedBox(height: 30),

              // 캐릭터 애니메이션 영역
              const CharacterAnimationFragment(),
              const SizedBox(height: 15),

              // 노래 선택 버튼
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/music.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        '노래 선택',
                        style: TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 컨트롤 버튼들
              Row(
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
                  const SizedBox(width: 20),
                  if (timerState.mode == TimerMode.pomodoro) ...[
                    _buildControlButton(
                      'assets/images/icons/x.svg',
                      () => timerNotifier.stop(),
                      '중지',
                    ),
                    const SizedBox(width: 20),
                  ],
                  _buildControlButton(
                    'assets/images/icons/rotate.svg',
                    () => timerNotifier.reset(),
                    '리셋',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildControlButton(
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
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
