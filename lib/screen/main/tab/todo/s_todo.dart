import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'f_todo_info_card.dart';
import 'f_todo_view_header.dart';
import 'f_todo_current_view.dart';
import '../../../../common/constant/app_constants.dart';
import '../../../../common/dialog/d_add_todo.dart';

// 뷰 상태 Provider (상태 유지용)
final todoViewIndexProvider = StateProvider<int>((ref) => 0);
final todoSelectedCategoryProvider = StateProvider<String?>((ref) => null);

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수

    final viewIndex = ref.watch(todoViewIndexProvider);
    final selectedCategory = ref.watch(todoSelectedCategoryProvider);

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
                  viewIndex: viewIndex,
                  onViewChanged: (newIndex) {
                    ref.read(todoViewIndexProvider.notifier).state = newIndex;
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
                viewIndex: viewIndex,
                selectedDate: _selectedDate,
                selectedCategory: selectedCategory,
                onCategorySelected: (categoryName) {
                  // 같은 카테고리를 다시 클릭하면 전체 보기로 변경
                  if (selectedCategory == categoryName) {
                    ref.read(todoSelectedCategoryProvider.notifier).state = null;
                  } else {
                    ref.read(todoSelectedCategoryProvider.notifier).state = categoryName;
                  }
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
