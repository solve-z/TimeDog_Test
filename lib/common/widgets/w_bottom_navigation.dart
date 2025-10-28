import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          height: 48,
          color: AppColors.bottomNavBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, AssetPaths.timerIcon),
              _buildNavItem(1, AssetPaths.diaryIcon),
              _buildNavItem(2, AssetPaths.chartIcon),
              _buildNavItem(3, AssetPaths.peopleIcon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath) {
    return InkWell(
      onTap: () => onTap(index),
      child: SvgPicture.asset(
        iconPath,
        width: AppConstants.bottomNavIconSize,
        height: AppConstants.bottomNavIconSize,
        colorFilter: ColorFilter.mode(
          currentIndex == index ? AppColors.selectedBottomNav : Colors.grey,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
