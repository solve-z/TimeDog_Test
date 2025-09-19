import 'package:flutter/material.dart';
import '../../common/widget/w_app_bar_actions.dart';
import '../../common/widget/w_bottom_navigation.dart';
import 'tab/timer/s_timer.dart';
import 'tab/todo/s_todo.dart';
import 'tab/statistics/s_statistics.dart';
import 'tab/profile/s_profile.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [AppBarActionsWidget()],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}