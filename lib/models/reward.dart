import 'package:flutter/material.dart';

class Reward {
  final String id;
  final String name;
  final String description;
  final int pointCost;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointCost,
    required this.icon,
    this.color = Colors.blue,
    this.isUnlocked = true,
  });

  // Create a copy of this reward with modified properties
  Reward copyWith({
    String? id,
    String? name,
    String? description,
    int? pointCost,
    IconData? icon,
    Color? color,
    bool? isUnlocked,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pointCost: pointCost ?? this.pointCost,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}