import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/activity.dart';
import 'models/activity_log.dart';
import 'models/user_profile.dart';
import 'providers/activity_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'themes/app_theme.dart';

// In your initialization code (likely in main() function)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register the ActivityType adapter
  Hive.registerAdapter(ActivityTypeAdapter());
  
  // Register other adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ActivityAdapter());
  Hive.registerAdapter(ActivityLogAdapter());
  
  // Open boxes
  await Hive.openBox('userProfile');
  await Hive.openBox('activities');
  await Hive.openBox('activityLogs');
  
  // Create a storage service instance
  final storageService = StorageService();
  await storageService.init();
  
  // Use the initialized storageService
  runApp(MyApp(storageService: storageService));
}


class MyApp extends StatelessWidget {
  final StorageService storageService;
  final bool isFirstLaunch;
  
  const MyApp({
    Key? key, 
    required this.storageService,
    this.isFirstLaunch = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LifePoints',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: OnboardingScreen(isFirstLaunch: isFirstLaunch),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}