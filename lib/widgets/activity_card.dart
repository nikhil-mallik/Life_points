import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isCompleted;
  final VoidCallback onTap;
  
  const ActivityCard({
    Key? key,
    required this.activity,
    this.isCompleted = false,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get screen width to make responsive layouts
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    
    return Card(
      margin: EdgeInsets.only(
        bottom: 16,
        left: isSmallScreen ? 8 : 16,
        right: isSmallScreen ? 8 : 16,
      ),
      // Add a different color for completed activities
      color: activity.isCompleted ? Colors.grey.shade200 : null,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        leading: CircleAvatar(
          backgroundColor: activity.isCompleted 
              ? Colors.grey 
              : Theme.of(context).primaryColor,
          radius: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
          child: Text(
            activity.type == ActivityType.spend 
                ? '-${activity.points}' 
                : '+${activity.points}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : (isMediumScreen ? 12 : 14),
            ),
          ),
        ),
        title: Text(
          activity.name,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
            decoration: activity.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: Text(
          '${activity.type.toString().split('.').last} activity',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        trailing: activity.isCompleted
            ? Icon(
                Icons.check_circle, 
                color: Colors.green,
                size: isSmallScreen ? 20 : 24,
              )
            : IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: onTap,
              ),
      ),
    );
  }
}