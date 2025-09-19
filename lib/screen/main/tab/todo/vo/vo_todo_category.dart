import 'package:flutter/material.dart';
import 'vo_todo_item.dart';

class TodoCategoryVo {
  final String name;
  final Color color;
  final String totalTime;
  final List<TodoItemVo> todos;

  TodoCategoryVo({
    required this.name,
    required this.color,
    required this.totalTime,
    required this.todos,
  });
}