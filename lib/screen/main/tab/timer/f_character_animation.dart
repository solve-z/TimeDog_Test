import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';
import 'video_controller_provider.dart';
import 'animation_provider.dart';
import '../../../../common/utils/app_logger.dart';

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
  VoidCallback? _playbackListener;

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
      AppLogger.video.d('컨트롤러가 없거나 초기화되지 않음 - 스킵');
      return;
    }

    // 기존 리스너 제거
    if (_playbackListener != null) {
      controller.removeListener(_playbackListener!);
      _playbackListener = null;
    }

    AppLogger.video.i('========== 타이머 상태 확인 ==========');
    AppLogger.video.d('타이머 상태: ${timerState.status}');
    AppLogger.video.d('비디오 재생 중: ${controller.value.isPlaying}');

    // 타이머 상태와 비디오 재생 상태 동기화
    switch (timerState.status) {
      case TimerStatus.running:
        if (!controller.value.isPlaying) {
          AppLogger.video.i('타이머 실행 중 - 비디오 재생 시작');
          controller.play();
          AppLogger.video.d('비디오 play() 호출 완료');
        } else {
          AppLogger.video.d('비디오 이미 재생 중');
        }
        break;
      case TimerStatus.paused:
        if (controller.value.isPlaying) {
          AppLogger.video.i('타이머 일시정지 - 비디오 일시정지');
          controller.pause();
        }
        break;
      case TimerStatus.stopped:
        AppLogger.video.i('타이머 정지 - 비디오 정지');
        controller.pause();
        controller.seekTo(Duration.zero);
        break;
    }

    _previousStatus = timerState.status;
    AppLogger.video.i('========== 타이머 상태 확인 끝 ==========');
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 항상 썸네일을 배경으로 표시
            Image.asset(
              animationSelection.getCurrentThumPath(
                isRunning: timerState.status == TimerStatus.running,
                round: timerState.round,
              ),
              fit: BoxFit.cover,
            ),
            // 비디오가 준비되면 그 위에 표시
            if (controller != null &&
                _isInitialized &&
                controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 리스너 정리
    if (_playbackListener != null) {
      final controller = ref.read(videoControllerProvider);
      controller?.removeListener(_playbackListener!);
    }
    // 컨트롤러는 Provider가 관리하므로 여기서 dispose 안 함
    super.dispose();
  }
}
