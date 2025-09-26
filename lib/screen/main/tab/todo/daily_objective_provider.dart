import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vo/vo_daily_objective.dart';

class DailyObjectiveNotifier extends StateNotifier<DailyObjectiveState> {
  DailyObjectiveNotifier() : super(DailyObjectiveState(objectives: {})) {
    _loadObjectives();
  }

  static const String _objectivesKey = 'daily_objectives_key';

  Future<void> _loadObjectives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final objectivesJson = prefs.getString(_objectivesKey);

      if (objectivesJson != null) {
        final Map<String, dynamic> objectivesMap = json.decode(objectivesJson);
        final objectives = <String, DailyObjectiveVo>{};

        objectivesMap.forEach((key, value) {
          objectives[key] = DailyObjectiveVo.fromJson(value);
        });

        state = state.copyWith(objectives: objectives);
      }
    } catch (e) {
      print('Failed to load objectives: $e');
    }
  }

  Future<void> _saveObjectives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final objectivesMap = <String, dynamic>{};

      state.objectives.forEach((key, objective) {
        objectivesMap[key] = objective.toJson();
      });

      final objectivesJson = json.encode(objectivesMap);
      await prefs.setString(_objectivesKey, objectivesJson);
    } catch (e) {
      print('Failed to save objectives: $e');
    }
  }

  Future<void> setObjective(DateTime date, String objective) async {
    final dateKey = _getDateKey(date);
    final now = DateTime.now();

    final newObjective = DailyObjectiveVo(
      id: '${dateKey}_objective',
      date: DateTime(date.year, date.month, date.day),
      objective: objective,
      createdAt: state.objectives[dateKey]?.createdAt ?? now,
      updatedAt: now,
    );

    final updatedObjectives = Map<String, DailyObjectiveVo>.from(state.objectives);
    updatedObjectives[dateKey] = newObjective;

    state = state.copyWith(objectives: updatedObjectives);
    await _saveObjectives();
  }

  String getObjective(DateTime date) {
    final dateKey = _getDateKey(date);
    return state.objectives[dateKey]?.objective ?? '';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class DailyObjectiveState {
  final Map<String, DailyObjectiveVo> objectives;

  DailyObjectiveState({required this.objectives});

  DailyObjectiveState copyWith({
    Map<String, DailyObjectiveVo>? objectives,
  }) {
    return DailyObjectiveState(
      objectives: objectives ?? this.objectives,
    );
  }
}

final dailyObjectiveProvider = StateNotifierProvider<DailyObjectiveNotifier, DailyObjectiveState>((ref) {
  return DailyObjectiveNotifier();
});