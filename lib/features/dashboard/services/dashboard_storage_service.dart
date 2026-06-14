import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_widget_model.dart';

class DashboardStorageService {
  static const String _keyDashboardWidgets = 'dashboard_widgets';

  static Future<void> saveWidgets(List<DashboardWidgetModel> widgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = widgets.map((w) => jsonEncode(w.toJson())).toList();
    await prefs.setStringList(_keyDashboardWidgets, jsonList);
  }

  static Future<List<DashboardWidgetModel>> loadWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyDashboardWidgets);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      return jsonList.map((item) {
        final Map<String, dynamic> decoded = jsonDecode(item) as Map<String, dynamic>;
        return DashboardWidgetModel.fromJson(decoded);
      }).toList();
    } catch (e) {
      // Return empty in case of serialization mismatch on version changes
      return [];
    }
  }
}
