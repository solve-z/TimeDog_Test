import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constant/app_constants.dart';

class AppBarActionsWidget extends StatelessWidget {
  const AppBarActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AppBarIconButtonWidget(
          iconPath: AssetPaths.crownIcon,
          tooltip: '프리미엄',
          onPressed: () {},
        ),
        _AppBarIconButtonWidget(
          iconPath: AssetPaths.listIcon,
          tooltip: '할일리스트',
          onPressed: () {},
        ),
        _AppBarIconButtonWidget(
          iconPath: AssetPaths.plusIcon,
          tooltip: '추가',
          onPressed: () {},
        ),
        _AppBarIconButtonWidget(
          iconPath: AssetPaths.settingIcon,
          tooltip: '설정',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _AppBarIconButtonWidget extends StatelessWidget {
  final String iconPath;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarIconButtonWidget({
    required this.iconPath,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        iconPath,
        width: AppConstants.appBarIconSize,
        height: AppConstants.appBarIconSize,
      ),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}