import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'f_todo_info_card.dart';
import 'f_todo_view_header.dart';
import 'f_todo_current_view.dart';
import '../../../../common/constant/app_constants.dart';
import '../../../../common/dialog/d_add_todo.dart';
import '../../../../common/utils/date_utils.dart';

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
  DateTime _selectedDate = AppDateUtils.getAppToday(); // 앱 기준 오늘 날짜
  late PageController _pageController;

  // 기준 날짜 (2020-01-01)
  final DateTime _baseDate = DateTime(2020, 1, 1);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 초기 페이지를 앱 기준 오늘 날짜로 설정
    final initialPage = _selectedDate.difference(_baseDate).inDays;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수

    final viewIndex = ref.watch(todoViewIndexProvider);
    final selectedCategory = ref.watch(todoSelectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16), // 추가,
            // 상단 고정 영역 (InfoCard + ViewHeader)
            TodoInfoCardFragment(
              selectedDate: _selectedDate,
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
                // PageView도 해당 날짜로 이동
                final newPage = newDate.difference(_baseDate).inDays;
                _pageController.jumpToPage(newPage);
              },
            ),
            const SizedBox(height: 12),
            TodoViewHeaderFragment(
              viewIndex: viewIndex,
              selectedDate: _selectedDate,
              onViewChanged: (newIndex) {
                ref.read(todoViewIndexProvider.notifier).state = newIndex;
              },
              onTodayPressed: () {
                final today = AppDateUtils.getAppToday();
                setState(() {
                  _selectedDate = today;
                });
                final todayPage = today.difference(_baseDate).inDays;
                _pageController.jumpToPage(todayPage);
              },
              onAddTodoPressed: () {
                showAddTodoDialog(context, selectedDate: _selectedDate);
              },
            ),
            const SizedBox(height: 12),

            // 메인 컨텐츠 (PageView로 좌우 스크롤 가능)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _selectedDate = _baseDate.add(Duration(days: index));
                  });
                },
                itemBuilder: (context, index) {
                  final currentDate = _baseDate.add(Duration(days: index));
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: TodoCurrentViewFragment(
                      viewIndex: viewIndex,
                      selectedDate: currentDate,
                      selectedCategory: selectedCategory,
                      onCategorySelected: (categoryName) {
                        // 같은 카테고리를 다시 클릭하면 전체 보기로 변경
                        if (selectedCategory == categoryName) {
                          ref
                              .read(todoSelectedCategoryProvider.notifier)
                              .state = null;
                        } else {
                          ref
                              .read(todoSelectedCategoryProvider.notifier)
                              .state = categoryName;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
