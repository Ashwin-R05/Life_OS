import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class ActivityStorageService {
  static const String _keyActivities = 'life_os_note_activities';
  static const int _maxActivities = 20;

  /// Load activity logs
  static Future<List<ActivityModel>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyActivities);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      return jsonList.map((item) {
        final Map<String, dynamic> decoded = jsonDecode(item) as Map<String, dynamic>;
        return ActivityModel.fromJson(decoded);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a new activity log and save it (caps at _maxActivities)
  static Future<List<ActivityModel>> addActivity(ActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await loadActivities();

    // Remove any existing log for the same note and actionType to avoid duplicate spamming
    currentList.removeWhere(
      (a) => a.noteId == activity.noteId && a.actionType == activity.actionType,
    );

    // Insert at the beginning of the list
    currentList.insert(0, activity);

    // Cap the list
    if (currentList.length > _maxActivities) {
      currentList.removeRange(_maxActivities, currentList.length);
    }

    final jsonList = currentList.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyActivities, jsonList);
    return currentList;
  }

  /// Clear all activity logs
  static Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActivities);
  }
}
