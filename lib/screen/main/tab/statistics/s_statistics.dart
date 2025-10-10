import 'package:flutter/material.dart';
import 'w_heatmap_calendar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate;
  PageController? _yearPageController;

  @override
  void initState() {
    super.initState();
    _yearPageController = PageController(
      initialPage: 4, // 과거 4년 + 현재 = index 4
      viewportFraction: 0.33,
    );
  }

  @override
  void dispose() {
    _yearPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildYearSelector(),
            _buildTotalSection(),
            _buildLegend(),
            const SizedBox(height: 8),
            Expanded(
              child: HeatmapCalendar(
                year: _selectedYear,
                data: _getDummyData(),
                onDayTap: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _showDayDetail(date);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          elevation: 0,
          onPressed: _openDetailedStatistics,
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      5,
      (index) => currentYear - 4 + index,
    ); // 과거 4년 + 현재

    if (_yearPageController == null) {
      return const SizedBox(height: 50);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 50,
        child: PageView.builder(
          controller: _yearPageController!,
          onPageChanged: (index) {
            setState(() {
              _selectedYear = years[index];
            });
          },
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            return Center(child: _buildYearTab(year));
          },
        ),
      ),
    );
  }

  Widget _buildYearTab(int year) {
    final isSelected = _selectedYear == year;
    return Text(
      '$year',
      style: TextStyle(
        fontSize: isSelected ? 28 : 18,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.black : Colors.grey[400],
      ),
    );
  }

  Widget _buildTotalSection() {
    final totalMinutes = _calculateTotalMinutes();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Divider(height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${hours}h ${minutes}m',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Divider(height: 1),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildLegendItem('0~2', Colors.green[200]!),
          const SizedBox(width: 4),
          _buildLegendItem('3~6', Colors.green[400]!),
          const SizedBox(width: 4),
          _buildLegendItem('7~10', Colors.green[600]!),
          const SizedBox(width: 4),
          _buildLegendItem('10+', Colors.green[800]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
      ],
    );
  }

  Map<DateTime, int> _getDummyData() {
    // 더미 데이터 생성
    final data = <DateTime, int>{};
    final random = [0, 30, 45, 60, 90, 120, 150, 180];

    for (int month = 1; month <= 12; month++) {
      final daysInMonth = DateTime(_selectedYear, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(_selectedYear, month, day);
        // 랜덤하게 데이터 생성 (약 70%의 날짜에만 데이터 있음)
        if ((day + month) % 3 != 0) {
          data[date] = random[(day * month) % random.length];
        }
      }
    }

    return data;
  }

  int _calculateTotalMinutes() {
    final data = _getDummyData();
    return data.values.fold(0, (sum, minutes) => sum + minutes);
  }

  void _showDayDetail(DateTime date) {
    final minutes = _getDummyData()[date] ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '${date.month}월 ${date.day}일',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '집중시간: ${hours}시간 ${mins}분',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                if (minutes > 0) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '완료한 할일',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 프로젝트 기획서 작성\n• 알고리즘 문제 3개 풀기\n• 운동 30분',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  void _openDetailedStatistics() {
    // TODO: 프리미엄 체크
    final isPremium = false; // 실제로는 상태 관리에서 가져와야 함

    if (!isPremium) {
      _showPremiumDialog();
    } else {
      // TODO: 상세 통계 화면으로 이동
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.lock, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('프리미엄 기능'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상세 통계는 프리미엄 기능입니다.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '프리미엄으로 업그레이드하면:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                _buildPremiumFeature('일간/주간/월간 상세 분석'),
                _buildPremiumFeature('카테고리별 통계'),
                _buildPremiumFeature('시간대별 집중 패턴'),
                _buildPremiumFeature('목표 대비 달성률'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 프리미엄 구매 페이지로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('업그레이드'),
              ),
            ],
          ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
