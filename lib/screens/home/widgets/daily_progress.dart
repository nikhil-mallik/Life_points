import 'package:flutter/material.dart';

class DailyProgress extends StatelessWidget {
  const DailyProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This would be connected to actual data in a real implementation
    const double progressPercentage = 0.65;
    const int pointsToday = 45;
    const int targetPoints = 70;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$pointsToday/$targetPoints points',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey[200],
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}