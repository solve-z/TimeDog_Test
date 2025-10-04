import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';
import 'video_controller_provider.dart';
import 'animation_provider.dart';

class CharacterAnimationFragment extends ConsumerStatefulWidget {
  const CharacterAnimationFragment({super.key});

  @override
  ConsumerState<CharacterAnimationFragment> createState() =>
      _CharacterAnimationFragmentState();
}

class _CharacterAnimationFragmentState
    extends ConsumerState<CharacterAnimationFragment> {
  TimerStatus? _previousStatus;
  PomodoroRound? _previousRound;
  String? _previousFocusAnimation;
  String? _previousBreakAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // 컨트롤러 초기화 완료 대기
  Future<void> _initializeVideo() async {
    final controller = ref.read(videoControllerProvider);

    if (controller == null) {
      // 비디오 컨트롤러가 아직 준비되지 않았으면 100ms 후 재시도
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _initializeVideo();
      }
      return;
    }

    // 초기화 완료될 때까지 대기 (Provider에서 이미 초기화 시작됨)
    if (!controller.value.isInitialized) {
      // 초기화 완료를 감지하기 위해 리스너 추가
      void listener() {
        if (controller.value.isInitialized && mounted) {
          controller.removeListener(listener);
          setState(() {
            _isInitialized = true;
          });
          _checkTimerStatus();
        }
      }

      controller.addListener(listener);
    } else {
      // 이미 초기화 완료된 경우
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _checkTimerStatus();
      }
    }
  }

  void _checkTimerStatus() {
    final timerState = ref.read(timerProvider);
    final controller = ref.read(videoControllerProvider);

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    // 타이머 상태와 비디오 재생 상태 동기화
    switch (timerState.status) {
      case TimerStatus.running:
        if (!controller.value.isPlaying) {
          controller.play();
        }
        break;
      case TimerStatus.paused:
        if (controller.value.isPlaying) {
          controller.pause();
        }
        break;
      case TimerStatus.stopped:
        controller.pause();
        controller.seekTo(Duration.zero);
        break;
    }

    _previousStatus = timerState.status;
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final animationSelection = ref.watch(animationProvider);
    final controller = ref.watch(videoControllerProvider);

    // 애니메이션 선택이나 타이머 라운드가 변경되었는지 확인
    final focusChanged =
        _previousFocusAnimation != animationSelection.focusAnimationId;
    final breakChanged =
        _previousBreakAnimation != animationSelection.breakAnimationId;
    final roundChanged = _previousRound != timerState.round;

    // build 완료 직후 타이머 상태와 비디오 상태 동기화
    // (다른 화면에서 돌아왔을 때 비디오 재생 상태 복원)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousStatus != timerState.status) {
        _checkTimerStatus();
      }

      // 애니메이션 선택이 변경되었거나 라운드가 변경되면 비디오 갱신
      if (focusChanged || breakChanged || roundChanged) {
        _previousFocusAnimation = animationSelection.focusAnimationId;
        _previousBreakAnimation = animationSelection.breakAnimationId;
        _previousRound = timerState.round;

        // 비디오 컨트롤러 업데이트
        ref.read(videoControllerProvider.notifier).updateVideo();
        _isInitialized = false;
        _initializeVideo();
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth > 600 ? 300.0 : 240.0;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            controller != null &&
                    _isInitialized &&
                    controller.value.isInitialized
                ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
                : Center(
                  // 로딩 중에는 플레이스홀더 이미지 표시 (회색 화면 대신)
                  child: Image.asset(
                    'assets/images/animations/drawing_white_Thum.jpg',
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  ),
                ),
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러는 Provider가 관리하므로 여기서 dispose 안 함
    super.dispose();
  }
}
