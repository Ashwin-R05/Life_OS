import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session_model.dart';
import '../models/focus_limit_model.dart';
import '../models/usage_log_model.dart';

class FocusStorageService {
  static const String _keySessions = 'life_os_focus_sessions';
  static const String _keyLimits = 'life_os_focus_limits';
  static const String _keyUsageLogs = 'life_os_usage_logs';

  // ── Focus Sessions ────────────────────────────────────────────────
  static Future<List<FocusSessionModel>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keySessions);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList.map((item) {
        return FocusSessionModel.fromJson(jsonDecode(item) as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSessions(List<FocusSessionModel> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_keySessions, jsonList);
  }

  // ── Focus Limits ──────────────────────────────────────────────────
  static Future<List<FocusLimitModel>> loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyLimits);
    if (jsonList == null || jsonList.isEmpty) {
      // Default limits
      return [
        FocusLimitModel(category: 'Social', limitMinutes: 45),
        FocusLimitModel(category: 'Entertainment', limitMinutes: 60),
        FocusLimitModel(category: 'Gaming', limitMinutes: 30),
        FocusLimitModel(category: 'Distraction', limitMinutes: 20),
      ];
    }

    try {
      return jsonList.map((item) {
        return FocusLimitModel.fromJson(jsonDecode(item) as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLimits(List<FocusLimitModel> limits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = limits.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(_keyLimits, jsonList);
  }

  // ── Daily Usage Logs ──────────────────────────────────────────────
  static Future<List<UsageLogModel>> loadUsageLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyUsageLogs);
    
    if (jsonList == null || jsonList.isEmpty) {
      // Seed mock data for the last 7 days if empty
      final list = _generateMockUsageLogs();
      await saveUsageLogs(list);
      return list;
    }

    try {
      return jsonList.map((item) {
        return UsageLogModel.fromJson(jsonDecode(item) as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUsageLogs(List<UsageLogModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = logs.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(_keyUsageLogs, jsonList);
  }

  /// Generate mock weekly history
  static List<UsageLogModel> _generateMockUsageLogs() {
    final List<UsageLogModel> logs = [];
    final now = DateTime.now();

    // Past 7 days
    final mockValues = [
      {'Social': 35, 'Entertainment': 45, 'Gaming': 20, 'Distraction': 15, 'focus': 45}, // 6 days ago
      {'Social': 50, 'Entertainment': 75, 'Gaming': 10, 'Distraction': 25, 'focus': 25}, // 5 days ago
      {'Social': 20, 'Entertainment': 30, 'Gaming': 0, 'Distraction': 10, 'focus': 60},  // 4 days ago
      {'Social': 40, 'Entertainment': 60, 'Gaming': 15, 'Distraction': 30, 'focus': 0},  // 3 days ago
      {'Social': 48, 'Entertainment': 80, 'Gaming': 40, 'Distraction': 22, 'focus': 30}, // 2 days ago
      {'Social': 30, 'Entertainment': 50, 'Gaming': 25, 'Distraction': 10, 'focus': 50}, // 1 day ago
      {'Social': 15, 'Entertainment': 20, 'Gaming': 5, 'Distraction': 8, 'focus': 15},   // Today (starts small)
    ];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final val = mockValues[6 - i];
      
      logs.add(
        UsageLogModel(
          date: DateTime(date.year, date.month, date.day),
          categoryMinutes: {
            'Social': val['Social'] as int,
            'Entertainment': val['Entertainment'] as int,
            'Gaming': val['Gaming'] as int,
            'Distraction': val['Distraction'] as int,
          },
          focusMinutes: val['focus'] as int,
        ),
      );
    }

    return logs;
  }
}
