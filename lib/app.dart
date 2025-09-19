import 'package:flutter/material.dart';
import 'screen/main/s_timer.dart';

class TimeDogApp extends StatelessWidget {
  const TimeDogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeDog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const TimerScreen(),
    );
  }
}