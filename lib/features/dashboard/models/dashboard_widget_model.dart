class DashboardWidgetModel {
  final String id;
  final String type; // 'notes', 'tasks', 'habits', 'focus'
  final String size; // 'small', 'medium', 'large'
  final int position;

  DashboardWidgetModel({
    required this.id,
    required this.type,
    required this.size,
    required this.position,
  });

  DashboardWidgetModel copyWith({
    String? id,
    String? type,
    String? size,
    int? position,
  }) {
    return DashboardWidgetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'size': size,
      'position': position,
    };
  }

  factory DashboardWidgetModel.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetModel(
      id: json['id'] as String,
      type: json['type'] as String,
      size: json['size'] as String,
      position: json['position'] as int,
    );
  }
}
