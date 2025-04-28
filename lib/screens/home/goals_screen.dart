import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity.dart';
import '../onboarding/goal_selection_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final currentGoal = activityProvider.primaryGoal;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current goal card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flag,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Goal',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currentGoal ?? 'No goal set',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoalSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(currentGoal == null ? 'Set a Goal' : 'Change Goal'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Goal-specific activities
          if (currentGoal != null) ...[
            const Text(
              'Goal Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalActivities(context, activityProvider, currentGoal),
          ],
          
          const SizedBox(height: 24),
          
          // Goal progress
          if (currentGoal != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Goal Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGoalProgress(context, activityProvider, currentGoal),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Goal suggestions
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Goal Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGoalSuggestions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalActivities(BuildContext context, ActivityProvider provider, String goalName) {
    final goalCategory = 'Goal: $goalName';
    final activities = provider.getActivitiesByCategory(goalCategory);
    
    if (activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No goal-specific activities found'),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: activity.type == ActivityType.spend
                  ? Colors.red.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              child: Icon(
                activity.type == ActivityType.spend
                    ? Icons.remove
                    : Icons.add,
                color: activity.type == ActivityType.spend
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            title: Text(activity.name),
            subtitle: Text('${activity.points} points'),
            trailing: activity.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined),
            onTap: () {
              // Handle activity tap
              if (!activity.isCompleted) {
                _showCompleteActivityDialog(context, activity, provider);
              }
            },
          ),
        );
      },
    );
  }
  
  Widget _buildGoalProgress(BuildContext context, ActivityProvider provider, String goalName) {
    final goalCategory = 'Goal: $goalName';
    final activities = provider.getActivitiesByCategory(goalCategory);
    
    if (activities.isEmpty) {
      return const Center(
        child: Text('No goal-specific activities found'),
      );
    }
    
    final completedCount = activities.where((a) => a.isCompleted).length;
    final totalCount = activities.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedCount of $totalCount activities completed (${(progress * 100).toStringAsFixed(0)}%)',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalSuggestions(BuildContext context) {
    final suggestions = [
      {
        'title': 'Weight Loss',
        'description': 'Track your fitness and eating habits',
        'icon': Icons.fitness_center,
        'color': Colors.green,
      },
      {
        'title': 'Productivity',
        'description': 'Improve your work efficiency and time management',
        'icon': Icons.work,
        'color': Colors.blue,
      },
      {
        'title': 'Learning',
        'description': 'Develop new skills and knowledge',
        'icon': Icons.school,
        'color': Colors.purple,
      },
      {
        'title': 'Mindfulness',
        'description': 'Improve mental health and reduce stress',
        'icon': Icons.self_improvement,
        'color': Colors.teal,
      },
    ];
    
    return Column(
      children: suggestions.map((suggestion) => Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: suggestion['color'] as Color,
            child: Icon(
              suggestion['icon'] as IconData,
              color: Colors.white,
            ),
          ),
          title: Text(suggestion['title'] as String),
          subtitle: Text(suggestion['description'] as String),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GoalSelectionScreen(),
              ),
            );
          },
        ),
      )).toList(),
    );
  }
  
  void _showCompleteActivityDialog(
    BuildContext context,
    Activity activity,
    ActivityProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete ${activity.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You will ${activity.type == ActivityType.spend ? 'spend' : 'earn'} ${activity.points} points.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create activity log
              final log = ActivityLog(
                id: const Uuid().v4(),
                activityId: activity.id,
                timestamp: DateTime.now(),
                points: activity.points,
              );
              
              // Log the activity
              provider.logActivity(log);
              
              // Close dialog
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${activity.name} completed!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}