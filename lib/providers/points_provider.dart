import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_log.dart';
import '../services/storage_service.dart';

class PointsProvider with ChangeNotifier {
  final StorageService _storageService;
  
  int _todayEarned = 0;
  int _todaySpent = 0;
  int _totalPoints = 0;
  
  // For leveling system
  int _xp = 0;
  int _level = 1;
  int _nextLevelThreshold = 100;
  
  // Level titles
  final List<String> _levelTitles = [
    'Beginner',
    'Focus Hero',
    'Habit Master',
    'Productivity Ninja',
    'Life Champion',
    'Transformation Guru',
    'Ultimate Achiever',
  ];
  
  PointsProvider(this._storageService) {
    _loadPointsData();
  }
  
  int get todayEarned => _todayEarned;
  int get todaySpent => _todaySpent;
  int get todayBalance => _todayEarned - _todaySpent;
  int get totalPoints => _totalPoints;
  
  int get xp => _xp;
  int get level => _level;
  int get nextLevelThreshold => _nextLevelThreshold;
  double get levelProgress => _xp / _nextLevelThreshold;
  String get levelTitle => _levelTitles[(_level - 1) % _levelTitles.length];
  
  Future<void> _loadPointsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalPoints = prefs.getInt('totalPoints') ?? 0;
      _xp = prefs.getInt('xp') ?? 0;
      _level = prefs.getInt('level') ?? 1;
      _nextLevelThreshold = prefs.getInt('nextLevelThreshold') ?? 100;
      
      // Calculate today's points
      await _calculateTodayPoints();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading points data: $e');
    }
  }
  
  Future<void> _calculateTodayPoints() async {
    try {
      final logs = await _storageService.getActivityLogs();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      _todayEarned = 0;
      _todaySpent = 0;
      
      for (var log in logs) {
        if (log.timestamp.year == today.year && 
            log.timestamp.month == today.month && 
            log.timestamp.day == today.day) {
          
          if (log.points > 0) {
            _todayEarned += log.points;
          } else {
            _todaySpent += log.points.abs();
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error calculating today points: $e');
    }
  }
  
  Future<void> addPoints(int amount) async {
    try {
      _totalPoints += amount;
      _todayEarned += amount;
      
      // Add XP
      await addXP(amount);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalPoints', _totalPoints);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding points: $e');
    }
  }
  
  Future<bool> spendPoints(int amount) async {
    try {
      if (_totalPoints >= amount) {
        _totalPoints -= amount;
        _todaySpent += amount;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('totalPoints', _totalPoints);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error spending points: $e');
      return false;
    }
  }
  
  // Light Leveling System
  Future<void> addXP(int amount) async {
    _xp += amount;
    
    // Check for level up
    if (_xp >= _nextLevelThreshold) {
      await levelUp();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('xp', _xp);
      notifyListeners();
    }
  }
  
  Future<void> levelUp() async {
    _level++;
    _xp = _xp - _nextLevelThreshold;
    _nextLevelThreshold = (_nextLevelThreshold * 1.5).round(); // Increase threshold for next level
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', _level);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('nextLevelThreshold', _nextLevelThreshold);
    
    notifyListeners();
  }
  
  // Get level up message
  String getLevelUpMessage() {
    return 'Level $_level: ${levelTitle} 🎉!';
  }
}