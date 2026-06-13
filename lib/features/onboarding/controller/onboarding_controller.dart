import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class OnboardingController extends ChangeNotifier {
  UserProfile _profile = UserProfile.empty();
  int _currentStep = 0;
  final PageController _pageController = PageController();

  UserProfile get profile => _profile;
  int get currentStep => _currentStep;
  PageController get pageController => _pageController;

  // Total steps in onboarding (welcome to permissions)
  static const int totalSteps = 7; // Welcome, Name, Role, Goals, Modules, Appearance, Permissions

  bool get isNameValid => _profile.name.trim().isNotEmpty;

  void initProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void updateName(String name) {
    _profile = _profile.copyWith(name: name);
    notifyListeners();
  }

  void updateRole(String role) {
    _profile = _profile.copyWith(role: role);
    notifyListeners();
  }

  void toggleGoal(String goalId) {
    final currentGoals = List<String>.from(_profile.goals);
    if (currentGoals.contains(goalId)) {
      currentGoals.remove(goalId);
    } else {
      if (currentGoals.length < 3) {
        currentGoals.add(goalId);
      }
    }
    _profile = _profile.copyWith(goals: currentGoals);
    notifyListeners();
  }

  void toggleModule(String moduleId) {
    final currentModules = List<String>.from(_profile.modules);
    if (currentModules.contains(moduleId)) {
      currentModules.remove(moduleId);
    } else {
      currentModules.add(moduleId);
    }
    _profile = _profile.copyWith(modules: currentModules);
    notifyListeners();
  }

  void updateAppearance(String theme) {
    _profile = _profile.copyWith(appearance: theme);
    notifyListeners();
  }

  void updateNotificationPermission(bool granted) {
    _profile = _profile.copyWith(notificationsPermissionGranted: granted);
    notifyListeners();
  }

  void updateUsageAccessPermission(bool granted) {
    _profile = _profile.copyWith(usageAccessPermissionGranted: granted);
    notifyListeners();
  }

  void nextStep(BuildContext context) {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      notifyListeners();
    } else {
      // Navigate to Workspace Creation Loader Screen
      Navigator.pushNamed(context, '/creating_workspace');
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<void> saveProfileAndComplete() async {
    await StorageService.saveUserProfile(_profile);
    await StorageService.completeOnboarding();
  }

  Future<void> resetOnboarding(BuildContext context) async {
    await StorageService.clearAll();
    _profile = UserProfile.empty();
    _currentStep = 0;
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }
}
