import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constant/app_constants.dart';

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
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.selectedBottomNav,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        backgroundColor: AppColors.bottomNavBackground,
        onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetPaths.timerIcon,
            width: AppConstants.bottomNavIconSize,
            height: AppConstants.bottomNavIconSize,
            colorFilter: currentIndex == 0
                ? ColorFilter.mode(
                    AppColors.selectedBottomNav,
                    BlendMode.srcIn,
                  )
                : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetPaths.diaryIcon,
            width: AppConstants.bottomNavIconSize,
            height: AppConstants.bottomNavIconSize,
            colorFilter: currentIndex == 1
                ? ColorFilter.mode(
                    AppColors.selectedBottomNav,
                    BlendMode.srcIn,
                  )
                : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetPaths.chartIcon,
            width: AppConstants.bottomNavIconSize,
            height: AppConstants.bottomNavIconSize,
            colorFilter: currentIndex == 2
                ? ColorFilter.mode(
                    AppColors.selectedBottomNav,
                    BlendMode.srcIn,
                  )
                : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AssetPaths.peopleIcon,
            width: AppConstants.bottomNavIconSize,
            height: AppConstants.bottomNavIconSize,
            colorFilter: currentIndex == 3
                ? ColorFilter.mode(
                    AppColors.selectedBottomNav,
                    BlendMode.srcIn,
                  )
                : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: '',
        ),
      ],
      ),
    );
  }
}