import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_os/features/focus/controller/focus_controller.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FocusController Tests', () {
    test('init loads default limits and mock usage logs', () async {
      final controller = FocusController();
      await controller.init();

      expect(controller.limits.length, 4);
      expect(controller.limits.any((l) => l.category == 'Social'), true);
      expect(controller.limits.any((l) => l.category == 'Entertainment'), true);
      expect(controller.limits.any((l) => l.category == 'Gaming'), true);
      expect(controller.limits.any((l) => l.category == 'Distraction'), true);

      // 7 days of logs seeded
      expect(controller.usageLogs.length, 7);
      expect(controller.sessions.isEmpty, true);
    });

    test('startFocusSession initializes active timer state', () {
      final controller = FocusController();
      controller.startFocusSession(25, 'Study');

      expect(controller.isActive, true);
      expect(controller.isPaused, false);
      expect(controller.activeCategory, 'Study');
      expect(controller.durationSeconds, 25 * 60);
      expect(controller.remainingSeconds, 25 * 60);
      expect(controller.justCompletedSession, false);
      
      controller.cancelFocusSession();
    });

    test('pauseFocusSession and resumeFocusSession modify paused state', () {
      final controller = FocusController();
      controller.startFocusSession(10, 'Coding');

      controller.pauseFocusSession();
      expect(controller.isPaused, true);

      controller.resumeFocusSession();
      expect(controller.isPaused, false);

      controller.cancelFocusSession();
    });

    test('cancelFocusSession resets all timer values', () {
      final controller = FocusController();
      controller.startFocusSession(20, 'Work');
      controller.cancelFocusSession();

      expect(controller.isActive, false);
      expect(controller.isPaused, false);
      expect(controller.durationSeconds, 0);
      expect(controller.remainingSeconds, 0);
    });

    test('updateCategoryLimit creates or updates limit parameters', () async {
      final controller = FocusController();
      await controller.init();

      // Update existing limit
      await controller.updateCategoryLimit('Social', 15, false);
      final socialLimit = controller.getLimitForCategory('Social');
      expect(socialLimit?.limitMinutes, 15);
      expect(socialLimit?.isActive, false);

      // Create new limit
      await controller.updateCategoryLimit('NewCat', 120, true);
      final newLimit = controller.getLimitForCategory('NewCat');
      expect(newLimit?.limitMinutes, 120);
      expect(newLimit?.isActive, true);
    });

    test('simulateUsage increments category usage minutes', () async {
      final controller = FocusController();
      await controller.init();

      final today = controller.getTodayUsage();
      final initialSocial = today.categoryMinutes['Social'] ?? 0;

      await controller.simulateUsage('Social', 15);
      expect(today.categoryMinutes['Social'], initialSocial + 15);
    });

    test('getInsights generates appropriate screen time warning and productivity tips', () async {
      final controller = FocusController();
      // Do not call init() to start with a completely clean today usage log (0 mins).

      // Initially no focus time
      var insights = controller.getInsights();
      expect(insights.any((i) => i.contains('Try launching a 25-minute study focus block')), true);

      // Simulate being near/over limit
      await controller.updateCategoryLimit('Social', 30, true);
      
      // 80%+ limit warning
      await controller.simulateUsage('Social', 25);
      insights = controller.getInsights();
      expect(insights.any((i) => i.contains('Almost there! Used 80%+')), true);

      // Over limit warning
      await controller.simulateUsage('Social', 10); // now 35, limit is 30
      insights = controller.getInsights();
      expect(insights.any((i) => i.contains('Take a Break! You reached the Daily Limit')), true);

      // Good focus time tip
      await controller.incrementTodayFocusTime(50);
      insights = controller.getInsights();
      expect(insights.any((i) => i.contains('Peak Brain State!')), true);
    });

    test('timer countdown completion records session and updates usage stats', () {
      fakeAsync((async) {
        final controller = FocusController();
        controller.startFocusSession(1, 'Study'); // 1 minute (60 seconds)

        expect(controller.isActive, true);
        expect(controller.remainingSeconds, 60);

        // Elapse 30 seconds
        async.elapse(const Duration(seconds: 30));
        expect(controller.isActive, true);
        expect(controller.remainingSeconds, 30);

        // Elapse remaining 31 seconds (61 seconds total to trigger the 61st timer tick)
        async.elapse(const Duration(seconds: 31));
        
        expect(controller.isActive, false);
        expect(controller.remainingSeconds, 0);
        expect(controller.justCompletedSession, true);
        expect(controller.sessions.length, 1);
        expect(controller.sessions[0].category, 'Study');
        expect(controller.sessions[0].durationMinutes, 1);
        expect(controller.sessions[0].completed, true);

        final today = controller.getTodayUsage();
        expect(today.focusMinutes, 1);
      });
    });
  });
}
