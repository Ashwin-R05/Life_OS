import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/controller/onboarding_controller.dart';
import 'features/onboarding/screens/onboarding_page_view.dart';
import 'features/onboarding/screens/workspace_creation_screen.dart';
import 'features/onboarding/services/storage_service.dart';
import 'features/dashboard/controller/dashboard_controller.dart';
import 'features/notes/controller/notes_controller.dart';
import 'features/search/controller/search_controller.dart' as smart_search;
import 'shared/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user has already completed the onboarding flow
  final hasCompleted = await StorageService.hasCompletedOnboarding();
  
  final onboardingController = OnboardingController();
  
  if (hasCompleted) {
    // Populate controller profile state from local storage
    final profile = await StorageService.getUserProfile();
    onboardingController.initProfile(profile);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<OnboardingController>.value(value: onboardingController),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => smart_search.SearchController()),
      ],
      child: MyApp(initialRoute: hasCompleted ? '/home' : '/onboarding'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OnboardingController>(context);
    final appearance = controller.profile.appearance;

    // Resolve ThemeMode from selection
    ThemeMode themeMode;
    switch (appearance) {
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      case 'Light':
        themeMode = ThemeMode.light;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: {
        '/onboarding': (context) => const OnboardingPageView(),
        '/creating_workspace': (context) => const WorkspaceCreationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
