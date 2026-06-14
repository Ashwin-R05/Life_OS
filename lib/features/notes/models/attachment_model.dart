class AttachmentModel {
  final String id;
  final String noteId;
  final String fileName;
  final String filePath;
  final String fileType; // 'pdf', 'jpg', 'jpeg', 'png', 'txt', 'docx'
  final int fileSize; // bytes
  final DateTime addedAt;

  AttachmentModel({
    required this.id,
    required this.noteId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.addedAt,
  });

  AttachmentModel copyWith({
    String? id,
    String? noteId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? addedAt,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Human-readable file size
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Whether this is an image type
  bool get isImage => ['jpg', 'jpeg', 'png'].contains(fileType.toLowerCase());

  /// Whether this is a text file
  bool get isText => fileType.toLowerCase() == 'txt';

  /// Whether this should open in external viewer
  bool get isExternalOpen => ['pdf', 'docx'].contains(fileType.toLowerCase());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
