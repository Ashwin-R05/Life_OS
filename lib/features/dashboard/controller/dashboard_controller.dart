import 'package:flutter/material.dart';
import '../models/dashboard_widget_model.dart';
import '../services/dashboard_storage_service.dart';

class DashboardController extends ChangeNotifier {
  List<DashboardWidgetModel> _activeWidgets = [];
  bool _isEditMode = false;

  List<DashboardWidgetModel> get activeWidgets => _activeWidgets;
  bool get isEditMode => _isEditMode;

  // Initial default layout
  static final List<DashboardWidgetModel> defaultLayout = [
    DashboardWidgetModel(id: 'default_tasks', type: 'tasks', size: 'medium', position: 0),
    DashboardWidgetModel(id: 'default_habits', type: 'habits', size: 'small', position: 1),
    DashboardWidgetModel(id: 'default_notes', type: 'notes', size: 'small', position: 2),
    DashboardWidgetModel(id: 'default_focus', type: 'focus', size: 'large', position: 3),
  ];

  Future<void> initDashboard() async {
    final stored = await DashboardStorageService.loadWidgets();
    if (stored.isEmpty) {
      _activeWidgets = List.from(defaultLayout);
      await DashboardStorageService.saveWidgets(_activeWidgets);
    } else {
      _activeWidgets = stored;
      _activeWidgets.sort((a, b) => a.position.compareTo(b.position));
    }
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  Future<void> addWidget(String type, String size) async {
    final uniqueId = 'widget_${type}_${DateTime.now().millisecondsSinceEpoch}';
    final newPosition = _activeWidgets.isEmpty ? 0 : _activeWidgets.last.position + 1;
    
    final newWidget = DashboardWidgetModel(
      id: uniqueId,
      type: type,
      size: size,
      position: newPosition,
    );

    _activeWidgets.add(newWidget);
    await DashboardStorageService.saveWidgets(_activeWidgets);
    notifyListeners();
  }

  Future<void> removeWidget(String id) async {
    _activeWidgets.removeWhere((w) => w.id == id);
    _normalizePositions();
    await DashboardStorageService.saveWidgets(_activeWidgets);
    notifyListeners();
  }

  Future<void> resizeWidget(String id, String size) async {
    final index = _activeWidgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _activeWidgets[index] = _activeWidgets[index].copyWith(size: size);
      await DashboardStorageService.saveWidgets(_activeWidgets);
      notifyListeners();
    }
  }

  Future<void> reorderWidgets(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _activeWidgets.length || newIndex < 0 || newIndex >= _activeWidgets.length) {
      return;
    }
    
    final item = _activeWidgets.removeAt(oldIndex);
    _activeWidgets.insert(newIndex, item);
    _normalizePositions();
    await DashboardStorageService.saveWidgets(_activeWidgets);
    notifyListeners();
  }

  Future<void> moveWidgetUp(String id) async {
    final index = _activeWidgets.indexWhere((w) => w.id == id);
    if (index > 0) {
      final temp = _activeWidgets[index];
      _activeWidgets[index] = _activeWidgets[index - 1];
      _activeWidgets[index - 1] = temp;
      _normalizePositions();
      await DashboardStorageService.saveWidgets(_activeWidgets);
      notifyListeners();
    }
  }

  Future<void> moveWidgetDown(String id) async {
    final index = _activeWidgets.indexWhere((w) => w.id == id);
    if (index != -1 && index < _activeWidgets.length - 1) {
      final temp = _activeWidgets[index];
      _activeWidgets[index] = _activeWidgets[index + 1];
      _activeWidgets[index + 1] = temp;
      _normalizePositions();
      await DashboardStorageService.saveWidgets(_activeWidgets);
      notifyListeners();
    }
  }

  void _normalizePositions() {
    for (int i = 0; i < _activeWidgets.length; i++) {
      _activeWidgets[i] = _activeWidgets[i].copyWith(position: i);
    }
  }
}
