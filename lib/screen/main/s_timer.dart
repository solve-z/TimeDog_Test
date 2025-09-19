import 'package:flutter/material.dart';
import '../../common/widget/w_app_bar_actions.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('타이머', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [AppBarActionsWidget()],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              '영어단어 외우기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                '21:00',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '00:00:00',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(75),
            ),
            child: const Icon(Icons.pets, size: 80, color: Colors.grey),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.hourglass_empty),
                iconSize: 32,
                tooltip: '모래시계',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                iconSize: 32,
                tooltip: '시작',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                iconSize: 32,
                tooltip: '리셋',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close),
                iconSize: 32,
                tooltip: '취소',
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: '할일'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내정보'),
        ],
      ),
    );
  }
}