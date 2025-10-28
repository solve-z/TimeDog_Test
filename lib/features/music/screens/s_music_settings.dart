import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/d_music_selection.dart';
import '../providers/music_provider.dart';
import '../models/vo_music_option.dart';

class MusicSettingsScreen extends ConsumerStatefulWidget {
  const MusicSettingsScreen({super.key});

  @override
  ConsumerState<MusicSettingsScreen> createState() =>
      _MusicSettingsScreenState();
}

class _MusicSettingsScreenState extends ConsumerState<MusicSettingsScreen> {
  String? selectedMusic;

  @override
  void initState() {
    super.initState();
    // 저장된 음악 설정 로드
    final musicSelection = ref.read(musicProvider);
    selectedMusic = musicSelection.musicId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B7280)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '음악 설정',
          style: TextStyle(
            fontFamily: 'OmyuPretty',
            fontSize: 16,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('노래'),
                const SizedBox(height: 16),
                _buildMusicSelector(),
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

  Widget _buildMusicSelector() {
    final selectedOption = defaultMusicOptions.firstWhere(
      (music) => music.id == selectedMusic,
      orElse: () => defaultMusicOptions[0],
    );

    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder:
              (context) => MusicSelectionDialog(
                title: '음악 선택',
                currentSelection: selectedMusic,
                musicOptions: defaultMusicOptions,
              ),
        );
        if (result != null) {
          setState(() {
            selectedMusic = result;
          });
          // Provider에 저장
          ref.read(musicProvider.notifier).setMusic(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selectedOption.icon,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedOption.name,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
