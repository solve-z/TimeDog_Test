import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timedog_test/screen/main/tab/statistics/w_heatmap_calendar.dart';
import 'package:timedog_test/services/statistics_data_service.dart';

import '../../../../common/utils/app_logger.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late int _selectedYear;
  DateTime? _selectedDate;
  final int _currentYear = DateTime.now().year;
  final int _startYear = 2022;
  late List<int> _years;
  late PageController? _yearPageController;

  Map<DateTime, int> _yearData = {}; // 연도별 데이터 캐시
  bool _isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();

    _selectedYear = _currentYear;
    _years = List.generate(
      _currentYear - _startYear + 1,
      (index) => _startYear + index,
    );

    final initialIndex = _years.indexOf(_selectedYear);

    _yearPageController = PageController(
      initialPage: _years.length - 1,
      viewportFraction: 0.33,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    AppLogger.statistics.d('_loadData 시작: $_selectedYear');
    setState(() => _isLoading = true);
    try {
      _yearData = await _loadYearData(_selectedYear); // ← _loadYearData 사용
      AppLogger.statistics.d('데이터 로드 완료: ${_yearData.length}개 날짜');
      _yearData.forEach((date, minutes) {
        AppLogger.statistics.d(
          '${date.toString().substring(0, 10)}: ${minutes}분',
        );
      });
    } catch (e) {
      _yearData = {};
    }
    setState(() => _isLoading = false);
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
              _isLoading
                  ? const SizedBox(
                    height: 400, // 로딩 인디케이터 높이 지정
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : HeatmapCalendar(
                    year: _selectedYear,
                    data: _yearData,
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
            _loadData();
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
    final totalMinutes = _yearData.values.fold(
      0,
      (sum, minutes) => sum + minutes,
    );
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

  Future<Map<DateTime, int>> _loadYearData(int year) async {
    final service = ref.read(statisticsDataServiceProvider);
    return await service.getYearData(year);
  }
}
