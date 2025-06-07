import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final List<String> taskIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.taskIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: IconData(map['icon'] ?? Icons.dashboard_rounded.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? 0xFFE91E63),
      isDefault: map['isDefault'] ?? false,
      taskIds: List<String>.from(map['taskIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'isDefault': isDefault,
      'taskIds': taskIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isDefault,
    List<String>? taskIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      taskIds: taskIds ?? this.taskIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Lista de categorias padrão
  static List<Category> get defaultCategories => [
    Category(
      id: 'default_1',
      name: 'Abandonar hábito',
      icon: Icons.do_disturb_rounded,
      color: const Color(0xFFE53935),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_2',
      name: 'Arte',
      icon: Icons.brush_rounded,
      color: const Color(0xFFEC407A),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_3',
      name: 'Tarefa',
      icon: Icons.access_time_rounded,
      color: const Color(0xFFAD1457),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_4',
      name: 'Meditação',
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFFAB47BC),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_5',
      name: 'Estudos',
      icon: Icons.school_rounded,
      color: const Color(0xFF7E57C2),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_6',
      name: 'Esportes',
      icon: Icons.directions_bike_rounded,
      color: const Color(0xFF5C6BC0),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_7',
      name: 'Entretenimento',
      icon: Icons.star_rounded,
      color: const Color(0xFF00ACC1),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_8',
      name: 'Social',
      icon: Icons.forum_rounded,
      color: const Color(0xFF00897B),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_9',
      name: 'Finança',
      icon: Icons.attach_money_rounded,
      color: const Color(0xFF66BB6A),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_10',
      name: 'Saúde',
      icon: Icons.add_rounded,
      color: const Color(0xFF9CCC65),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_11',
      name: 'Trabalho',
      icon: Icons.work_rounded,
      color: const Color(0xFF8D6E63),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_12',
      name: 'Nutrição',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFFF8A65),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_13',
      name: 'Casa',
      icon: Icons.home_rounded,
      color: const Color(0xFFFF7043),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_14',
      name: 'Ar livre',
      icon: Icons.terrain_rounded,
      color: const Color(0xFFFF6E40),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'default_15',
      name: 'Outros',
      icon: Icons.dashboard_rounded,
      color: const Color(0xFFEF5350),
      isDefault: true,
      taskIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
