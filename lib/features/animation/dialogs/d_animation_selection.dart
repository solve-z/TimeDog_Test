import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimationSelectionDialog extends StatefulWidget {
  final String title;
  final String? currentSelection;
  final List<AnimationOption> animations;

  const AnimationSelectionDialog({
    super.key,
    required this.title,
    this.currentSelection,
    required this.animations,
  });

  @override
  State<AnimationSelectionDialog> createState() =>
      _AnimationSelectionDialogState();
}

class _AnimationSelectionDialogState extends State<AnimationSelectionDialog> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<String, VideoPlayerController?> _controllers = {};

  @override
  void initState() {
    super.initState();
    // 현재 선택된 항목이 있으면 해당 페이지로 이동
    if (widget.currentSelection != null) {
      final index = widget.animations.indexWhere(
        (anim) => anim.id == widget.currentSelection,
      );
      _currentPage = index != -1 ? index : 0;
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 모든 비디오 컨트롤러 정리
    for (var controller in _controllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // 타이틀
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 12),

            // 상태 표시 (선택됨, 비어있는영역, 잠금표시)
            _buildStatusIndicator(),

            const SizedBox(height: 20),

            // PageView로 좌우 스와이프
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.animations.length,
                itemBuilder: (context, index) {
                  final animation = widget.animations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child:
                                animation.thumbnailPath != null
                                    ? Image.asset(
                                      animation.thumbnailPath!,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(
                                      Icons.pets,
                                      size: 80,
                                      color: Color(0xFFD1D5DB),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 페이지 인디케이터 (점)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.animations.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? const Color(0xFFD9B5FF)
                            : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 선택 버튼
            GestureDetector(
              onTap: () {
                Navigator.pop(context, widget.animations[_currentPage].id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '선택',
                  style: TextStyle(
                    fontFamily: 'OmyuPretty',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final currentAnimation = widget.animations[_currentPage];
    final status = currentAnimation.status;

    Widget statusWidget;

    switch (status) {
      case AnimationSelectionStatus.selected:
        // 선택됨 - 체크 아이콘
        statusWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
            SizedBox(width: 4),
            Text(
              '선택됨',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        );
        break;

      case AnimationSelectionStatus.locked:
        // 잠금 - 자물쇠 아이콘
        statusWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, color: Color(0xFF9CA3AF), size: 16),
            SizedBox(width: 4),
            Text(
              '잠금',
              style: TextStyle(
                fontFamily: 'OmyuPretty',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        );
        break;

      case AnimationSelectionStatus.empty:
        // 비어있음 - 빈 공간
        statusWidget = const SizedBox(height: 20);
        break;
    }

    return SizedBox(height: 20, child: statusWidget);
  }

  Widget _buildVideoThumbnail(String videoPath) {
    // 비디오 컨트롤러가 없으면 생성
    if (!_controllers.containsKey(videoPath)) {
      final controller = VideoPlayerController.asset(videoPath)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      _controllers[videoPath] = controller;
    }

    final controller = _controllers[videoPath];

    if (controller != null && controller.value.isInitialized) {
      return VideoPlayer(controller);
    } else {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFD9B5FF),
        ),
      );
    }
  }
}

// 애니메이션 옵션 모델
class AnimationOption {
  final String id;
  final String name;
  final String? videoPath;
  final String? thumbnailPath; // 썸네일 이미지 경로
  final AnimationSelectionStatus status;

  const AnimationOption({
    required this.id,
    required this.name,
    this.videoPath,
    this.thumbnailPath,
    this.status = AnimationSelectionStatus.empty, // 기본값: 비어있음
  });
}

enum AnimationSelectionStatus {
  selected, // 선택됨
  empty, // 비어있음
  locked, // 잠김
}
