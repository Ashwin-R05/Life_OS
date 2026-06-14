import 'dart:async';
import 'package:flutter/material.dart';
import '../models/focus_session_model.dart';
import '../models/focus_limit_model.dart';
import '../models/usage_log_model.dart';
import '../services/focus_storage_service.dart';

class FocusController extends ChangeNotifier {
  List<FocusSessionModel> _sessions = [];
  List<FocusLimitModel> _limits = [];
  List<UsageLogModel> _usageLogs = [];

  // Active Timer State
  Timer? _timer;
  int _durationSeconds = 0;
  int _remainingSeconds = 0;
  bool _isActive = false;
  bool _isPaused = false;
  String _activeCategory = 'Study';
  DateTime? _sessionStartTime;
  bool _justCompletedSession = false;

  // Getters
  List<FocusSessionModel> get sessions => _sessions;
  List<FocusLimitModel> get limits => _limits;
  List<UsageLogModel> get usageLogs => _usageLogs;

  int get durationSeconds => _durationSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  String get activeCategory => _activeCategory;
  bool get justCompletedSession => _justCompletedSession;

  // Available focus categories
  static const List<Map<String, dynamic>> focusCategories = [
    {'name': 'Study', 'emoji': '📚', 'color': Color(0xFF6366F1)},
    {'name': 'Work', 'emoji': '💼', 'color': Color(0xFF3B82F6)},
    {'name': 'Coding', 'emoji': '💻', 'color': Color(0xFF10B981)},
    {'name': 'Reading', 'emoji': '📖', 'color': Color(0xFFF59E0B)},
  ];

  /// Initialize state from local storage
  Future<void> init() async {
    _sessions = await FocusStorageService.loadSessions();
    _limits = await FocusStorageService.loadLimits();
    _usageLogs = await FocusStorageService.loadUsageLogs();
    notifyListeners();
  }

  // ── Focus Session Countdown logic ────────────────────────────────
  void startFocusSession(int minutes, String category) {
    if (_isActive) return;

    _durationSeconds = minutes * 60;
    _remainingSeconds = _durationSeconds;
    _activeCategory = category;
    _isActive = true;
    _isPaused = false;
    _sessionStartTime = DateTime.now();
    _justCompletedSession = false;

    _startTimer();
    notifyListeners();
  }

  void pauseFocusSession() {
    if (!_isActive || _isPaused) return;

    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  void resumeFocusSession() {
    if (!_isActive || !_isPaused) return;

    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  void cancelFocusSession() {
    _timer?.cancel();
    _isActive = false;
    _isPaused = false;
    _durationSeconds = 0;
    _remainingSeconds = 0;
    notifyListeners();
  }

  void resetCompletionFlag() {
    _justCompletedSession = false;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeFocusSession();
      }
    });
  }

  Future<void> _completeFocusSession() async {
    _timer?.cancel();
    _isActive = false;
    _isPaused = false;

    final now = DateTime.now();
    final durationMinutes = _durationSeconds ~/ 60;

    final session = FocusSessionModel(
      id: 'focus_${now.millisecondsSinceEpoch}',
      durationMinutes: durationMinutes,
      category: _activeCategory,
      completed: true,
      startedAt: _sessionStartTime ?? now,
    );

    _sessions.add(session);
    await FocusStorageService.saveSessions(_sessions);

    // Update today's usage stats
    await incrementTodayFocusTime(durationMinutes);

    _durationSeconds = 0;
    _remainingSeconds = 0;
    _justCompletedSession = true;
    notifyListeners();
  }

  // ── Usage Tracking & Limits ──────────────────────────────────────
  FocusLimitModel? getLimitForCategory(String cat) {
    try {
      return _limits.firstWhere((l) => l.category == cat);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateCategoryLimit(String category, int minutes, bool isActive) async {
    final index = _limits.indexWhere((l) => l.category == category);
    if (index != -1) {
      _limits[index] = _limits[index].copyWith(limitMinutes: minutes, isActive: isActive);
    } else {
      _limits.add(FocusLimitModel(category: category, limitMinutes: minutes, isActive: isActive));
    }
    await FocusStorageService.saveLimits(_limits);
    notifyListeners();
  }

  /// Get or create today's usage log
  UsageLogModel getTodayUsage() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    try {
      return _usageLogs.firstWhere(
        (log) => log.date.year == todayStart.year &&
            log.date.month == todayStart.month &&
            log.date.day == todayStart.day,
      );
    } catch (_) {
      // Create new one for today if missing
      final newLog = UsageLogModel(
        date: todayStart,
        categoryMinutes: {
          'Social': 0,
          'Entertainment': 0,
          'Gaming': 0,
          'Distraction': 0,
        },
        focusMinutes: 0,
      );
      _usageLogs.add(newLog);
      FocusStorageService.saveUsageLogs(_usageLogs);
      return newLog;
    }
  }

  /// Add simulated time to a category (useful to demonstrate limit warning popup triggers)
  Future<void> simulateUsage(String category, int minutes) async {
    final today = getTodayUsage();
    final currentMinutes = today.categoryMinutes[category] ?? 0;
    today.categoryMinutes[category] = currentMinutes + minutes;
    
    await FocusStorageService.saveUsageLogs(_usageLogs);
    notifyListeners();
  }

  Future<void> incrementTodayFocusTime(int minutes) async {
    final today = getTodayUsage();
    final currentFocus = today.focusMinutes;
    final updatedLog = UsageLogModel(
      date: today.date,
      categoryMinutes: today.categoryMinutes,
      focusMinutes: currentFocus + minutes,
    );

    final index = _usageLogs.indexWhere(
      (log) => log.date.year == today.date.year &&
          log.date.month == today.date.month &&
          log.date.day == today.date.day,
    );

    if (index != -1) {
      _usageLogs[index] = updatedLog;
    }
    await FocusStorageService.saveUsageLogs(_usageLogs);
    notifyListeners();
  }

  // ── Insights & Analytics ─────────────────────────────────────────
  List<String> getInsights() {
    final List<String> insights = [];
    final today = getTodayUsage();

    // Limit warning
    for (final limit in _limits) {
      if (limit.isActive) {
        final used = today.categoryMinutes[limit.category] ?? 0;
        if (used >= limit.limitMinutes) {
          insights.add('⚠️ Take a Break! You reached the Daily Limit for "${limit.category}" (${limit.limitMinutes}m).');
        } else if (used >= limit.limitMinutes * 0.8) {
          insights.add('⚠️ Almost there! Used 80%+ of today\'s limit for "${limit.category}" (${used}m / ${limit.limitMinutes}m).');
        }
      }
    }

    // Productivity Insights
    if (today.focusMinutes > 40) {
      insights.add('🧠 Peak Brain State! Today\'s focus session total is excellent (${today.focusMinutes}m).');
    } else if (today.focusMinutes == 0) {
      insights.add('💡 Tip: Try launching a 25-minute study focus block today to kickstart work.');
    }

    // Weekly trend insight
    if (_usageLogs.length >= 2) {
      final yesterdayFocus = _usageLogs[_usageLogs.length - 2].focusMinutes;
      if (today.focusMinutes > yesterdayFocus && yesterdayFocus > 0) {
        insights.add('📈 Climbing Up! Your focus score is higher today compared to yesterday.');
      }
    }

    if (insights.isEmpty) {
      insights.add('✨ Keep it up! Staying conscious of screen limits improves productivity.');
      insights.add('📚 Use Focus Mode blocks to organize study sprints.');
    }

    return insights;
  }
}
