import 'package:flutter/material.dart';

class CharacterAnimationFragment extends StatefulWidget {
  const CharacterAnimationFragment({super.key});

  @override
  State<CharacterAnimationFragment> createState() =>
      _CharacterAnimationFragmentState();
}

class _CharacterAnimationFragmentState
    extends State<CharacterAnimationFragment> {
  String currentAnimation = 'assets/images/animations/animation2.png';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 추후 애니메이션 변경 기능
      },
      child: Container(
        height: 250,
        width: 250,
        child: ClipRRect(
          child: Image.asset(currentAnimation, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // 추후 애니메이션 변경을 위한 메서드
  void changeAnimation(String animationPath) {
    setState(() {
      currentAnimation = animationPath;
    });
  }
}
