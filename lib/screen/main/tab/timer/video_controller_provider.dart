import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// 비디오 컨트롤러를 앱 전체에서 공유하여 탭 전환 시에도 재로딩 방지
/// AutoDisposeProvider 대신 Provider 사용으로 앱이 살아있는 동안 계속 유지
final videoControllerProvider = Provider<VideoPlayerController>((ref) {
  final controller = VideoPlayerController.asset(
    'assets/videos/focus_animations/drawing_white.mp4',
  );

  // 앱 시작 시 자동으로 비디오 초기화 (백그라운드에서 미리 로드)
  controller.initialize().then((_) {
    controller.setLooping(true);
  });

  // Provider가 dispose될 때 컨트롤러도 정리
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
