class ActivityModel {
  final String id;
  final String noteId;
  final String noteTitle;
  final String actionType; // 'created' | 'updated' | 'viewed'
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.noteId,
    required this.noteTitle,
    required this.actionType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'noteTitle': noteTitle,
      'actionType': actionType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      noteTitle: json['noteTitle'] as String,
      actionType: json['actionType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
