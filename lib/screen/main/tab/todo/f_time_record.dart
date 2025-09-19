import 'package:flutter/material.dart';
import 'vo/vo_todo_category.dart';

class TimeRecordFragment extends StatefulWidget {
  final List<TodoCategoryVo> categories;

  const TimeRecordFragment({
    super.key,
    required this.categories,
  });

  @override
  State<TimeRecordFragment> createState() => _TimeRecordFragmentState();
}

class _TimeRecordFragmentState extends State<TimeRecordFragment> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '타임레코드 화면\n(추후 구현 예정)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}