import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/widgets/w_app_bar_actions.dart';
import '../common/widgets/w_bottom_navigation.dart';
import '../common/widgets/w_drawer_menu.dart';
import '../features/timer/screens/s_timer.dart';
import '../features/todo/screens/s_todo.dart';
import '../features/statistics/screens/s_statistics.dart';
import '../features/profile/screens/s_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = ['타이머', '할일 관리', '통계', '내정보'];

  final List<Widget> _screens = [
    const TimerScreen(),
    const TodoScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        appBar:
            isLandscape
                ? null
                : (_currentIndex == 0
                    ? AppBar(
                      leading: Builder(
                        builder:
                            (context) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/icons/drawer.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                      ),
                    )
                    : _currentIndex == 1
                    ? null
                    : AppBar(
                      title: Text(
                        _tabTitles[_currentIndex],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: const [AppBarActionsWidget()],
                    )),
        drawer: _currentIndex == 0 ? const DrawerMenuWidget() : null,
        body: _screens[_currentIndex],
        bottomNavigationBar:
            isLandscape
                ? null
                : BottomNavigationWidget(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
      ),
    );
  }
}
