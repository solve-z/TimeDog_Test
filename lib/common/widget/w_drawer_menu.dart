import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../screen/main/tab/timer/s_timer_settings.dart';
import '../../screen/main/tab/timer/timer_notifier.dart';
import '../../screen/main/tab/timer/vo/vo_timer.dart';
import '../constant/app_constants.dart';

class DrawerMenuWidget extends ConsumerStatefulWidget {
  const DrawerMenuWidget({super.key});

  @override
  ConsumerState<DrawerMenuWidget> createState() => _DrawerMenuWidgetState();
}

class _DrawerMenuWidgetState extends ConsumerState<DrawerMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final isPomodoroMode = timerState.mode == TimerMode.pomodoro;

    // 모드 변경 시 애니메이션 실행
    if (isPomodoroMode) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 60),
                _TimerModeSegment(
                  isPomodoroMode: isPomodoroMode,
                  slideAnimation: _slideAnimation,
                  onToggle: timerNotifier.toggleMode,
                ),
                const Divider(),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/images/icons/setting.svg',
                    width: 36,
                    height: 36,
                  ),
                  title: const Text('타이머 설정'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimerSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// 타이머 모드 세그먼트 위젯
class _TimerModeSegment extends StatelessWidget {
  final bool isPomodoroMode;
  final Animation<double> slideAnimation;
  final VoidCallback onToggle;

  const _TimerModeSegment({
    required this.isPomodoroMode,
    required this.slideAnimation,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '타이머 모드',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0 && !isPomodoroMode) {
                onToggle(); // 스톱워치 -> 뽀모도로
              } else if (details.primaryVelocity! < 0 && isPomodoroMode) {
                onToggle(); // 뽀모도로 -> 스톱워치
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final segmentWidth = constraints.maxWidth / 2;
                  return Stack(
                    children: [
                      // 애니메이션되는 배경
                      AnimatedBuilder(
                        animation: slideAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: slideAnimation.value * segmentWidth,
                            child: Container(
                              width: segmentWidth,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          );
                        },
                      ),
                      // 버튼들
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isPomodoroMode) onToggle();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/icons/timer.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        isPomodoroMode ? Colors.white : const Color(0xFF6B7280),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '뽀모도로',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isPomodoroMode ? Colors.white : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isPomodoroMode) onToggle();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/icons/stopwatch.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        !isPomodoroMode ? Colors.white : const Color(0xFF6B7280),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '스톱워치',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: !isPomodoroMode ? Colors.white : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
