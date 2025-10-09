import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'f_todo_info_card.dart';
import 'f_todo_view_header.dart';
import 'f_todo_current_view.dart';
import '../../../../common/constant/app_constants.dart';
import '../../../../common/dialog/d_add_todo.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  int _viewIndex = 0; // 0: 할일리스트, 1: 타임레코드
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  String? _selectedCategory; // 선택된 카테고리 (타임레코드 필터링용)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 상단 고정 영역 (InfoCard + ViewHeader)
          SliverToBoxAdapter(
            child: Column(
              children: [
                TodoInfoCardFragment(
                  selectedDate: _selectedDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TodoViewHeaderFragment(
                  viewIndex: _viewIndex,
                  onViewChanged: (newIndex) {
                    setState(() {
                      _viewIndex = newIndex;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 메인 컨텐츠 (할일 리스트 or 타임 레코드)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TodoCurrentViewFragment(
                viewIndex: _viewIndex,
                selectedDate: _selectedDate,
                selectedCategory: _selectedCategory,
                onCategorySelected: (categoryName) {
                  setState(() {
                    // 같은 카테고리를 다시 클릭하면 전체 보기로 변경
                    if (_selectedCategory == categoryName) {
                      _selectedCategory = null;
                    } else {
                      _selectedCategory = categoryName;
                    }
                  });
                },
              ),
            ),
          ),

          // 하단 여백 (FloatingButton 공간 확보)
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => showAddTodoDialog(context, selectedDate: _selectedDate),
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
