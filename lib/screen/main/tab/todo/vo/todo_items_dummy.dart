import 'package:flutter/material.dart';
import 'vo_todo_category.dart';
import 'vo_todo_item.dart';

final List<TodoCategoryVo> todoItems = [
  TodoCategoryVo(
    name: '영어',
    color: const Color(0xFFD9B5FF),
    totalTime: '0h 00m',
    todos: [
      TodoItemVo(title: '영어 단어 50개 외우기', time: '0h 00m', isCompleted: false),
      TodoItemVo(title: '리스닝 5강 듣기', time: '0h 00m', isCompleted: false),
    ],
  ),
  TodoCategoryVo(
    name: '수학',
    color: const Color(0xFFB6D6FF),
    totalTime: '0h 00m',
    todos: [
      TodoItemVo(title: '수학의 정석 2단원 풀기', time: '0h 00m', isCompleted: true),
      TodoItemVo(title: '오답노트 복습하기', time: '0h 00m', isCompleted: true),
    ],
  ),
  TodoCategoryVo(
    name: '운동',
    color: const Color(0xFFFFBDD0),
    totalTime: '0h 00m',
    todos: [
      TodoItemVo(title: '러닝 30분 뛰기', time: '0h 00m', isCompleted: true),
    ],
  ),
];