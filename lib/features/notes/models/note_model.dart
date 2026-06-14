class NoteModel {
  final String id;
  final String title;
  final String content;
  final String folder; // 'All', 'Study', 'Ideas', 'Knowledge', 'Projects'
  final bool isPinned;
  final List<String> attachmentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.folder,
    this.isPinned = false,
    this.attachmentIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? folder,
    bool? isPinned,
    List<String>? attachmentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folder: folder ?? this.folder,
      isPinned: isPinned ?? this.isPinned,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'folder': folder,
      'isPinned': isPinned,
      'attachmentIds': attachmentIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      folder: json['folder'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      attachmentIds: (json['attachmentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
