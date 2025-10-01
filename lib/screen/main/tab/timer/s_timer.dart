// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'f_character_animation.dart';
import 'w_timer_display.dart';
import 'w_timer_controls.dart';
import 'w_progress_indicator.dart';
import '../todo/todo_provider.dart';
import '../../../../common/dialog/d_todo_selection.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // 할일 선택 영역
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 700 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                  child: GestureDetector(
                    onTap: () => showTodoSelectionDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            todoState.selectedTodo?.color.withOpacity(0.1) ??
                            const Color(0xFFF9FAFB),
                        border: Border.all(
                          color:
                              todoState.selectedTodo?.color.withOpacity(0.3) ??
                              const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (todoState.selectedTodo != null) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: todoState.selectedTodo!.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                todoState.selectedTodo!.title,
                                style: const TextStyle(
                                  fontFamily: 'OmyuPretty',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '할일 선택',
                              style: TextStyle(
                                fontFamily: 'OmyuPretty',
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
