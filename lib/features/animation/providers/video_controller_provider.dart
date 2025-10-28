import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_session/audio_session.dart';
import 'animation_provider.dart';
import '../../timer/providers/timer_notifier.dart';
import '../../timer/models/vo_timer.dart';
import '../../../common/utils/app_logger.dart';

class VideoControllerNotifier extends StateNotifier<VideoPlayerController?> {
  VideoControllerNotifier(this._ref) : super(null) {
    _initializeControllerAsync();
  }

  final Ref _ref;
  String? _currentVideoPath;

  Future<void> _initializeControllerAsync() async {
    // 앱 레벨 오디오 세션 설정 (ambient 모드 - 다른 앱 음악과 믹스)
    await _configureAudioSession();

    // animationProvider의 SharedPreferences 로드 완료를 기다림
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _initializeController();
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;

      const config = AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.moviePlayback,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidWillPauseWhenDucked: false,
      );

      await session.configure(config);
    } catch (e, stackTrace) {
      AppLogger.video.e('오디오 세션 설정 실패: $e');
      AppLogger.video.e('스택 트레이스: $stackTrace');
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
      return;
    }

    // 기존 컨트롤러 정리
    final oldController = state;
    if (oldController != null) {
      AppLogger.video.d('기존 컨트롤러 정리 중...');
      oldController.pause();
      oldController.dispose();
    }

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
            controller.setVolume(0.0);
            state = controller;
          }
        })
        .catchError((error) {
          AppLogger.video.e('비디오 로드 실패: $error');
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
