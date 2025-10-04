import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';
import 'd_animation_selection.dart';
import 'animation_provider.dart';
import '../../../../common/dialog/d_number_picker.dart';

class TimerSettingsScreen extends ConsumerStatefulWidget {
  const TimerSettingsScreen({super.key});

  @override
  ConsumerState<TimerSettingsScreen> createState() =>
      _TimerSettingsScreenState();
}

class _TimerSettingsScreenState extends ConsumerState<TimerSettingsScreen> {
  late int totalRounds;
  late int focusMinutes;
  late int shortBreakMinutes;
  late int longBreakMinutes;

  String? focusAnimationSelection;
  String? breakAnimationSelection;
  String? focusAnimationSelectionThum;
  String? breakAnimationSelectionThum;
  String? selectedMusic;

  // 애니메이션 옵션 리스트
  static const List<AnimationOption> focusAnimations = [
    AnimationOption(
      id: 'drawing_white',
      name: '그림 그리기',
      videoPath: 'assets/videos/focus_animations/drawing_white.mp4',
      thumbnailPath: 'assets/images/animations/drawing_white_Thum.jpg',
      status: AnimationSelectionStatus.selected, // 예시: 선택됨
    ),
    AnimationOption(
      id: 'cooking_white',
      name: '요리하기',
      videoPath: 'assets/videos/focus_animations/cook_white.mp4',
      thumbnailPath: 'assets/images/animations/cook_white_Thum.jpg',
      status: AnimationSelectionStatus.empty, // 비어있음
    ),
    AnimationOption(
      id: 'reading',
      name: '독서하기',
      videoPath: null,
      thumbnailPath: null,
      status: AnimationSelectionStatus.locked, // 예시: 잠금
    ),
  ];

  static const List<AnimationOption> breakAnimations = [
    AnimationOption(
      id: 'rest_white',
      name: '휴식하기',
      videoPath: 'assets/videos/rest_animations/rest_white.mp4',
      thumbnailPath: 'assets/images/animations/rest_white_Thum.jpg',
      status: AnimationSelectionStatus.selected,
    ),
    AnimationOption(
      id: 'sleeping',
      name: '휴식',
      videoPath: 'assets/videos/rest_animations/rest_1.mp4',
      thumbnailPath: 'assets/images/animations/rest_1_Thum.jpg',
      status: AnimationSelectionStatus.empty,
    ),
    AnimationOption(
      id: 'playing',
      name: '놀기',
      videoPath: null,
      thumbnailPath: null,
      status: AnimationSelectionStatus.locked,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(timerProvider).settings;
    totalRounds = settings.totalRounds;
    focusMinutes = settings.focusTime.inMinutes;
    shortBreakMinutes = settings.shortBreakTime.inMinutes;
    longBreakMinutes = settings.longBreakTime.inMinutes;

    // 저장된 애니메이션 설정 로드
    final animationSelection = ref.read(animationProvider);
    focusAnimationSelection = animationSelection.focusAnimationId;
    breakAnimationSelection = animationSelection.breakAnimationId;

    // TODO: 저장된 음악 설정 로드
    selectedMusic = null;
  }

  @override
  Widget build(BuildContext context) {
    final animatinosSelectionWatch = ref.watch(animationProvider);

    focusAnimationSelectionThum = animatinosSelectionWatch.getFocusThumPath();
    breakAnimationSelectionThum = animatinosSelectionWatch.getBreakThumPath();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B7280)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 16,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 뽀모도로 타이머 섹션
                _buildSectionTitle('뽀모도로 타이머'),
                const SizedBox(height: 16),
                // 4개의 박스를 한 줄로 배치
                Row(
                  children: [
                    Expanded(
                      child: _buildTimerBox(
                        '집중 시간',
                        focusMinutes,
                        '분',
                        () async {
                          final result = await showDialog<int>(
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
                          final result = await showDialog<int>(
                            context: context,
                            builder:
                                (context) => NumberPickerDialog(
                                  title: '짧은 휴식 시간',
                                  currentValue: shortBreakMinutes,
                                  minValue: 1,
                                  maxValue: 30,
                                  unit: '분',
                                ),
                          );
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
                          final result = await showDialog<int>(
                            context: context,
                            builder:
                                (context) => NumberPickerDialog(
                                  title: '긴 휴식 시간',
                                  currentValue: longBreakMinutes,
                                  minValue: 1,
                                  maxValue: 60,
                                  unit: '분',
                                ),
                          );
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
                  ],
                ),

                const SizedBox(height: 40),

                // 애니메이션 섹션
                _buildSectionTitle('애니메이션'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimationCard(
                        '집중 애니메이션',
                        focusAnimationSelection,
                        focusAnimationSelectionThum,
                        () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder:
                                (context) => AnimationSelectionDialog(
                                  title: '집중 애니메이션 선택',
                                  currentSelection: focusAnimationSelection,
                                  animations: focusAnimations,
                                ),
                          );
                          if (result != null) {
                            setState(() {
                              focusAnimationSelection = result;
                            });
                            // Provider에 저장
                            ref
                                .read(animationProvider.notifier)
                                .setFocusAnimation(result);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAnimationCard(
                        '휴식 애니메이션',
                        breakAnimationSelection,
                        breakAnimationSelectionThum,
                        () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder:
                                (context) => AnimationSelectionDialog(
                                  title: '휴식 애니메이션 선택',
                                  currentSelection: breakAnimationSelection,
                                  animations: breakAnimations,
                                ),
                          );
                          if (result != null) {
                            setState(() {
                              breakAnimationSelection = result;
                            });
                            // Provider에 저장
                            ref
                                .read(animationProvider.notifier)
                                .setBreakAnimation(result);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 노래 섹션
                _buildSectionTitle('노래'),
                const SizedBox(height: 16),
                _buildMusicSelector(),

                const SizedBox(height: 24), // 하단 여백 추가
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'OmyuPretty',
          fontSize: 14,
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
          // color: const Color(0xFFF9FAFB),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value$unit',
              style: const TextStyle(
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

  Widget _buildAnimationCard(
    String label,
    String? selection,
    String? placeholderImage,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          // color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            // 캐릭터 이미지 플레이스홀더
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  placeholderImage != null
                      ? Image.asset(placeholderImage, fit: BoxFit.cover)
                      : const Icon(
                        Icons.pets,
                        size: 48,
                        color: Color(0xFFD1D5DB),
                      ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                _getAnimationName(selection) ?? '선택',
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getAnimationName(String? selectionId) {
    if (selectionId == null) return null;
    final allAnimations = [...focusAnimations, ...breakAnimations];
    final selected = allAnimations.firstWhere(
      (anim) => anim.id == selectionId,
      orElse: () => const AnimationOption(id: '', name: '', videoPath: null),
    );
    return selected.name.isEmpty ? null : selected.name;
  }

  Widget _buildMusicSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedMusic ?? '도서관 소음',
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shuffle,
              color: Color(0xFF6B7280),
              size: 18,
            ),
          ),
        ],
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

  void _saveSettings() {
    _updateTimerSettings();

    // TODO: 애니메이션 및 음악 설정 저장

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '설정이 저장되었습니다',
          style: TextStyle(fontFamily: 'OmyuPretty'),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }
}
