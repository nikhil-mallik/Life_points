import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _timeRange = 'Week';
  
  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level progress card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          Icons.trending_up,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Level',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Level ${activityProvider.level}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: activityProvider.levelProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activityProvider.xp} / ${activityProvider.nextLevelThreshold} XP to next level',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Points chart
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Points History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _timeRange,
                        items: ['Week', 'Month', 'Year'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _timeRange = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPointsChart(activityProvider),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Activity categories
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryStats(activityProvider),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivity(activityProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPointsChart(ActivityProvider provider) {
    // Get data based on selected time range
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_timeRange) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }
    
    // Filter logs by date range
    final logs = provider.activityLogs.where(
      (log) => log.timestamp.isAfter(startDate) && log.timestamp.isBefore(now.add(const Duration(days: 1)))
    ).toList();
    
    // Group logs by day
    final Map<String, int> earnedByDay = {};
    final Map<String, int> spentByDay = {};
    
    for (var log in logs) {
      final activity = provider.getActivityById(log.activityId);
      if (activity == null) continue;
      
      final day = DateFormat('MM/dd').format(log.timestamp);
      
      if (activity.type == ActivityType.spend) {
        spentByDay[day] = (spentByDay[day] ?? 0) + log.points;
      } else {
        earnedByDay[day] = (earnedByDay[day] ?? 0) + log.points;
      }
    }
    
    // Create chart data
    final List<FlSpot> earnedSpots = [];
    final List<FlSpot> spentSpots = [];
    
    // Generate dates for x-axis
    final List<String> dates = [];
    int daysToShow = _timeRange == 'Week' ? 7 : (_timeRange == 'Month' ? 30 : 12);
    
    for (int i = 0; i < daysToShow; i++) {
      final date = now.subtract(Duration(days: daysToShow - i - 1));
      final formattedDate = DateFormat('MM/dd').format(date);
      dates.add(formattedDate);
      
      earnedSpots.add(FlSpot(i.toDouble(), (earnedByDay[formattedDate] ?? 0).toDouble()));
      spentSpots.add(FlSpot(i.toDouble(), (spentByDay[formattedDate] ?? 0).toDouble()));
    }
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  // Show fewer labels for better readability
                  if (_timeRange == 'Week' || value.toInt() % 5 == 0) {
                    return Text(
                      dates[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        lineBarsData: [
          LineChartBarData(
            spots: earnedSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
          ),
          LineChartBarData(
            spots: spentSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final String text = spot.barIndex == 0 ? 'Earned: ${spot.y.toInt()}' : 'Spent: ${spot.y.toInt()}';
                return LineTooltipItem(
                  text,
                  TextStyle(
                    color: spot.barIndex == 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryStats(ActivityProvider provider) {
    // Count activities by category
    final Map<String, int> categoryCounts = {};
    
    for (var log in provider.activityLogs) {
      final activity = provider.getActivityById(log.activityId);
      if (activity != null) {
        categoryCounts[activity.category] = (categoryCounts[activity.category] ?? 0) + 1;
      }
    }
    
    if (categoryCounts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No activity data available'),
        ),
      );
    }
    
    return Column(
      children: categoryCounts.entries.map((entry) {
        final percentage = (entry.value / provider.activityLogs.length) * 100;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(entry.key)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentActivity(ActivityProvider provider) {
    // In your recent activity section, make sure you're not filtering by type
    // Instead of something like:
    // final recentActivities = activityProvider.activityLogs.where((log) => 
    //     activityProvider.getActivityById(log.activityId)?.type != ActivityType.spend).toList();
    
    // Use this instead:
    final recentLogs = provider.activityLogs;
    
    if (recentLogs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent activity'),
        ),
      );
    }
    
    // When displaying the activity in your ListView
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentLogs.length,
      itemBuilder: (context, index) {
        final log = recentLogs[index];
        final activity = provider.getActivityById(log.activityId);
        
        if (activity == null) return const SizedBox.shrink();
        
        return ListTile(
          title: Text(activity.name),
          subtitle: Text(DateFormat.yMd().add_jm().format(log.timestamp)),
          trailing: Text(
            activity.type == ActivityType.spend 
                ? '-${activity.points}' 
                : '+${log.points}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: activity.type == ActivityType.spend 
                  ? Colors.red 
                  : Colors.green,
            ),
          ),
        );
      },
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Health':
        return Colors.green;
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.purple;
      case 'Entertainment':
        return Colors.orange;
      case 'Social':
        return Colors.pink;
      case 'Food':
        return Colors.red;
      default:
        if (category.startsWith('Goal:')) {
          return Colors.teal;
        }
        return Colors.grey;
    }
  }
}