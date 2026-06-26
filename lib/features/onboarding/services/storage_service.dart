import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> saveUserProfile(UserProfile profile) async {
    await _secureStorage.write(key: AppConstants.keyUserName, value: profile.name);
    await _secureStorage.write(key: AppConstants.keyUserRole, value: profile.role);
    await _secureStorage.write(key: AppConstants.keyUserGoals, value: jsonEncode(profile.goals));
    await _secureStorage.write(key: AppConstants.keyUserModules, value: jsonEncode(profile.modules));
    await _secureStorage.write(key: AppConstants.keyUserTheme, value: profile.appearance);
  }

  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if migration is needed
    if (prefs.containsKey(AppConstants.keyUserName)) {
      await _migrateFromSharedPreferences(prefs);
    }

    final name = await _secureStorage.read(key: AppConstants.keyUserName) ?? '';
    final role = await _secureStorage.read(key: AppConstants.keyUserRole) ?? '';

    final goalsStr = await _secureStorage.read(key: AppConstants.keyUserGoals);
    final goals = goalsStr != null ? List<String>.from(jsonDecode(goalsStr)) : <String>[];

    final modulesStr = await _secureStorage.read(key: AppConstants.keyUserModules);
    final modules = modulesStr != null ? List<String>.from(jsonDecode(modulesStr)) : <String>[];

    final appearance = await _secureStorage.read(key: AppConstants.keyUserTheme) ?? 'System';

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
    await _secureStorage.write(key: AppConstants.keyHasCompletedOnboarding, value: 'true');
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if migration is needed
    if (prefs.containsKey(AppConstants.keyHasCompletedOnboarding)) {
      await _migrateFromSharedPreferences(prefs);
    }

    final value = await _secureStorage.read(key: AppConstants.keyHasCompletedOnboarding);
    return value == 'true';
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  static Future<void> _migrateFromSharedPreferences(SharedPreferences prefs) async {
    final hasCompleted = prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false;
    if (hasCompleted) {
      await _secureStorage.write(key: AppConstants.keyHasCompletedOnboarding, value: 'true');
    }

    final name = prefs.getString(AppConstants.keyUserName);
    if (name != null) {
      await _secureStorage.write(key: AppConstants.keyUserName, value: name);
    }

    final role = prefs.getString(AppConstants.keyUserRole);
    if (role != null) {
      await _secureStorage.write(key: AppConstants.keyUserRole, value: role);
    }

    final goals = prefs.getStringList(AppConstants.keyUserGoals);
    if (goals != null) {
      await _secureStorage.write(key: AppConstants.keyUserGoals, value: jsonEncode(goals));
    }

    final modules = prefs.getStringList(AppConstants.keyUserModules);
    if (modules != null) {
      await _secureStorage.write(key: AppConstants.keyUserModules, value: jsonEncode(modules));
    }

    final appearance = prefs.getString(AppConstants.keyUserTheme);
    if (appearance != null) {
      await _secureStorage.write(key: AppConstants.keyUserTheme, value: appearance);
    }

    // Clean up migrated keys
    await prefs.remove(AppConstants.keyHasCompletedOnboarding);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyUserGoals);
    await prefs.remove(AppConstants.keyUserModules);
    await prefs.remove(AppConstants.keyUserTheme);
  }
}
