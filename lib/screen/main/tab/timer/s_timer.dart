import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'f_character_animation.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 할일 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 27,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9B5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '영어 단어 외우기',
                    style: TextStyle(
                      fontFamily: 'OmyuPretty',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 타이머 표시
              const Text(
                '21 : 00',
                style: TextStyle(
                  fontFamily: 'OmyuPretty',
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF6B7280),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),

              // 라운드 진행 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressCircle(true),
                  const SizedBox(width: 12),
                  _buildProgressCircle(true),
                  const SizedBox(width: 12),
                  _buildProgressCircle(false),
                  const SizedBox(width: 12),
                  _buildProgressCircle(false),
                ],
              ),
              const SizedBox(height: 30),

              // 캐릭터 애니메이션 영역
              const CharacterAnimationFragment(),
              const SizedBox(height: 15),

              // 노래 선택 버튼
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/music.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        '노래 선택',
                        style: TextStyle(
                          fontFamily: 'OmyuPretty',
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 컨트롤 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    'assets/images/icons/play.svg',
                    () {},
                    '시작',
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    'assets/images/icons/rotate.svg',
                    () {},
                    '리셋',
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton('assets/images/icons/x.svg', () {}, '취소'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle(bool isCompleted) {
    return SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.asset(
        isCompleted
            ? 'assets/images/icons/check_circle.svg'
            : 'assets/images/icons/circle.svg',
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildControlButton(
    String iconPath,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
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
