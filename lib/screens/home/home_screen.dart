import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/activity.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/point_balance_widget.dart';
import '../../widgets/activity_card.dart';
import 'package:uuid/uuid.dart';

import '../activities/add_activity_screen.dart';
import '../settings/settings_screen.dart';
import 'goals_screen.dart';
import 'stats_screen.dart';

// Global variable to store the points balance
int globalPointsBalance = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: Activities, Stats, Goals
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final pointsSummary = activityProvider.getTodayPointsSummary();
    // Update the global variable with the current balance
    globalPointsBalance = pointsSummary['balance'] ?? 0;
    
    // Update the user profile points with the global balance
    if (userProvider.userProfile != null) {
      userProvider.userProfile!.points = globalPointsBalance;
    }
    
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activities'),
            Tab(text: 'Stats'),
            Tab(text: 'Goals'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: PointBalanceWidget(
              label: 'Available Points',
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                    value: pointsSummary['earned'] ?? 0,
                    label: 'Earned Today',
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                    value: pointsSummary['spent'] ?? 0,
                    label: 'Spent Today',
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    icon: pointsSummary['balance']! >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: pointsSummary['balance']! >= 0
                        ? Colors.green
                        : Colors.red,
                    value: pointsSummary['balance'] ?? 0,
                    label: 'Net Today',
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivitiesTab(context, activityProvider, userProvider),
                const StatsScreen(),
                const GoalsScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddActivityScreen(
                activityType: ActivityType.custom,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required int value,
    required String label,
    required bool isSmallScreen,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(
    BuildContext context,
    ActivityProvider activityProvider,
    UserProvider userProvider,
  ) {
    final earnActivities = activityProvider.getActivitiesByType(ActivityType.earn);
    final dailyActivities = activityProvider.getActivitiesByType(ActivityType.daily);
    final spendActivities = activityProvider.getActivitiesByType(ActivityType.spend);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dailyActivities.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Daily Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyActivities.length,
              itemBuilder: (context, index) {
                final activity = dailyActivities[index];
                return ActivityCard(
                  activity: activity,
                  isCompleted: activity.isCompleted,
                  onTap: () => _handleActivityTap(context, activity),
                );
              },
            ),
          ],
          if (earnActivities.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Earn Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: earnActivities.length,
              itemBuilder: (context, index) {
                final activity = earnActivities[index];
                return ActivityCard(
                  activity: activity,
                  isCompleted: activity.isCompleted,
                  onTap: () => _handleActivityTap(context, activity),
                );
              },
            ),
          ],
          if (spendActivities.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Spend Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spendActivities.length,
              itemBuilder: (context, index) {
                final activity = spendActivities[index];
                return ActivityCard(
                  activity: activity,
                  onTap: () => _handleActivityTap(context, activity),
                );
              },
            ),
          ],
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  void _handleActivityTap(BuildContext context, Activity activity) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (activity.type == ActivityType.spend) {
      // Use globalPointsBalance instead of userProvider.userProfile?.points
      userProvider.userProfile?.points = globalPointsBalance;
      if (globalPointsBalance < activity.points || globalPointsBalance < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough points!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Spend Points'),
          content: Text('Are you sure you want to spend ${activity.points} points on ${activity.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _completeActivity(context, activity);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      _completeActivity(context, activity);
    }
  }

  void _completeActivity(BuildContext context, Activity activity) {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!activity.isCompleted) {
      final updatedActivity = activity.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      activityProvider.updateActivity(updatedActivity);

      final log = ActivityLog(
        id: const Uuid().v4(),
        activityId: activity.id,
        timestamp: DateTime.now(),
        points: activity.points,
      );

      activityProvider.logActivity(log);

      if (activity.type == ActivityType.spend) {
        userProvider.spendPoints(activity.points);
        // Also update XP in ActivityProvider
        activityProvider.spendXp(activity.points);
      } else {
        userProvider.addPoints(activity.points);
        // Also update XP in ActivityProvider
        activityProvider.addXp(activity.points);
      }
      
      // Update global points balance and sync with user profile
      globalPointsBalance = userProvider.userProfile?.points ?? 0;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activity.type == ActivityType.spend
                ? 'Spent ${activity.points} points on ${activity.name}'
                : 'Earned ${activity.points} points from ${activity.name}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${activity.name} is already completed today'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
