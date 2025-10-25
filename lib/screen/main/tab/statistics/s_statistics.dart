import 'package:flutter/material.dart';
import 'package:timedog_test/screen/main/tab/statistics/w_heatmap_calendar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late int _selectedYear;
  DateTime? _selectedDate;
  int _currentYear = DateTime.now().year;
  final int _startYear = 2022;
  late final List<int> _years = List.generate(
    _currentYear - _startYear + 1,
    (i) => _startYear + i,
  );
  late PageController? _yearPageController;

  @override
  void initState() {
    super.initState();
    _yearPageController = PageController(
      initialPage: _years.length - 1,
      viewportFraction: 0.33,
    );

    _selectedYear = _currentYear;
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildYearSelector(),
              _buildTotalSection(),
              _buildLegend(),
              const SizedBox(height: 8),
              HeatmapCalendar(
                year: _selectedYear,
                data: _getDummyData(),
                onDayTap: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          elevation: 0,
          onPressed: () {},
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 50,
        child: PageView.builder(
          controller: _yearPageController,
          onPageChanged: (index) {
            setState(() {
              _selectedYear = _years[index];
            });
          },
          itemCount: _years.length,
          itemBuilder: (context, index) {
            final year = _years[index];
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
    final totalMinutes = 250;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Divider(height: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 16,
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
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Divider(height: 1),
              ),
            ],
          ),
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
}
