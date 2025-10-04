import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class NumberPickerDialog extends StatefulWidget {
  final String title;
  final int currentValue;
  final int minValue;
  final int maxValue;
  final String unit;

  const NumberPickerDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.unit,
  });

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int selectedValue;
  late FixedExtentScrollController scrollController;
  bool isScrolling = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.currentValue;
    scrollController = FixedExtentScrollController(
      initialItem: selectedValue - widget.minValue,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.maxValue - widget.minValue + 1;

    return Dialog(
      backgroundColor: Color(0xFFF8F8F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            // 숫자 선택 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 240,
                color: Color(0xFFF8F8F8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        // 선택된 항목 강조 (회색 배경) - 먼저 배치
                        Center(
                          child: IgnorePointer(
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                          ),
                        ),

                        // 숫자 휠 피커 - 배경 위에 배치
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollStartNotification) {
                              setState(() {
                                isScrolling = true;
                              });
                            } else if (notification is ScrollEndNotification) {
                              setState(() {
                                isScrolling = false;
                              });
                            }
                            return true;
                          },
                          child: ListWheelScrollView.useDelegate(
                            controller: scrollController,
                            itemExtent: 80,
                            physics: const FixedExtentScrollPhysics(),
                            diameterRatio: 100.0,
                            perspective: 0.0001,
                            useMagnifier: false,
                            magnification: 1.0,
                            onSelectedItemChanged: (index) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedValue = widget.minValue + index;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: itemCount,
                              builder: (context, index) {
                                final value = widget.minValue + index;
                                final isSelected = value == selectedValue;

                                return Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 100),
                                    style: TextStyle(
                                      fontFamily: 'OmyuPretty',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          isScrolling
                                              ? const Color(0xFFC76D71)
                                              : const Color(0xFF111827),
                                    ),
                                    child: Text('$value'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // 상단 투명도 효과
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9).withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),

                        // 하단 투명도 효과
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9).withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 선택 버튼
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: 24,
              ),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(selectedValue),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '선택',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
