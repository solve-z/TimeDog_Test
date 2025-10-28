import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/widgets/w_common_app_bar.dart';
import 'package:timedog_test/features/animation/providers/animation_provider.dart';
import 'package:timedog_test/features/animation/dialogs/d_animation_selection.dart';

class AnimationSettingsScreen extends ConsumerStatefulWidget {
  const AnimationSettingsScreen({super.key});

  @override
  ConsumerState<AnimationSettingsScreen> createState() =>
      _AnimationSettingsScreenState();
}

class _AnimationSettingsScreenState
    extends ConsumerState<AnimationSettingsScreen> {
  String? focusAnimationSelection;
  String? breakAnimationSelection;
  String? focusAnimationSelectionThum;
  String? breakAnimationSelectionThum;

  // 애니메이션 옵션 리스트
  static const List<AnimationOption> focusAnimations = [
    AnimationOption(
      id: 'drawing_white',
      name: '그림 그리기',
      videoPath: 'assets/videos/focus_animations/drawing_white.mp4',
      thumbnailPath: 'assets/images/animations/drawing_white_Thum.jpg',
      status: AnimationSelectionStatus.selected,
    ),
    AnimationOption(
      id: 'cooking_white',
      name: '요리하기',
      videoPath: 'assets/videos/focus_animations/cook_white.mp4',
      thumbnailPath: 'assets/images/animations/cook_white_Thum.jpg',
      status: AnimationSelectionStatus.empty,
    ),
    AnimationOption(
      id: 'reading',
      name: '독서하기',
      videoPath: null,
      thumbnailPath: null,
      status: AnimationSelectionStatus.locked,
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
    // 저장된 애니메이션 설정 로드
    final animationSelection = ref.read(animationProvider);
    focusAnimationSelection = animationSelection.focusAnimationId;
    breakAnimationSelection = animationSelection.breakAnimationId;
  }

  @override
  Widget build(BuildContext context) {
    final animationsSelectionWatch = ref.watch(animationProvider);

    focusAnimationSelectionThum = animationsSelectionWatch.getFocusThumPath();
    breakAnimationSelectionThum = animationsSelectionWatch.getBreakThumPath();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: '애니메이션 설정'),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
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
                          final result = await showDialog(
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
                const SizedBox(height: 24),
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

  Widget _buildAnimationCard(
    String label,
    String? selection,
    String? placeHolderImage,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // 캐릭터 이미지 플레이스 홀더
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  placeHolderImage != null
                      ? Image.asset(placeHolderImage, fit: BoxFit.cover)
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
}
