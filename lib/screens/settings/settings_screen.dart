import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/theme_provider.dart';
import '../onboarding/goal_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User profile section
          if (userProvider.userProfile != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(userProvider.userProfile!.name),
              subtitle: Text(userProvider.userProfile!.email),
            ),
            const Divider(),
          ],
          
          // Theme settings
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          
          // Goal settings
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Change Goal'),
            subtitle: Text(activityProvider.primaryGoal ?? 'No goal set'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
              );
            },
          ),
          
          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: userProvider.notificationsEnabled ?? false,
              onChanged: (value) {
                userProvider.toggleNotifications();
              },
            ),
          ),
          
          // Reset progress
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: const Text('Reset Daily Activities'),
            subtitle: const Text('Mark all daily activities as incomplete'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Daily Activities'),
                  content: const Text('Are you sure you want to reset all daily activities? This will mark them as incomplete.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        activityProvider.resetDailyActivities();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily activities reset')),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        userProvider.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}