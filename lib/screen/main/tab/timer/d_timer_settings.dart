import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class TimerSettingsDialog extends ConsumerStatefulWidget {
  const TimerSettingsDialog({super.key});

  @override
  ConsumerState<TimerSettingsDialog> createState() => _TimerSettingsDialogState();
}

class _TimerSettingsDialogState extends ConsumerState<TimerSettingsDialog> {
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '타이머 설정',
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSettingItem('총 라운드 수', totalRounds, 1, 10, (value) {
                  setState(() => totalRounds = value);
                }),
                const SizedBox(height: 20),

                _buildSettingItem('집중 시간', focusMinutes, 5, 60, (value) {
                  setState(() => focusMinutes = value);
                }, unit: '분'),
                const SizedBox(height: 20),

                _buildSettingItem('짧은 휴식', shortBreakMinutes, 1, 30, (value) {
                  setState(() => shortBreakMinutes = value);
                }, unit: '분'),
                const SizedBox(height: 20),

                _buildSettingItem('긴 휴식', longBreakMinutes, 5, 60, (value) {
                  setState(() => longBreakMinutes = value);
                }, unit: '분'),
                const SizedBox(height: 20),

                // 테스트용 5초 설정 버튼
                Container(
                  width: double.infinity,
                  child: _buildActionButton(
                    _isTestMode() ? '기본값으로 복원' : '테스트용 5초 설정',
                    _setTestMode,
                    isPrimary: false,
                    isTest: true,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('취소', () => Navigator.of(context).pop()),
                    _buildActionButton('저장', _saveSettings, isPrimary: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged, {
    String unit = '',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: value > min ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: value > min ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  '$value$unit',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: value < max ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: value < max ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isPrimary = false, bool isTest = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isTest
              ? const Color(0xFFFEF3C7)
              : isPrimary
                  ? const Color(0xFFD9B5FF)
                  : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(25),
          border: isTest ? Border.all(color: const Color(0xFFF59E0B), width: 1) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isTest
                ? const Color(0xFFF59E0B)
                : isPrimary
                    ? Colors.white
                    : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  bool _isTestMode() {
    final currentSettings = ref.read(timerProvider).settings;
    return currentSettings.totalRounds == 2 &&
           currentSettings.focusTime.inSeconds == 5 &&
           currentSettings.shortBreakTime.inSeconds == 5 &&
           currentSettings.longBreakTime.inSeconds == 5;
  }

  void _setTestMode() {
    // 현재 테스트 모드인지 확인
    if (_isTestMode()) {
      // 이미 테스트 모드라면 기본값으로 복원
      _setDefaultSettings();
      return;
    }

    setState(() {
      totalRounds = 2;
      focusMinutes = 0; // 5초는 분으로 표현할 수 없으므로 0으로 설정
      shortBreakMinutes = 0;
      longBreakMinutes = 0;
    });

    // 5초 설정으로 바로 저장
    final newSettings = TimerSettings(
      totalRounds: 2,
      focusTime: const Duration(seconds: 5),
      shortBreakTime: const Duration(seconds: 5),
      longBreakTime: const Duration(seconds: 5),
    );

    ref.read(timerProvider.notifier).updateSettings(newSettings);

    // 설정 완료 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '테스트용 5초 타이머로 설정되었습니다!',
          style: TextStyle(fontFamily: 'OmyuPretty'),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );

    Navigator.of(context).pop();
  }

  void _setDefaultSettings() {
    setState(() {
      totalRounds = 4;
      focusMinutes = 25;
      shortBreakMinutes = 5;
      longBreakMinutes = 15;
    });

    // 기본값으로 저장
    const defaultSettings = TimerSettings(
      totalRounds: 4,
      focusTime: Duration(minutes: 25),
      shortBreakTime: Duration(minutes: 5),
      longBreakTime: Duration(minutes: 15),
    );

    ref.read(timerProvider.notifier).updateSettings(defaultSettings);

    // 기본값 복원 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '기본 설정으로 복원되었습니다!',
          style: TextStyle(fontFamily: 'OmyuPretty'),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF059669),
      ),
    );

    Navigator.of(context).pop();
  }

  void _saveSettings() {
    final newSettings = TimerSettings(
      totalRounds: totalRounds,
      focusTime: Duration(minutes: focusMinutes),
      shortBreakTime: Duration(minutes: shortBreakMinutes),
      longBreakTime: Duration(minutes: longBreakMinutes),
    );

    ref.read(timerProvider.notifier).updateSettings(newSettings);
    Navigator.of(context).pop();
  }
}