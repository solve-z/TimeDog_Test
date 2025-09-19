import 'package:flutter/material.dart';
import 'vo_todo_item.dart';

class TodoCategoryVo {
  final String name;
  final Color color;
  final Color accentColor;
  final Color backgroundColor;
  final String totalTime;
  final List<TodoItemVo> todos;

  TodoCategoryVo({
    required this.name,
    required this.color,
    required this.accentColor,
    required this.backgroundColor,
    required this.totalTime,
    required this.todos,
  });
}