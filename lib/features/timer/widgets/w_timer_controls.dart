import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/timer_notifier.dart';
import '../models/vo_timer.dart';
import '../../../common/dialogs/d_todo_required.dart';
import '../../../common/dialogs/d_todo_selection.dart';

class TimerControlsWidget extends ConsumerWidget {
  const TimerControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 초기상태(stopped): play만
          if (timerState.status == TimerStatus.stopped) ...[
            _buildControlButton(
              context,
              ref,
              'assets/images/icons/play.svg',
              () => _handleStart(context, timerNotifier),
              '시작',
            ),
          ]
          // 시작상태(running): pause만
          else if (timerState.status == TimerStatus.running) ...[
            _buildControlButton(
              context,
              ref,
              'assets/images/icons/pause.svg',
              () => timerNotifier.pause(),
              '일시정지',
            ),
          ]
          // 일시정지상태(paused): play, rotate, x
          else if (timerState.status == TimerStatus.paused) ...[
            _buildControlButton(
              context,
              ref,
              'assets/images/icons/play.svg',
              () => _handleStart(context, timerNotifier),
              '시작',
            ),
            _buildControlButton(
              context,
              ref,
              'assets/images/icons/rotate.svg',
              () => timerNotifier.stop(),
              '재시작',
            ),
            _buildControlButton(
              context,
              ref,
              'assets/images/icons/x.svg',
              () => timerNotifier.reset(),
              '종료',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleStart(
    BuildContext context,
    TimerNotifier timerNotifier,
  ) async {
    try {
      print('🎯 타이머 시작 시도');
      await timerNotifier.start();
      print('✅ 타이머 시작 성공');
    } catch (e) {
      print('❌ 타이머 시작 실패: $e');
      if (e.toString().contains('NO_TODO_SELECTED')) {
        print('📋 할일 미선택 - 다이얼로그 표시');
        // 할일 선택 필수 다이얼로그 표시
        if (!context.mounted) return;

        final shouldNavigate = await showTodoRequiredDialog(context);
        print('👆 사용자 선택: $shouldNavigate');

        if (shouldNavigate == true) {
          // 할일 선택 화면으로 이동
          if (context.mounted) {
            print('🔄 할일 선택 다이얼로그 열기');
            showTodoSelectionDialog(context);
          }
        }
      } else {
        // 다른 예외 처리
        print('⚠️ 알 수 없는 예외: $e');
        rethrow;
      }
    }
  }

  Widget _buildControlButton(
    BuildContext context,
    WidgetRef ref,
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 38,
            height: 38,
            colorFilter: const ColorFilter.mode(
              Color(0xFF666666),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
