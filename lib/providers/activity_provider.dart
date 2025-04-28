import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../services/storage_service.dart';

class ActivityProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Activity> _activities = [];
  List<ActivityLog> _activityLogs = [];
  
  // For leveling system
  int _xp = 0;
  int _level = 1;
  int _nextLevelThreshold = 100;
  
  // For chain reaction tracking
  List<String> _completedChainActivities = [];
  DateTime? _lastActivityCompletionTime;
  
  // User's primary goal
  String? _primaryGoal;
  
  ActivityProvider(this._storageService) {
    loadActivities();
    _loadActivityLogs();
    _loadXpAndLevel();
    _loadPrimaryGoal();
  }
  
  List<Activity> get activities => _activities;
  List<ActivityLog> get activityLogs => _activityLogs;
  int get xp => _xp;
  int get level => _level;
  int get nextLevelThreshold => _nextLevelThreshold;
  double get levelProgress => _xp / _nextLevelThreshold;
  String? get primaryGoal => _primaryGoal;
  
  List<Activity> get recentActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _activities.where((activity) {
      if (activity.completedAt == null) return true;
      final completedDate = DateTime(
        activity.completedAt!.year,
        activity.completedAt!.month,
        activity.completedAt!.day,
      );
      return completedDate.isAfter(today.subtract(const Duration(days: 7)));
    }).toList();
  }
  
  List<Activity> getActivitiesByType(ActivityType type) {
    return _activities.where((activity) => activity.type == type).toList();
  }
  
  List<Activity> getActivitiesByCategory(String category) {
    return _activities.where((activity) => activity.category == category).toList();
  }
  
  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<ActivityLog> getLogsForActivity(String activityId) {
    return _activityLogs
        .where((log) => log.activityId == activityId)
        .toList();
  }
  
  List<ActivityLog> getLogsForDate(DateTime date) {
    return _activityLogs
        .where((log) => 
            log.timestamp.year == date.year && 
            log.timestamp.month == date.month && 
            log.timestamp.day == date.day)
        .toList();
  }
  
  // Get today's points summary
  Map<String, int> getTodayPointsSummary() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int earned = 0;
    int spent = 0;
    
    for (var log in _activityLogs) {
      if (log.timestamp.year == today.year && 
          log.timestamp.month == today.month && 
          log.timestamp.day == today.day) {
        
        final activity = getActivityById(log.activityId);
        if (activity != null) {
          if (activity.type == ActivityType.spend) {
            spent += activity.points;
          } else {
            earned += log.points;
          }
        }
      }
    }
    
    return {
      'earned': earned,
      'spent': spent,
      'balance': earned - spent,
    };
  }
  
  // d. Time Context Engine
  int getTimeContextPoints(Activity activity) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Study efficiency based on time of day
    if (activity.category == 'Study') {
      if (hour >= 8 && hour < 11) {
        return 6; // Morning study (8-11 AM): 6 points/hour
      } else if (hour >= 14 && hour < 16) {
        return 4; // Afternoon study (2-4 PM): 4 points/hour
      } else if (hour >= 22) {
        return 2; // Late night study (after 10 PM): 2 points/hour
      }
    }
    
    // Entertainment costs based on time
    if (activity.category == 'Entertainment') {
      if (activity.name.contains('Netflix')) {
        return hour < 20 ? 10 : 15; // Netflix before/after 8 PM
      }
      
      if (activity.name.contains('Gaming')) {
        // Gaming progression: +2 points/hour
        final gamingHours = _getGamingHoursToday();
        return activity.points + (gamingHours * 2);
      }
    }
    
    // Food costs based on time (for Weight Loss goal)
    if (_primaryGoal == 'Weight Loss' && activity.category == 'Food') {
      if (activity.name.contains('snack') || activity.name.contains('Snack')) {
        return hour < 19 ? 8 : 15; // Snacks before/after 7 PM
      }
    }
    
    return activity.points;
  }
  
  int _getGamingHoursToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Count gaming activities completed today
    int count = 0;
    for (var log in _activityLogs) {
      if (log.timestamp.year == today.year && 
          log.timestamp.month == today.month && 
          log.timestamp.day == today.day) {
        
        final activity = getActivityById(log.activityId);
        if (activity != null && 
            activity.category == 'Entertainment' && 
            activity.name.contains('Gaming')) {
          count++;
        }
      }
    }
    
    return count;
  }
  
  Future<void> loadActivities() async {
    try {
      final activities = await _storageService.getActivities();
      if (activities.isNotEmpty) {
        _activities = activities;
        notifyListeners();
      } else {
        // Load default activities if none exist
        await _loadDefaultActivities();
      }
    } catch (e) {
      debugPrint('Error loading activities: $e');
      // If there's an error loading activities, initialize with defaults
      await _loadDefaultActivities();
    }
  }
  
  Future<void> _loadActivityLogs() async {
    try {
      final logs = await _storageService.getActivityLogs();
      _activityLogs = logs;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading activity logs: $e');
    }
  }
  
  Future<void> _loadXpAndLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _xp = prefs.getInt('xp') ?? 0;
      _level = prefs.getInt('level') ?? 1;
      _nextLevelThreshold = prefs.getInt('nextLevelThreshold') ?? 100;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading XP and level: $e');
    }
  }
  
  Future<void> _loadPrimaryGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _primaryGoal = prefs.getString('primaryGoal');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading primary goal: $e');
    }
  }
  
  Future<void> setPrimaryGoal(String goal) async {
    try {
      _primaryGoal = goal;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('primaryGoal', goal);
      
      // Adjust activities based on the goal
      await adjustActivitiesForGoal(goal);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting primary goal: $e');
    }
  }
  
  Future<void> _saveXpAndLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('xp', _xp);
      await prefs.setInt('level', _level);
      await prefs.setInt('nextLevelThreshold', _nextLevelThreshold);
    } catch (e) {
      debugPrint('Error saving XP and level: $e');
    }
  }
  
  Future<void> _loadDefaultActivities() async {
    try {
      const uuid = Uuid();
      // Default earn activities
      final defaultEarnActivities = [
        Activity(
          id: uuid.v4(),
          name: 'Wake up at 7 AM',
          points: 3,
          type: ActivityType.daily,
          category: 'Morning Routine',
          isChainable: true,
          chainBonus: 1,
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: '10 minutes meditation',
          points: 2,
          type: ActivityType.daily,
          category: 'Morning Routine',
          isChainable: true,
          chainBonus: 1,
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Make your bed',
          points: 1,
          type: ActivityType.daily,
          category: 'Morning Routine',
          isChainable: true,
          chainBonus: 1,
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Morning run',
          points: 5,
          type: ActivityType.daily,
          category: 'Exercise',
          isChainable: true,
          chainBonus: 2,
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: '30 minutes focused work',
          points: 4,
          type: ActivityType.daily,
          category: 'Work',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Complete a difficult task',
          points: 8,
          type: ActivityType.daily,
          category: 'Work',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Help a colleague',
          points: 3,
          type: ActivityType.daily,
          category: 'Social',
          createdAt: DateTime.now(),
        ),
      ];
      
      // Default spend activities
      final defaultSpendActivities = [
        Activity(
          id: uuid.v4(),
          name: '1 hour of gaming',
          points: 15,
          type: ActivityType.spend,
          category: 'Entertainment',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Social media break',
          points: 5,
          type: ActivityType.spend,
          category: 'Entertainment',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: uuid.v4(),
          name: 'Order takeout',
          points: 25,
          type: ActivityType.spend,
          category: 'Food',
          createdAt: DateTime.now(),
        ),
      ];
      
      _activities = [...defaultEarnActivities, ...defaultSpendActivities];
      
      // Save default activities
      for (var activity in _activities) {
        await _storageService.saveActivity(activity);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading default activities: $e');
    }
  }
  
  Future<void> addActivity(Activity activity) async {
    try {
      await _storageService.saveActivity(activity);
      _activities.add(activity);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding activity: $e');
    }
  }
  
  Future<void> updateActivity(Activity updatedActivity) async {
    try {
      await _storageService.saveActivity(updatedActivity);
      
      final index = _activities.indexWhere((a) => a.id == updatedActivity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating activity: $e');
    }
  }
  
  Future<void> deleteActivity(String activityId) async {
    try {
      await _storageService.deleteActivity(activityId);
      
      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
    }
  }
  
  Future<void> logActivity(ActivityLog log) async {
    try {
      await _storageService.saveActivityLog(log);
      _activityLogs.add(log);
      
      // Mark the activity as completed
      final activity = getActivityById(log.activityId);
      if (activity != null && !activity.isCompleted) {
        activity.complete();
        await updateActivity(activity);
        
        // Add XP for completing the activity
        addXp(log.points);
        
        // Check for chain reaction
        await _checkChainReaction(activity);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }
  
  // c. Chain Reaction Rewards
  Future<void> _checkChainReaction(Activity activity) async {
    final now = DateTime.now();
    
    // Check if this activity is chainable
    if (activity.isChainable) {
      // If this is the first activity in the chain or if the last activity was completed within 30 minutes
      if (_lastActivityCompletionTime == null || 
          now.difference(_lastActivityCompletionTime!).inMinutes <= 30) {
        
        _completedChainActivities.add(activity.id);
        _lastActivityCompletionTime = now;
        
        // Check if we have a complete chain (3 or more activities)
        if (_completedChainActivities.length >= 3) {
          // Calculate bonus points
          int bonus = 0;
          for (var id in _completedChainActivities) {
            final chainActivity = getActivityById(id);
            if (chainActivity != null) {
              bonus += chainActivity.chainBonus;
            }
          }
          
          // Add bonus XP
          addXp(bonus);
          
          // Reset chain
          _completedChainActivities = [];
          _lastActivityCompletionTime = null;
        }
      } else {
        // Reset chain if too much time has passed
        _completedChainActivities = [activity.id];
        _lastActivityCompletionTime = now;
      }
    }
  }
  
  // Add these methods to your ActivityProvider class
  void addXp(int points) {
    _xp += points;
    
    // Check if level up is needed
    while (_xp >= _nextLevelThreshold) {
      _level++;
      _xp -= _nextLevelThreshold;
      _nextLevelThreshold = (_nextLevelThreshold * 1.5).round(); // Increase threshold for next level
    }
    
    notifyListeners();
  }
  
  void spendXp(int points) {
    // Optional: Handle spending XP if needed
    // This might not be necessary depending on your game mechanics
    notifyListeners();
  }
  
  Future<void> adjustActivitiesForGoal(String goal) async {
    try {
      const uuid = Uuid();
      
      // Remove any goal-specific activities
      _activities.removeWhere((a) => 
          a.category == 'Goal: Weight Loss' || 
          a.category == 'Goal: Productivity' ||
          a.category == 'Goal: Learning');
      
      // Add goal-specific activities
      if (goal == 'Weight Loss') {
        final weightLossActivities = [
          Activity(
            id: uuid.v4(),
            name: 'Track calories',
            points: 3,
            type: ActivityType.daily,
            category: 'Goal: Weight Loss',
            isChainable: true,
            chainBonus: 1,
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: '30 minutes cardio',
            points: 5,
            type: ActivityType.daily,
            category: 'Goal: Weight Loss',
            isChainable: true,
            chainBonus: 2,
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Prepare healthy meal',
            points: 4,
            type: ActivityType.daily,
            category: 'Goal: Weight Loss',
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Late night snack',
            points: 15,
            type: ActivityType.spend,
            category: 'Goal: Weight Loss',
            createdAt: DateTime.now(),
          ),
        ];
        
        for (var activity in weightLossActivities) {
          await addActivity(activity);
        }
      } else if (goal == 'Productivity') {
        final productivityActivities = [
          Activity(
            id: uuid.v4(),
            name: 'Plan day in advance',
            points: 3,
            type: ActivityType.daily,
            category: 'Goal: Productivity',
            isChainable: true,
            chainBonus: 1,
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Complete top 3 tasks',
            points: 8,
            type: ActivityType.daily,
            category: 'Goal: Productivity',
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'No phone for 2 hours',
            points: 5,
            type: ActivityType.daily,
            category: 'Goal: Productivity',
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Social media check',
            points: 10,
            type: ActivityType.spend,
            category: 'Goal: Productivity',
            createdAt: DateTime.now(),
          ),
        ];
        
        for (var activity in productivityActivities) {
          await addActivity(activity);
        }
      } else if (goal == 'Learning') {
        final learningActivities = [
          Activity(
            id: uuid.v4(),
            name: 'Read for 30 minutes',
            points: 4,
            type: ActivityType.daily,
            category: 'Goal: Learning',
            isChainable: true,
            chainBonus: 1,
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Complete online course module',
            points: 6,
            type: ActivityType.daily,
            category: 'Goal: Learning',
            createdAt: DateTime.now(),
          ),
          Activity(
            id: uuid.v4(),
            name: 'Practice new skill',
            points: 5,
            type: ActivityType.daily,
            category: 'Goal: Learning',
            createdAt: DateTime.now(),
          ),
        ];
        
        for (var activity in learningActivities) {
          await addActivity(activity);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adjusting activities for goal: $e');
    }
  }
  
  Future<void> resetDailyActivities() async {
    try {
      final dailyActivities = _activities.where((activity) => 
        activity.type == ActivityType.daily || 
        activity.type == ActivityType.positive
      ).toList();
      
      for (var activity in dailyActivities) {
        activity.isCompleted = false;
        activity.completedAt = null;
        await updateActivity(activity);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting daily activities: $e');
    }
  }
}