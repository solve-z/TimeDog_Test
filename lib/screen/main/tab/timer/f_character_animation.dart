import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'timer_notifier.dart';
import 'vo/vo_timer.dart';

class CharacterAnimationFragment extends ConsumerStatefulWidget {
  const CharacterAnimationFragment({super.key});

  @override
  ConsumerState<CharacterAnimationFragment> createState() =>
      _CharacterAnimationFragmentState();
}

class _CharacterAnimationFragmentState
    extends ConsumerState<CharacterAnimationFragment> {
  VideoPlayerController? _controller;
  String currentVideoPath = 'assets/videos/focus_animations/drawing_white.mp4';
  TimerStatus? _previousStatus;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(currentVideoPath);
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void didUpdateWidget(CharacterAnimationFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkTimerStatus();
  }

  void _checkTimerStatus() {
    final timerState = ref.read(timerProvider);

    // 상태가 변경되지 않았으면 무시
    if (_previousStatus == timerState.status) return;

    _previousStatus = timerState.status;

    if (_controller == null || !_controller!.value.isInitialized) return;

    switch (timerState.status) {
      case TimerStatus.running:
        // 타이머 시작 - 영상 재생
        if (!_controller!.value.isPlaying) {
          _controller!.play();
        }
        break;
      case TimerStatus.paused:
        // 타이머 일시정지 - 영상 일시정지
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        }
        break;
      case TimerStatus.stopped:
        // 타이머 중지/초기화 - 영상 초기화
        _controller!.pause();
        _controller!.seekTo(Duration.zero);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 타이머 상태 감시
    ref.listen<TimerState>(timerProvider, (previous, next) {
      if (previous?.status != next.status) {
        _checkTimerStatus();
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
        child: _hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      '영상 로드 실패',
                      style: TextStyle(color: Colors.red),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              )
            : _controller != null && _controller!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
