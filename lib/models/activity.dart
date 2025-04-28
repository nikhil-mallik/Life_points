
import 'package:hive/hive.dart';
part 'activity.g.dart';

@HiveType(typeId: 1)
class Activity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final int points;
  
  @HiveField(4)
  final ActivityType type;
  
  @HiveField(5)
  bool isCompleted;
  
  @HiveField(6)
  DateTime? completedAt;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final String category;
  
  @HiveField(9)
  final bool isChainable;
  
  @HiveField(10)
  final int chainBonus;
  
  @HiveField(11)
  final Map<String, dynamic> progressiveValues;
  
  @HiveField(12)
  final int progressiveWeek;

  Activity({
    required this.id,
    required this.name,
    this.description,
    required this.points,
    required this.type,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.category = 'General',
    this.isChainable = false,
    this.chainBonus = 0,
    this.progressiveValues = const {},
    this.progressiveWeek = 1,
  });

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  Activity copyWith({
    String? id,
    String? name,
    String? description,
    int? points,
    ActivityType? type,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    String? category,
    bool? isChainable,
    int? chainBonus,
    Map<String, dynamic>? progressiveValues,
    int? progressiveWeek,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isChainable: isChainable ?? this.isChainable,
      chainBonus: chainBonus ?? this.chainBonus,
      progressiveValues: progressiveValues ?? this.progressiveValues,
      progressiveWeek: progressiveWeek ?? this.progressiveWeek,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'points': points,
      'type': type.toString(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'isChainable': isChainable,
      'chainBonus': chainBonus,
      'progressiveValues': progressiveValues,
      'progressiveWeek': progressiveWeek,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ActivityType.earn,
      ),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      category: json['category'] ?? 'General',
      isChainable: json['isChainable'] ?? false,
      chainBonus: json['chainBonus'] ?? 0,
      progressiveValues: json['progressiveValues'] ?? {},
      progressiveWeek: json['progressiveWeek'] ?? 1,
    );
  }
}

@HiveType(typeId: 2)
enum ActivityType {
  @HiveField(0)
  earn,
  
  @HiveField(1)
  spend,
  
  @HiveField(2)
  positive,
  
  @HiveField(3)
  negative,
  
  @HiveField(4)
  daily,
  
  @HiveField(5)
  weekly,
  
  @HiveField(6)
  custom,
}