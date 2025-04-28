import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../providers/user_provider.dart';


class PointBalanceWidget extends StatelessWidget {
  final String label;

   PointBalanceWidget({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('PointBalanceWidget build called'); // <-- 🔵 Add this to see when widget rebuilds
 final activityProvider = Provider.of<ActivityProvider>(context);
  // Get today's points summary
    final pointsSummary = activityProvider.getTodayPointsSummary();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    print('User Points Updated: ${userProvider.userProfile?.points ?? 0}'); // <-- 🔵 Add this inside Consumer to track points
                    return Text(
                      '${pointsSummary['balance']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
