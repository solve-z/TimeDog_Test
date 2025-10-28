class DailyObjectiveVo {
  final String id;
  final DateTime date;
  final String objective;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyObjectiveVo({
    required this.id,
    required this.date,
    required this.objective,
    required this.createdAt,
    required this.updatedAt,
  });

  DailyObjectiveVo copyWith({
    String? id,
    DateTime? date,
    String? objective,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyObjectiveVo(
      id: id ?? this.id,
      date: date ?? this.date,
      objective: objective ?? this.objective,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'objective': objective,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DailyObjectiveVo.fromJson(Map<String, dynamic> json) {
    return DailyObjectiveVo(
      id: json['id'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      objective: json['objective'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}