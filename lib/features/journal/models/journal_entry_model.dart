class JournalEntryModel {
  final String id;
  final String content;
  final String mood; // 'Great', 'Good', 'Okay', 'Bad', 'Terrible'
  final DateTime createdAt;

  JournalEntryModel({
    required this.id,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  JournalEntryModel copyWith({
    String? id,
    String? content,
    String? mood,
    DateTime? createdAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
