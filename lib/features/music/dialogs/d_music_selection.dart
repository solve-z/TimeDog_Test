import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/features/music/models/vo_music_option.dart';
import '../services/music_player_service.dart';
import '../../timer/providers/timer_notifier.dart';
import '../../timer/models/vo_timer.dart';

class MusicSelectionDialog extends ConsumerStatefulWidget {
  final String title;
  final String? currentSelection;
  final List<MusicOption> musicOptions;

  const MusicSelectionDialog({
    super.key,
    required this.title,
    this.currentSelection,
    required this.musicOptions,
  });

  @override
  ConsumerState<MusicSelectionDialog> createState() =>
      _MusicSelectionDialogState();
}

class _MusicSelectionDialogState extends ConsumerState<MusicSelectionDialog> {
  String? _selectedId;
  String? _playingId;
  late MusicPlayerService _musicService;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentSelection;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _musicService = ref.read(musicPlayerServiceProvider);
    // 타이머 상태를 미리 캐싱 (dispose에서 ref 사용 불가하므로)
    _isTimerRunning = ref.read(timerProvider).status == TimerStatus.running;
  }

  @override
  void dispose() {
    // dispose에서는 ref를 사용할 수 없으므로 미리 저장한 상태 사용
    // 타이머가 실행 중이 아닐 때만 음악 정지 (미리듣기만 정지)
    if (_playingId != null && !_isTimerRunning) {
      _musicService.stopMusic();
    }
    super.dispose();
  }

  Future<void> _toggleAudioPreview(MusicOption music) async {
    if (music.audioPath == null) {
      print('🎵 음악 경로가 없습니다: ${music.name}');
      return;
    }

    try {
      if (_playingId == music.id) {
        // 현재 재생 중이면 정지
        print('⏸️  음악 정지: ${music.name}');
        await _musicService.stopMusic();
        setState(() {
          _playingId = null;
        });
      } else {
        // 다른 음악 재생
        print('🎵 음악 재생 시도: ${music.name}');
        print('📁 경로: ${music.audioPath}');

        // 볼륨 설정 (미리듣기는 최대 볼륨)
        await _musicService.setVolume(1.0);

        // MusicPlayerService를 통해 재생
        await _musicService.playMusic(music.id);
        print('✅ 재생 시작됨');

        setState(() {
          _playingId = music.id;
        });
      }
    } catch (e) {
      print('❌ 오디오 재생 오류: $e');
      setState(() {
        _playingId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
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

            const SizedBox(height: 20),

            // 그리드뷰
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.musicOptions.length,
                itemBuilder: (context, index) {
                  final music = widget.musicOptions[index];
                  final isSelected = music.id == _selectedId;
                  final isLocked = music.status == MusicStatus.locked;

                  final isPlaying = _playingId == music.id;

                  return GestureDetector(
                    onTap: () {
                      if (!isLocked) {
                        setState(() {
                          _selectedId = music.id;
                        });
                        _toggleAudioPreview(music);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF6B7280)
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 선택 표시 또는 잠금 표시 또는 재생 표시
                            if (isPlaying)
                              const Icon(
                                Icons.play_circle_filled,
                                color: Color(0xFF10B981),
                                size: 14,
                              )
                            else if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 14,
                              )
                            else if (isLocked)
                              const Icon(
                                Icons.lock,
                                color: Color(0xFF9CA3AF),
                                size: 14,
                              )
                            else
                              const SizedBox(height: 14),
                            const SizedBox(height: 4),
                            // 아이콘
                            Icon(
                              music.icon,
                              size: 32,
                              color:
                                  isLocked
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF6B7280),
                            ),
                            const SizedBox(height: 4),
                            // 이름
                            Flexible(
                              child: Text(
                                music.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'OmyuPretty',
                                  fontSize: 10,
                                  color:
                                      isLocked
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 선택 버튼
            GestureDetector(
              onTap: () {
                if (_selectedId != null) {
                  Navigator.pop(context, _selectedId);
                }
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
}
