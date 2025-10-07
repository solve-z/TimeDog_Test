import 'package:flutter/material.dart';
import 'package:timedog_test/common/constant/app_constants.dart';
import 'd_todo_selection.dart';

class TodoRequiredDialog extends StatelessWidget {
  const TodoRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              const Text(
                '할일을 선택해주세요',
                style: TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              const Text(
                '타이머를 시작하려면\n할일을 먼저 선택해야 합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '취소',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 할일 선택 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '할일 선택',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'OmyuPretty',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 할일 필수 다이얼로그 표시
///
/// Returns:
/// - `true`: 할일 선택 화면으로 이동
/// - `false` or `null`: 취소
Future<bool?> showTodoRequiredDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const TodoRequiredDialog(),
  );
}
