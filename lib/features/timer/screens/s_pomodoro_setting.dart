import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/dialogs/d_number_picker.dart';
import 'package:timedog_test/common/widgets/w_common_app_bar.dart';
import 'package:timedog_test/features/timer/providers/timer_notifier.dart';
import 'package:timedog_test/features/timer/models/vo_timer.dart';

class PomodoroSettingScreen extends ConsumerStatefulWidget {
  const PomodoroSettingScreen({super.key});

  @override
  ConsumerState<PomodoroSettingScreen> createState() =>
      _PomodoroSettingScreenState();
}

class _PomodoroSettingScreenState extends ConsumerState<PomodoroSettingScreen> {
  late int totalRounds;
  late int focusMinutes;
  late int shortBreakMinutes;
  late int longBreakMinutes;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(timerProvider).settings;
    totalRounds = settings.totalRounds;
    focusMinutes = settings.focusTime.inMinutes;
    shortBreakMinutes = settings.shortBreakTime.inMinutes;
    longBreakMinutes = settings.longBreakTime.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: '뽀모도로 설정'),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('뽀모도로 타이머'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimerBox(
                        '집중 시간',
                        focusMinutes,
                        '분',
                        () async {
                          final result = await showDialog(
                            context: context,
                            builder:
                                (context) => NumberPickerDialog(
                                  title: '집중 시간',
                                  currentValue: focusMinutes,
                                  minValue: 1,
                                  maxValue: 60,
                                  unit: '분',
                                ),
                          );
                          // 숫자 입력 창에서 취소를 안눌렀다면
                          if (result != null) {
                            setState(() {
                              focusMinutes = result;
                            });
                            _updateTimerSettings();
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimerBox(
                        '짧은 휴식',
                        shortBreakMinutes,
                        '분',
                        () async {
                          final result = await showDialog(
                            context: context,
                            builder:
                                (context) => NumberPickerDialog(
                                  title: '짧은 휴식',
                                  currentValue: shortBreakMinutes,
                                  minValue: 1,
                                  maxValue: 30,
                                  unit: '분',
                                ),
                          );
                          // 숫자 입력 창에서 취소를 안눌렀다면
                          if (result != null) {
                            setState(() {
                              shortBreakMinutes = result;
                            });
                            _updateTimerSettings();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimerBox(
                        '긴 휴식',
                        longBreakMinutes,
                        '분',
                        () async {
                          final result = await showDialog(
                            context: context,
                            builder:
                                (context) => NumberPickerDialog(
                                  title: '긴 휴식',
                                  currentValue: longBreakMinutes,
                                  minValue: 1,
                                  maxValue: 60,
                                  unit: '분',
                                ),
                          );
                          // 숫자 입력 창에서 취소를 안눌렀다면
                          if (result != null) {
                            setState(() {
                              longBreakMinutes = result;
                            });
                            _updateTimerSettings();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimerBox('라운드', totalRounds, '회', () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder:
                              (context) => NumberPickerDialog(
                                title: '라운드',
                                currentValue: totalRounds,
                                minValue: 1,
                                maxValue: 10,
                                unit: '회',
                              ),
                        );
                        if (result != null) {
                          setState(() {
                            totalRounds = result;
                          });
                          _updateTimerSettings();
                        }
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'OmyuPretty',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildTimerBox(
    String label,
    int value,
    String unit,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value$unit',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTimerSettings() {
    final newSettings = TimerSettings(
      totalRounds: totalRounds,
      focusTime: Duration(minutes: focusMinutes),
      shortBreakTime: Duration(minutes: shortBreakMinutes),
      longBreakTime: Duration(minutes: longBreakMinutes),
    );

    ref.read(timerProvider.notifier).updateSettings(newSettings);
  }
}
