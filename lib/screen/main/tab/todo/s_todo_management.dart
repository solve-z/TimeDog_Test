import 'package:flutter/material.dart';

class TodoManagementScreen extends StatefulWidget {
  const TodoManagementScreen({super.key});

  @override
  State<TodoManagementScreen> createState() => _TodoManagementScreenState();
}

class _TodoManagementScreenState extends State<TodoManagementScreen> {
  final List<TodoCategory> _categories = [
    TodoCategory(
      name: '영어',
      color: Colors.purple,
      totalTime: '0h 00m',
      todos: [
        TodoItem(title: '영어 단어 50개 외우기', time: '0h 00m', isCompleted: false),
        TodoItem(title: '리스닝 5강 듣기', time: '0h 00m', isCompleted: false),
      ],
    ),
    TodoCategory(
      name: '수학',
      color: Colors.yellow.shade700,
      totalTime: '2h 30m',
      todos: [
        TodoItem(title: '미분 문제 10개 풀기', time: '1h 30m', isCompleted: true),
        TodoItem(title: '적분 개념 정리', time: '1h 00m', isCompleted: false),
      ],
    ),
    TodoCategory(
      name: '운동',
      color: Colors.pink,
      totalTime: '1h 00m',
      todos: [
        TodoItem(title: '헬스장 가기', time: '1h 00m', isCompleted: true),
        TodoItem(title: '러닝 30분', time: '0h 00m', isCompleted: false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_categories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Total Time: 4H 30M',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF67575),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Object: 토탈 타임 8시간 이상',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(TodoCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category.totalTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...category.todos.map((todo) => _buildTodoItem(todo)).toList(),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) {
              setState(() {
                todo.isCompleted = value ?? false;
              });
            },
            activeColor: const Color(0xFFF67575),
          ),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 14,
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Text(
            todo.time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class TodoCategory {
  final String name;
  final Color color;
  final String totalTime;
  final List<TodoItem> todos;

  TodoCategory({
    required this.name,
    required this.color,
    required this.totalTime,
    required this.todos,
  });
}

class TodoItem {
  final String title;
  final String time;
  bool isCompleted;

  TodoItem({
    required this.title,
    required this.time,
    required this.isCompleted,
  });
}