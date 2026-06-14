class UsageLogModel {
  final DateTime date;
  final Map<String, int> categoryMinutes; // e.g. {'Social': 45, 'Entertainment': 60, 'Gaming': 15, 'Distraction': 30}
  final int focusMinutes; // minutes spent in focus mode

  UsageLogModel({
    required this.date,
    required this.categoryMinutes,
    required this.focusMinutes,
  });

  int get totalMinutes {
    int sum = categoryMinutes.values.fold(0, (prev, val) => prev + val);
    return sum;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'categoryMinutes': categoryMinutes,
      'focusMinutes': focusMinutes,
    };
  }

  factory UsageLogModel.fromJson(Map<String, dynamic> json) {
    final rawMinutes = json['categoryMinutes'] as Map<String, dynamic>;
    final parsedMinutes = rawMinutes.map((k, v) => MapEntry(k, v as int));
    
    return UsageLogModel(
      date: DateTime.parse(json['date'] as String),
      categoryMinutes: parsedMinutes,
      focusMinutes: json['focusMinutes'] as int? ?? 0,
    );
  }
}
