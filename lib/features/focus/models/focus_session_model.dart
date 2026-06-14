class FocusSessionModel {
  final String id;
  final int durationMinutes;
  final String category; // 'Study' | 'Work' | 'Coding' | 'Reading'
  final bool completed;
  final DateTime startedAt;

  FocusSessionModel({
    required this.id,
    required this.durationMinutes,
    required this.category,
    required this.completed,
    required this.startedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'category': category,
      'completed': completed,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] as String,
      durationMinutes: json['durationMinutes'] as int,
      category: json['category'] as String,
      completed: json['completed'] as bool,
      startedAt: DateTime.parse(json['startedAt'] as String),
    );
  }
}
