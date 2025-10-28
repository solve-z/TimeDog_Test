import 'package:flutter/material.dart';

class CategoryVo {
  final String name;
  final Color color;
  final Color accentColor;
  final bool isArchived; // 보관 상태
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryVo({
    required this.name,
    required this.color,
    required this.accentColor,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryVo copyWith({
    String? name,
    Color? color,
    Color? accentColor,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryVo(
      name: name ?? this.name,
      color: color ?? this.color,
      accentColor: accentColor ?? this.accentColor,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'accentColor': accentColor.value,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory CategoryVo.fromJson(Map<String, dynamic> json) {
    return CategoryVo(
      name: json['name'],
      color: Color(json['color']),
      accentColor: Color(json['accentColor']),
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
