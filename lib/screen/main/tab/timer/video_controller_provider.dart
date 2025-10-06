import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'animation_provider.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class VideoControllerNotifier extends StateNotifier<VideoPlayerController?> {
  VideoControllerNotifier(this._ref) : super(null) {
    _initializeControllerAsync();
  }

  final Ref _ref;
  String? _currentVideoPath;

  Future<void> _initializeControllerAsync() async {
    // animationProvider의 SharedPreferences 로드 완료를 기다림
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _initializeController();
    }
  }

  void _initializeController() {
    final animationSelection = _ref.read(animationProvider);
    final timerState = _ref.read(timerProvider);

    // 타이머 상태에 따라 적절한 비디오 선택
    String videoPath;
    if (timerState.mode == TimerMode.pomodoro) {
      if (timerState.round == PomodoroRound.focus) {
        videoPath = animationSelection.getFocusVideoPath();
      } else {
        videoPath = animationSelection.getBreakVideoPath();
      }
    } else {
      // 스톱워치 모드는 집중 애니메이션 사용
      videoPath = animationSelection.getFocusVideoPath();
    }

    _loadVideo(videoPath);
  }

  void _loadVideo(String videoPath) {
    if (_currentVideoPath == videoPath &&
        state != null &&
        state!.value.isInitialized) {
      // 이미 같은 비디오가 로드되어 있으면 스킵
      return;
    }

    // 기존 컨트롤러 정리
    final oldController = state;
    oldController?.pause();
    oldController?.dispose();

    state = null;
    _currentVideoPath = null;

    // 새 비디오 로드
    _currentVideoPath = videoPath;
    final controller = VideoPlayerController.asset(videoPath);

    controller
        .initialize()
        .then((_) {
          if (mounted) {
            controller.setLooping(true);
            controller.setVolume(0.0); // 비디오 음소거 (음악과 충돌 방지)
            state = controller;
          }
        })
        .catchError((error) {
          _currentVideoPath = null;
        });
  }

  void updateVideo() {
    _initializeController();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final videoControllerProvider =
    StateNotifierProvider<VideoControllerNotifier, VideoPlayerController?>((
      ref,
    ) {
      final notifier = VideoControllerNotifier(ref);

      // 애니메이션 선택이 변경되면 비디오 업데이트
      ref.listen(animationProvider, (previous, next) {
        if (previous != next) {
          notifier.updateVideo();
        }
      });

      // 타이머 라운드가 변경되면 비디오 업데이트 (집중 <-> 휴식)
      ref.listen(timerProvider, (previous, next) {
        if (previous?.round != next.round || previous?.mode != next.mode) {
          notifier.updateVideo();
        }
      });

      return notifier;
    });
