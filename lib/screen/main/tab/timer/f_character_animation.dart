import 'package:flutter/material.dart';

class CharacterAnimationFragment extends StatefulWidget {
  const CharacterAnimationFragment({super.key});

  @override
  State<CharacterAnimationFragment> createState() =>
      _CharacterAnimationFragmentState();
}

class _CharacterAnimationFragmentState
    extends State<CharacterAnimationFragment> {
  String currentAnimation = 'assets/images/animations/animation1.png';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 추후 애니메이션 변경 기능
      },
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(75)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(75),
          child: Image.asset(
            currentAnimation,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
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
