import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/activity.dart';
import '../activities/add_activity_screen.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Custom'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ActivityList(type: ActivityType.daily),
                _ActivityList(type: ActivityType.weekly),
                _ActivityList(type: ActivityType.custom),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddActivityScreen(activityType: _tabController.index == 0 ? ActivityType.daily : _tabController.index == 1 ? ActivityType.weekly : ActivityType.custom),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Remove this enum definition
// enum ActivityType { daily, weekly, custom }

class _ActivityList extends StatelessWidget {
  final ActivityType type;
  
  const _ActivityList({Key? key, required this.type}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final goal = userProvider.selectedGoal;
    
    if (goal == null) {
      return const Center(
        child: Text('No goal selected. Please set a goal first.'),
      );
    }
    
    // For demo purposes, we'll use the default activities from the goal
    // In a real app, you'd have a more sophisticated activity management system
    final activities = goal.defaultActivities.map((activity) {
      final parts = activity.split(':');
      final name = parts[0].trim();
      final pointsText = parts[1].trim();
      final points = int.parse(pointsText.split(' ')[0]);
      
      return Activity(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        points: points,
        type: type,
        isCompleted: false,
        createdAt: DateTime.now(),
        description: null,
        category: 'General',
        isChainable: false,
        chainBonus: 0,
        progressiveValues: const {},
        progressiveWeek: 1,
      );
    }).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '+${activity.points}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(activity.name),
            subtitle: Text('${type.toString().split('.').last} activity'),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {
                _completeActivity(context, activity);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _completeActivity(BuildContext context, Activity activity) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      await userProvider.addPoints(activity.points);
      await userProvider.recordCompletedActivity(activity.name);
      
      if (!context.mounted) return;
      
      // Show a success animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You earned ${activity.points} points!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Show confetti or some celebration animation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Great job!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'You completed "${activity.name}" and earned ${activity.points} points!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}