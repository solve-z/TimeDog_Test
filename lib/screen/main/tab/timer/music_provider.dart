import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MusicSelection {
  final String musicId;

  const MusicSelection({
    this.musicId = 'none', // 기본값: 없음
  });

  MusicSelection copyWith({
    String? musicId,
  }) {
    return MusicSelection(
      musicId: musicId ?? this.musicId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'musicId': musicId,
    };
  }

  factory MusicSelection.fromJson(Map<String, dynamic> json) {
    return MusicSelection(
      musicId: json['musicId'] ?? 'none',
    );
  }
}

class MusicNotifier extends StateNotifier<MusicSelection> {
  bool _isLoaded = false;

  MusicNotifier() : super(const MusicSelection()) {
    _loadSelection();
  }

  static const String _storageKey = 'music_selection';

  Future<void> _loadSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        state = MusicSelection.fromJson(decoded);
        print('✅ 음악 선택 로드: ${state.musicId}');
      } else {
        print('✅ 기본 음악 사용: ${state.musicId}');
      }
      _isLoaded = true;
    } catch (e) {
      print('❌ 음악 선택 로드 실패: $e');
      _isLoaded = true;
    }
  }

  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    // 로딩이 완료될 때까지 최대 2초 대기
    for (int i = 0; i < 20; i++) {
      if (_isLoaded) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _saveSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
      print('💾 음악 선택 저장: ${state.musicId}');
    } catch (e) {
      print('❌ 음악 선택 저장 실패: $e');
    }
  }

  void setMusic(String musicId) {
    state = state.copyWith(musicId: musicId);
    _saveSelection();
  }
}

final musicProvider =
    StateNotifierProvider<MusicNotifier, MusicSelection>((ref) {
  return MusicNotifier();
});
