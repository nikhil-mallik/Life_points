import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';  // Add this import

part 'activity_log.g.dart';

@HiveType(typeId: 4)
class ActivityLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String activityId;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final int points;
  
  @HiveField(4)
  final bool isChainCompleted;
  
  @HiveField(5)
  final int chainBonus;
  
  @HiveField(6)
  final String? notes;

  ActivityLog({
    required this.id,
    required this.activityId,
    required this.timestamp,
    required this.points,
    this.isChainCompleted = false,
    this.chainBonus = 0,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'timestamp': timestamp.toIso8601String(),
      'points': points,
      'isChainCompleted': isChainCompleted,
      'chainBonus': chainBonus,
      'notes': notes,
    };
  }
  
  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      activityId: json['activityId'],
      timestamp: DateTime.parse(json['timestamp']),
      points: json['points'],
      isChainCompleted: json['isChainCompleted'] ?? false,
      chainBonus: json['chainBonus'] ?? 0,
      notes: json['notes'],
    );
  }
}

@HiveType(typeId: 2)
class ActivityLogV2 {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String activityId;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final int points;
  
  @HiveField(4)
  final bool isChainCompleted;
  
  @HiveField(5)
  final int chainBonus;
  
  @HiveField(6)
  final String notes;

  ActivityLogV2({
    String? id,
    required this.activityId,
    required this.timestamp,
    required this.points,
    this.isChainCompleted = false,
    this.chainBonus = 0,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();
}