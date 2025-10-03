// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'f_character_animation.dart';
import 'w_timer_display.dart';
import 'w_timer_controls.dart';
import 'w_progress_indicator.dart';
import 'w_todo_selector.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // 할일 선택 영역
            const TodoSelectorWidget(),
            SizedBox(height: isTablet ? 24 : 20),

            // 타이머 표시 위젯 (전체 너비 사용)
            const TimerDisplayWidget(),

            // 나머지 컨텐츠
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 700 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 20 : 16),

                      // 라운드 진행 상태 (뽀모도로 모드에서만)
                      const ProgressIndicatorWidget(),
                      SizedBox(height: isTablet ? 30 : 24),

                      // 캐릭터 애니메이션 영역
                      const CharacterAnimationFragment(),
                      SizedBox(height: isTablet ? 30 : 24),

                      // 컨트롤 버튼들
                      const TimerControlsWidget(),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
