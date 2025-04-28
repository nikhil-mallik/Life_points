import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> defaultActivities;

  Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.defaultActivities,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'description': description,
      'defaultActivities': defaultActivities,
    };
  }
}