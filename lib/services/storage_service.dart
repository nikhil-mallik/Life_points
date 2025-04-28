import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _activitiesBoxName = 'activities';
  static const String _activityLogsBoxName = 'activityLogs';
  static const String _userProfileBoxName = 'userProfile';
  
  // Use late variables
  late Box _userProfileBox;
  late Box _activitiesBox;
  late Box _activityLogsBox;
  
  // Initialize boxes in init method
  Future<void> init() async {
    // Ensure boxes are initialized
    _userProfileBox = Hive.box(_userProfileBoxName);
    _activitiesBox = Hive.box(_activitiesBoxName);
    _activityLogsBox = Hive.box(_activityLogsBoxName);
  }
  
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
    
    return isFirstLaunch;
  }
  
  // Activity methods
  Future<List<Activity>> getActivities() async {
    final activities = _activitiesBox.values.toList();
    return activities.cast<Activity>();
  }
  
  Future<void> saveActivity(Activity activity) async {
    await _activitiesBox.put(activity.id, activity);
  }
  
  Future<void> deleteActivity(String id) async {
    await _activitiesBox.delete(id);
  }
  
  // ActivityLog methods
  Future<List<ActivityLog>> getActivityLogs() async {
    final logs = _activityLogsBox.values.toList();
    return logs.cast<ActivityLog>();
  }
  
  Future<void> saveActivityLog(ActivityLog log) async {
    await _activityLogsBox.put(log.id, log);
  }
  
  Future<void> deleteActivityLog(String id) async {
    await _activityLogsBox.delete(id);
  }
  
  // UserProfile methods
  Future<UserProfile?> getUserProfile() async {
    if (_userProfileBox.isEmpty) return null;
    return _userProfileBox.getAt(0);
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_userProfileBox.isEmpty) {
      await _userProfileBox.add(profile);
    } else {
      await _userProfileBox.putAt(0, profile);
    }
  }
  
  Future<void> clearAll() async {
    await _activitiesBox.clear();
    await _activityLogsBox.clear();
    await _userProfileBox.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Move the logActivity method inside the class
  void logActivity(ActivityLog log) {
    try {
      _activityLogsBox.add(log);
    } catch (e) {
      print('Error logging activity: $e');
      // Try to reinitialize the box
      _activityLogsBox = Hive.box('activityLogs');
      // Try again
      try {
        _activityLogsBox.add(log);
      } catch (e) {
        print('Failed to log activity after reinitialization: $e');
      }
    }
  }
}