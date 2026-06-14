import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_os/features/dashboard/controller/dashboard_controller.dart';
import 'package:life_os/features/dashboard/models/dashboard_widget_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DashboardController Tests', () {
    test('initDashboard loads default widgets when storage is empty', () async {
      final controller = DashboardController();
      expect(controller.activeWidgets.isEmpty, true);

      await controller.initDashboard();

      expect(controller.activeWidgets.length, 4);
      expect(controller.activeWidgets[0].type, 'tasks');
      expect(controller.activeWidgets[1].type, 'habits');
      expect(controller.activeWidgets[2].type, 'notes');
      expect(controller.activeWidgets[3].type, 'focus');
    });

    test('addWidget appends a widget at the end', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      final initialCount = controller.activeWidgets.length;

      await controller.addWidget('notes', 'small');

      expect(controller.activeWidgets.length, initialCount + 1);
      expect(controller.activeWidgets.last.type, 'notes');
      expect(controller.activeWidgets.last.size, 'small');
      expect(controller.activeWidgets.last.position, initialCount);
    });

    test('removeWidget deletes the target widget and normalizes positions', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      final initialCount = controller.activeWidgets.length;
      final targetId = controller.activeWidgets[1].id;

      await controller.removeWidget(targetId);

      expect(controller.activeWidgets.length, initialCount - 1);
      expect(controller.activeWidgets.any((w) => w.id == targetId), false);
      
      // Verify positions are normalized (0, 1, 2...)
      for (int i = 0; i < controller.activeWidgets.length; i++) {
        expect(controller.activeWidgets[i].position, i);
      }
    });

    test('resizeWidget changes target widget size correctly', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      final targetId = controller.activeWidgets[0].id;

      await controller.resizeWidget(targetId, 'large');

      expect(controller.activeWidgets[0].size, 'large');
    });

    test('reorderWidgets swaps indices and normalizes positions', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      
      final firstId = controller.activeWidgets[0].id;
      final secondId = controller.activeWidgets[1].id;

      await controller.reorderWidgets(0, 1);

      expect(controller.activeWidgets[0].id, secondId);
      expect(controller.activeWidgets[1].id, firstId);
      expect(controller.activeWidgets[0].position, 0);
      expect(controller.activeWidgets[1].position, 1);
    });

    test('moveWidgetUp swaps position with predecessor', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      
      final secondId = controller.activeWidgets[1].id;
      final firstId = controller.activeWidgets[0].id;

      await controller.moveWidgetUp(secondId);

      expect(controller.activeWidgets[0].id, secondId);
      expect(controller.activeWidgets[1].id, firstId);
    });

    test('moveWidgetDown swaps position with successor', () async {
      final controller = DashboardController();
      await controller.initDashboard();
      
      final firstId = controller.activeWidgets[0].id;
      final secondId = controller.activeWidgets[1].id;

      await controller.moveWidgetDown(firstId);

      expect(controller.activeWidgets[0].id, secondId);
      expect(controller.activeWidgets[1].id, firstId);
    });
  });
}
