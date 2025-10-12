import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/common/utils/app_logger.dart';
import 'music_provider.dart';
import '../../../../common/data/vo_music_option.dart';

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer(); // 완료 사운드용 별도 플레이어
  String? _currentPlayingId;
  bool _isPlaying = false;

  MusicPlayerService() {
    _initializePlayer();
    _initializeSoundEffectPlayer();
  }

  Future<void> _initializePlayer() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(1.0); // 기본 볼륨 100%

    // PlayerMode 설정 (Low Latency 모드 - 끊김 없는 루프 재생)
    await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);

    // AudioContext 설정 - 다른 앱 음악과 함께 재생
    await _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers}, // iOS: 다른 앱과 믹스
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          // none: 오디오 포커스를 요청하지 않음 (다른 앱과 동시 재생)
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

    // 재생 상태 리스너
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('🎵 [MusicPlayerService] 플레이어 상태: $state');
      _isPlaying = state == PlayerState.playing;
    });

    print('🎵 [MusicPlayerService] 초기화 완료');
  }

  Future<void> _initializeSoundEffectPlayer() async {
    print('🔔 [SoundEffectPlayer] 초기화 시작');

    await _soundEffectPlayer.setReleaseMode(ReleaseMode.release); // 한 번만 재생
    print('   - ReleaseMode: release');

    await _soundEffectPlayer.setVolume(1.0); // 완료 사운드는 최대 볼륨
    print('   - Volume: 1.0');

    // PlayerMode 설정
    await _soundEffectPlayer.setPlayerMode(PlayerMode.lowLatency);
    print('   - PlayerMode: lowLatency');

    // AudioContext 설정 - 알림/효과음으로 설정
    await _soundEffectPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification, // 효과음
          usageType: AndroidUsageType.notificationEvent, // 알림 이벤트 (짧은 사운드)
          audioFocus:
              AndroidAudioFocus.gainTransient, // 일시적으로 포커스 획득 (다른 앱 일시정지)
        ),
      ),
    );
    print('   - AudioContext 설정 완료');

    // 재생 상태 리스너
    _soundEffectPlayer.onPlayerStateChanged.listen((state) {
      print('🔔 [SoundEffectPlayer] 상태 변경: $state');
    });

    _soundEffectPlayer.onPlayerComplete.listen((event) {
      print('🔔 [SoundEffectPlayer] 재생 완료');
    });

    print('🔔 [SoundEffectPlayer] 초기화 완료');
  }

  Future<void> playMusic(String musicId) async {
    if (_currentPlayingId == musicId && _isPlaying) {
      return;
    }

    try {
      // 음악 옵션 찾기
      final musicOption = defaultMusicOptions.firstWhere(
        (option) => option.id == musicId,
        orElse: () => defaultMusicOptions[0], // 'none'
      );

      if (musicOption.audioPath == null || musicOption.id == 'none') {
        await stopMusic();
        return;
      }

      await _audioPlayer.stop();

      // 재생 전 오디오 컨텍스트 재설정 (오디오 포커스 강제 확보)
      await _audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            // none: 오디오 포커스를 요청하지 않음 (유튜브 등과 동시 재생)
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );

      await _audioPlayer.play(AssetSource(musicOption.audioPath!));

      _currentPlayingId = musicId;
      _isPlaying = true;

      print('✅ [MusicPlayerService] 재생 시작됨');
    } catch (e) {
      _currentPlayingId = null;
      _isPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    try {
      print('⏹️  음악 정지');
      await _audioPlayer.stop();
      _currentPlayingId = null;
      _isPlaying = false;
    } catch (e) {
      print('❌ 음악 정지 오류: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      print('⏸️  음악 일시정지');
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('❌ 음악 일시정지 오류: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      if (_currentPlayingId != null) {
        print('▶️  음악 재개');
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      print('❌ 음악 재개 오류: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> playCompletionSound() async {
    try {
      // 기존 배경 음악 플레이어를 사용 (이미 검증된 방식)

      // 배경 음악 정지
      await _audioPlayer.stop();

      // 완료 사운드용 임시 설정
      final originalVolume = 0.5; // 원래 볼륨
      await _audioPlayer.setVolume(1.0); // 완료 사운드는 최대 볼륨

      // ReleaseMode 임시 변경 (한 번만 재생)
      await _audioPlayer.setReleaseMode(ReleaseMode.release);

      // 완료 사운드 재생
      await _audioPlayer.play(AssetSource('audios/alarm_7.wav'));

      // 완료 사운드 재생 대기 (1.5초)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 원래 설정 복원
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // 루프 모드로 복원
      await _audioPlayer.setVolume(originalVolume); // 원래 볼륨으로 복원

      // 상태 초기화
      _currentPlayingId = null;
      _isPlaying = false;
    } catch (e, stackTrace) {
      AppLogger.sound.e('완료 사운드 재생 오류: $e');
      AppLogger.sound.e('스택 트레이스: $stackTrace');
    }
  }

  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _soundEffectPlayer.stop();
    _soundEffectPlayer.dispose();
  }

  bool get isPlaying => _isPlaying;
  String? get currentPlayingId => _currentPlayingId;
}

// Provider로 MusicPlayerService를 제공
final musicPlayerServiceProvider = Provider<MusicPlayerService>((ref) {
  final service = MusicPlayerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
