import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class StorageService {
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, profile.name);
    await prefs.setString(AppConstants.keyUserRole, profile.role);
    await prefs.setStringList(AppConstants.keyUserGoals, profile.goals);
    await prefs.setStringList(AppConstants.keyUserModules, profile.modules);
    await prefs.setString(AppConstants.keyUserTheme, profile.appearance);
  }

  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(AppConstants.keyUserName) ?? '';
    final role = prefs.getString(AppConstants.keyUserRole) ?? '';
    final goals = prefs.getStringList(AppConstants.keyUserGoals) ?? [];
    final modules = prefs.getStringList(AppConstants.keyUserModules) ?? [];
    final appearance = prefs.getString(AppConstants.keyUserTheme) ?? 'System';

    return UserProfile(
      name: name,
      role: role,
      goals: goals,
      modules: modules,
      appearance: appearance,
      notificationsPermissionGranted: false, // Permission status resolved dynamically or cached
      usageAccessPermissionGranted: false,
    );
  }

  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasCompletedOnboarding, true);
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
