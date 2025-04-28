// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reward.dart';
import '../../providers/user_provider.dart';
import '../../utils/responsive_util.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userPoints = userProvider.userProfile?.points ?? 0;
    
    // Sample rewards - replace with your actual rewards data
    final List<Reward> rewards = [
      Reward(
        id: '1',
        name: 'Movie Night',
        description: 'Treat yourself to a movie night',
        pointCost: 100,
        icon: Icons.movie,
      ),
      Reward(
        id: '2',
        name: 'Gaming Hour',
        description: 'One hour of guilt-free gaming',
        pointCost: 150,
        icon: Icons.videogame_asset,
      ),
      Reward(
        id: '3',
        name: 'Dessert',
        description: 'Enjoy your favorite dessert',
        pointCost: 200,
        icon: Icons.icecream,
      ),
      Reward(
        id: '4',
        name: 'Sleep In',
        description: 'Sleep in an extra hour',
        pointCost: 250,
        icon: Icons.hotel,
      ),
    ];
    
    // Get screen size for responsive layout
    final isSmallScreen = ResponsiveUtil.isSmallScreen(context);
    final isMediumScreen = ResponsiveUtil.isMediumScreen(context);
    final isLandscape = ResponsiveUtil.isLandscape(context);
    
    // Calculate grid columns based on screen size and orientation
    int crossAxisCount = 2;
    if (isLandscape) {
      crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);
    } else {
      crossAxisCount = isSmallScreen ? 1 : (isMediumScreen ? 2 : 3);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: Column(
        children: [
          // Points balance
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).primaryColor,
                      size: ResponsiveUtil.getIconSize(
                        context,
                        small: 24,
                        medium: 32,
                        large: 40,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Points',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.getFontSize(
                              context,
                              small: 14,
                              medium: 16,
                              large: 18,
                            ),
                          ),
                        ),
                        Text(
                          '$userPoints',
                          style: TextStyle(
                            fontSize: ResponsiveUtil.getFontSize(
                              context,
                              small: 24,
                              medium: 32,
                              large: 40,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Rewards grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.8,
                crossAxisSpacing: isSmallScreen ? 8 : 16,
                mainAxisSpacing: isSmallScreen ? 8 : 16,
              ),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                final bool canAfford = userPoints >= reward.pointCost;
                
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      if (canAfford) {
                        _showRedeemDialog(context, reward, userProvider);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Not enough points to redeem ${reward.name}'),
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                reward.icon,
                                size: ResponsiveUtil.getIconSize(
                                  context,
                                  small: 40,
                                  medium: 60,
                                  large: 80,
                                ),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  reward.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtil.getFontSize(
                                      context,
                                      small: 14,
                                      medium: 16,
                                      large: 18,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${reward.pointCost} points',
                                      style: TextStyle(
                                        color: canAfford ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveUtil.getFontSize(
                                          context,
                                          small: 12,
                                          medium: 14,
                                          large: 16,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      canAfford ? Icons.check_circle : Icons.cancel,
                                      color: canAfford ? Colors.green : Colors.red,
                                      size: ResponsiveUtil.getIconSize(
                                        context,
                                        small: 16,
                                        medium: 20,
                                        large: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRedeemDialog(BuildContext context, Reward reward, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${reward.name}?'),
        content: Text('This will cost ${reward.pointCost} points.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Make sure the result is explicitly cast to bool if needed
              final success = userProvider.spendPoints(reward.pointCost) == true;
              
              if (success) {
                userProvider.recordRedeemedReward(reward.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully redeemed ${reward.name}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not enough points!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}