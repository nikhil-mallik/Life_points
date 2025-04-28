import 'package:flutter/material.dart';
import '../../../models/activity.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  final Function(Activity) onActivityCompleted;
  
  const ActivityList({
    Key? key,
    required this.activities,
    required this.onActivityCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some activities to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: activity.type == ActivityType.positive || activity.type == ActivityType.earn
                  ? Colors.green
                  : Colors.red,
              child: Text(
                activity.type == ActivityType.positive || activity.type == ActivityType.earn
                    ? '+${activity.points}'
                    : '-${activity.points}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(activity.name),
            subtitle: Text(activity.description ?? ''),
            trailing: activity.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      onActivityCompleted(activity);
                    },
                  ),
          ),
        );
      },
    );
  }
}