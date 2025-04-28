import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  final StorageService _storageService;
  UserProfile? _userProfile;
  Goal? _selectedGoal;
  bool _onboardingComplete = false;
  bool _notificationsEnabled = true;

  UserProfile? get userProfile => _userProfile;
  Goal? get selectedGoal => _selectedGoal;
  bool get onboardingComplete => _onboardingComplete;
  int get points => _userProfile?.points ?? 0;
  bool? get notificationsEnabled => _notificationsEnabled;

  UserProvider(this._storageService) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load onboarding status
      final prefs = await SharedPreferences.getInstance();
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      
      // Load user profile
      final userProfile = await _storageService.getUserProfile();
      if (userProfile != null) {
        _userProfile = userProfile;
      }
      
      // Load selected goal
      final goalJson = prefs.getString('selectedGoal');
      if (goalJson != null) {
        try {
          final goalMap = json.decode(goalJson);
          // Add this method to your UserProvider class
          IconData getIconFromCodePoint(int codePoint) {
            // Map code points to constant icons
            switch (codePoint) {
              case 0xe3af: return Icons.fitness_center;
              case 0xe80c: return Icons.school;
              case 0xe8f9: return Icons.work;
              // Add more mappings as needed
              default: return Icons.star; // Default icon
            }
          }
          
          // Then use it in your goal creation:
          _selectedGoal = Goal(
            id: goalMap['id'],
            name: goalMap['name'],
            icon: getIconFromCodePoint(goalMap['iconCodePoint']),
            color: Color(goalMap['colorValue']),
            description: goalMap['description'],
            defaultActivities: List<String>.from(goalMap['defaultActivities'] ?? []),
          );
        } catch (e) {
          debugPrint('Error parsing goal: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> createInitialProfile(String name, String email, Goal? goal) async {
    try {
      final profile = UserProfile(
        id: const Uuid().v4(),
        name: name,
        email: email,
        primaryGoal: goal?.id,
        points: 0,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      
      await updateUserProfile(profile);
      
      if (goal != null) {
        await setUserGoal(goal);
      }
    } catch (e) {
      debugPrint('Error creating initial profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      _userProfile = profile;
      
      // Use StorageService instead of SharedPreferences
      await _storageService.saveUserProfile(profile);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  Future<void> setUserGoal(Goal goal) async {
    try {
      _selectedGoal = goal;
      
      // Update the user profile with the goal
      if (_userProfile != null) {
        final updatedProfile = UserProfile(
          id: _userProfile!.id,
          name: _userProfile!.name,
          email: _userProfile!.email,
          points: _userProfile!.points,
          primaryGoal: goal.id,
          createdAt: _userProfile!.createdAt,
          lastUpdated: DateTime.now(),
          completedActivities: _userProfile!.completedActivities,
          redeemedRewards: _userProfile!.redeemedRewards,
        );
        
        await updateUserProfile(updatedProfile);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedGoal', json.encode({
        'id': goal.id,
        'name': goal.name,
        'iconCodePoint': goal.icon.codePoint,
        'colorValue': goal.color.value,
        'description': goal.description,
        'defaultActivities': goal.defaultActivities,
      }));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user goal: $e');
    }
  }

  Future<void> completeOnboarding() async {
    try {
      _onboardingComplete = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  // After updating points
  Future<void> addPoints(int amount) async {
    try {
      final user = await _storageService.getUserProfile();
      if (user != null) {
        user.addPoints(amount);
        await _storageService.saveUserProfile(user);
        
        // Update local state to match storage
        _userProfile = user;
        
        notifyListeners(); // Make sure this is called
      }
    } catch (e) {
      debugPrint('Error adding points: $e');
    }
  }

  Future<bool> spendPoints(int amount) async {
    try {
      if (_userProfile != null) {
        if (_userProfile!.spendPoints(amount)) {
          // Use the storage service instead of SharedPreferences directly
          await _storageService.saveUserProfile(_userProfile!);
          
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error spending points: $e');
      return false;
    }
  }

  Future<void> recordCompletedActivity(String activity) async {
    try {
      if (_userProfile != null) {
        if (!_userProfile!.completedActivities.contains(activity)) {
          _userProfile!.completedActivities.add(activity);
          
          // Use StorageService instead of SharedPreferences
          await _storageService.saveUserProfile(_userProfile!);
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error recording completed activity: $e');
    }
  }

  Future<void> recordRedeemedReward(String reward) async {
    try {
      if (_userProfile != null) {
        if (!_userProfile!.redeemedRewards.contains(reward)) {
          _userProfile!.redeemedRewards.add(reward);
          
          // Use StorageService instead of SharedPreferences
          await _storageService.saveUserProfile(_userProfile!);
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error recording redeemed reward: $e');
    }
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveNotificationPreference();
    notifyListeners();
  }

  Future<void> _saveNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  Future<void> signOut() async {
    // Clear user data
    _userProfile = null;
    _selectedGoal = null;
    
    // Reset preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', false);
    await prefs.remove('selectedGoal');
    
    // Clear storage
    await _storageService.clearAll();
    
    notifyListeners();
  }
}