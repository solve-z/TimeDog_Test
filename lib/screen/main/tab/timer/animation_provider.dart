import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnimationSelection {
  final String focusAnimationId;
  final String breakAnimationId;

  const AnimationSelection({
    this.focusAnimationId = 'drawing_white', // 기본값: 그림 그리기
    this.breakAnimationId = 'rest_white', // 기본값: 휴식하기
  });

  AnimationSelection copyWith({
    String? focusAnimationId,
    String? breakAnimationId,
  }) {
    return AnimationSelection(
      focusAnimationId: focusAnimationId ?? this.focusAnimationId,
      breakAnimationId: breakAnimationId ?? this.breakAnimationId,
    );
  }

  // 현재 선택된 애니메이션의 비디오 경로 가져오기
  String getFocusVideoPath() {
    print('🎬 집중 애니메이션 ID: $focusAnimationId');
    switch (focusAnimationId) {
      case 'drawing_white':
        return 'assets/videos/focus_animations/drawing_white.mp4';
      case 'cooking_white':
        return 'assets/videos/focus_animations/cook_white.mp4';
      case 'reading':
        return 'assets/videos/focus_animations/drawing_white.mp4'; // 기본값
      default:
        print('⚠️  알 수 없는 집중 애니메이션 ID: $focusAnimationId, 기본값 사용');
        return 'assets/videos/focus_animations/drawing_white.mp4';
    }
  }

  String getBreakVideoPath() {
    print('🎬 휴식 애니메이션 ID: $breakAnimationId');
    switch (breakAnimationId) {
      case 'rest_white':
        return 'assets/videos/rest_animations/rest_white.mp4';
      case 'sleeping':
        return 'assets/videos/rest_animations/rest_1.mp4';
      case 'playing':
        return 'assets/videos/rest_animations/rest_white.mp4'; // 기본값
      default:
        print('⚠️  알 수 없는 휴식 애니메이션 ID: $breakAnimationId, 기본값 사용');
        return 'assets/videos/rest_animations/rest_white.mp4';
    }
  }

  String getFocusThumPath() {
    switch (focusAnimationId) {
      case 'drawing_white':
        return 'assets/images/animations/drawing_white_Thum.jpg';
      case 'cooking_white':
        return 'assets/images/animations/cook_white_Thum.jpg';
      case 'reading':
        return 'assets/images/animations/drawing_white_Thum.jpg'; // 기본값
      default:
        print('⚠️  알 수 없는 집중 애니메이션 ID: $focusAnimationId, 기본값 사용');
        return 'assets/images/animations/drawing_white_Thum.jpg';
    }
  }

  String getBreakThumPath() {
    switch (breakAnimationId) {
      case 'rest_white':
        return 'assets/images/animations/rest_white_Thum.jpg';
      case 'sleeping':
        return 'assets/images/animations/rest_1_Thum.jpg';
      case 'playing':
        return 'assets/images/animations/rest_white_Thum.jpg'; // 기본값
      default:
        print('⚠️  알 수 없는 휴식 애니메이션 ID: $breakAnimationId, 기본값 사용');
        return 'assets/images/animations/rest_white_Thum.jpg';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'focusAnimationId': focusAnimationId,
      'breakAnimationId': breakAnimationId,
    };
  }

  factory AnimationSelection.fromJson(Map<String, dynamic> json) {
    return AnimationSelection(
      focusAnimationId: json['focusAnimationId'] ?? 'drawing_white',
      breakAnimationId: json['breakAnimationId'] ?? 'rest_white',
    );
  }
}

class AnimationNotifier extends StateNotifier<AnimationSelection> {
  AnimationNotifier() : super(const AnimationSelection()) {
    _loadSelection();
  }

  static const String _storageKey = 'animation_selection';

  Future<void> _loadSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        state = AnimationSelection.fromJson(decoded);
        print(
          '✅ 애니메이션 선택 로드: focus=${state.focusAnimationId}, break=${state.breakAnimationId}',
        );
      } else {
        print(
          '✅ 기본 애니메이션 사용: focus=${state.focusAnimationId}, break=${state.breakAnimationId}',
        );
      }
    } catch (e) {
      print('❌ 애니메이션 선택 로드 실패: $e');
    }
  }

  Future<void> _saveSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
      print(
        '💾 애니메이션 선택 저장: focus=${state.focusAnimationId}, break=${state.breakAnimationId}',
      );
    } catch (e) {
      print('❌ 애니메이션 선택 저장 실패: $e');
    }
  }

  void setFocusAnimation(String animationId) {
    state = state.copyWith(focusAnimationId: animationId);
    _saveSelection();
  }

  void setBreakAnimation(String animationId) {
    state = state.copyWith(breakAnimationId: animationId);
    _saveSelection();
  }
}

final animationProvider =
    StateNotifierProvider<AnimationNotifier, AnimationSelection>((ref) {
      return AnimationNotifier();
    });
