import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? primaryGoal;
  int points;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<String> completedActivities;
  final List<String> redeemedRewards;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.primaryGoal,
    this.points = 0,
    required this.createdAt,
    required this.lastUpdated,
    this.completedActivities = const [],
    this.redeemedRewards = const [],
  });

  void addPoints(int amount) {
    points += amount;
  }

  bool spendPoints(int amount) {
    // Add debugging to see what's happening
    print('Current points: $points, Attempting to spend: $amount');
    
    if (points >= amount) {
      points -= amount;
      print('Points spent successfully. Remaining: $points');
      return true;
    }
    
    print('Not enough points. Have: $points, Need: $amount');
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'primaryGoal': primaryGoal,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'completedActivities': completedActivities,
      'redeemedRewards': redeemedRewards,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      primaryGoal: json['primaryGoal'],
      points: json['points'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      completedActivities: List<String>.from(json['completedActivities'] ?? []),
      redeemedRewards: List<String>.from(json['redeemedRewards'] ?? []),
    );
  }
}

// Add this if you're manually creating the adapter
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3; // Use a unique ID that doesn't conflict with other adapters

  @override
  UserProfile read(BinaryReader reader) {
    // Read the fields in the same order they were written
    // Example implementation - adjust based on your UserProfile class
    return UserProfile(
      id: reader.read(),
      name: reader.read(),
      email: reader.read(),
      primaryGoal: reader.read(),
      points: reader.read(),
      createdAt: reader.read(),
      lastUpdated: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    // Write the fields in a consistent order
    // Example implementation - adjust based on your UserProfile class
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.primaryGoal);
    writer.write(obj.points);
    writer.write(obj.createdAt);
    writer.write(obj.lastUpdated);
  }
}