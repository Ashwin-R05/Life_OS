import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/attachment_model.dart';
import '../services/notes_storage_service.dart';
import '../services/attachment_storage_service.dart';

class NotesController extends ChangeNotifier {
  List<NoteModel> _allNotes = [];
  List<AttachmentModel> _allAttachments = [];
  String _activeFolder = 'All';
  String _searchQuery = '';

  // ── Getters ──────────────────────────────────────────────────────
  List<NoteModel> get allNotes => _allNotes;
  List<AttachmentModel> get allAttachments => _allAttachments;
  String get activeFolder => _activeFolder;
  String get searchQuery => _searchQuery;

  /// Available folders
  static const List<Map<String, String>> folders = [
    {'name': 'All', 'emoji': '📂'},
    {'name': 'Study', 'emoji': '📚'},
    {'name': 'Ideas', 'emoji': '💡'},
    {'name': 'Knowledge', 'emoji': '🧠'},
    {'name': 'Projects', 'emoji': '🚀'},
  ];

  /// Returns notes filtered by active folder + search query,
  /// sorted: pinned first → then by updatedAt descending.
  List<NoteModel> get filteredNotes {
    List<NoteModel> result = List.from(_allNotes);

    // Filter by folder
    if (_activeFolder != 'All') {
      result = result.where((n) => n.folder == _activeFolder).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query);
      }).toList();
    }

    // Sort: pinned first, then by updatedAt desc
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  /// Count notes in a specific folder
  int noteCountForFolder(String folder) {
    if (folder == 'All') return _allNotes.length;
    return _allNotes.where((n) => n.folder == folder).length;
  }

  // ── Init ─────────────────────────────────────────────────────────
  Future<void> initNotes() async {
    _allNotes = await NotesStorageService.loadNotes();
    _allAttachments = await AttachmentStorageService.loadAttachmentMetadata();
    notifyListeners();
  }

  // ── Note CRUD ────────────────────────────────────────────────────
  /// Create a blank note in the given folder. Returns the new note's id.
  Future<String> createNote(String folder) async {
    final now = DateTime.now();
    final id = 'note_${now.millisecondsSinceEpoch}';
    // Use 'All' as default folder if creating from All view
    final noteFolder = folder == 'All' ? 'Study' : folder;

    final note = NoteModel(
      id: id,
      title: '',
      content: '',
      folder: noteFolder,
      isPinned: false,
      attachmentIds: [],
      createdAt: now,
      updatedAt: now,
    );

    _allNotes.insert(0, note);
    await NotesStorageService.saveNotes(_allNotes);
    notifyListeners();
    return id;
  }

  /// Update a note's title and content (called by auto-save)
  Future<void> updateNote(String id, {String? title, String? content, String? folder}) async {
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _allNotes[index] = _allNotes[index].copyWith(
      title: title,
      content: content,
      folder: folder,
      updatedAt: DateTime.now(),
    );

    await NotesStorageService.saveNotes(_allNotes);
    notifyListeners();
  }

  /// Delete a note by id — also deletes all its attachments
  Future<void> deleteNote(String id) async {
    // Delete all attachment files for this note
    final noteAttachments = _allAttachments.where((a) => a.noteId == id).toList();
    for (final attachment in noteAttachments) {
      await AttachmentStorageService.deleteAttachmentFile(attachment.filePath);
    }
    _allAttachments.removeWhere((a) => a.noteId == id);
    await AttachmentStorageService.saveAttachmentMetadata(_allAttachments);

    // Delete the attachments directory
    await AttachmentStorageService.deleteAllAttachmentsForNote(id);

    // Delete the note
    _allNotes.removeWhere((n) => n.id == id);
    await NotesStorageService.saveNotes(_allNotes);
    notifyListeners();
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _allNotes[index] = _allNotes[index].copyWith(
      isPinned: !_allNotes[index].isPinned,
    );

    await NotesStorageService.saveNotes(_allNotes);
    notifyListeners();
  }

  /// Get a single note by id
  NoteModel? getNoteById(String id) {
    try {
      return _allNotes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Attachment CRUD ──────────────────────────────────────────────

  /// Get all attachments for a specific note
  List<AttachmentModel> getAttachmentsForNote(String noteId) {
    return _allAttachments.where((a) => a.noteId == noteId).toList();
  }

  /// Add an attachment to a note
  Future<void> addAttachment(String noteId, File sourceFile) async {
    // Copy file to local storage
    final localPath = await AttachmentStorageService.saveAttachmentFile(noteId, sourceFile);

    // Extract file info
    final fileName = sourceFile.path.split('/').last;
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'unknown';
    final fileSize = await sourceFile.length();

    // Create attachment model
    final now = DateTime.now();
    final attachmentId = 'att_${now.millisecondsSinceEpoch}';
    final attachment = AttachmentModel(
      id: attachmentId,
      noteId: noteId,
      fileName: fileName,
      filePath: localPath,
      fileType: extension,
      fileSize: fileSize,
      addedAt: now,
    );

    // Add to metadata list
    _allAttachments.add(attachment);
    await AttachmentStorageService.saveAttachmentMetadata(_allAttachments);

    // Link to note
    final noteIndex = _allNotes.indexWhere((n) => n.id == noteId);
    if (noteIndex != -1) {
      final updatedIds = List<String>.from(_allNotes[noteIndex].attachmentIds)
        ..add(attachmentId);
      _allNotes[noteIndex] = _allNotes[noteIndex].copyWith(
        attachmentIds: updatedIds,
        updatedAt: now,
      );
      await NotesStorageService.saveNotes(_allNotes);
    }

    notifyListeners();
  }

  /// Remove an attachment from a note
  Future<void> removeAttachment(String noteId, String attachmentId) async {
    // Find attachment
    final attachment = _allAttachments.firstWhere(
      (a) => a.id == attachmentId,
      orElse: () => throw Exception('Attachment not found'),
    );

    // Delete file
    await AttachmentStorageService.deleteAttachmentFile(attachment.filePath);

    // Remove from metadata list
    _allAttachments.removeWhere((a) => a.id == attachmentId);
    await AttachmentStorageService.saveAttachmentMetadata(_allAttachments);

    // Unlink from note
    final noteIndex = _allNotes.indexWhere((n) => n.id == noteId);
    if (noteIndex != -1) {
      final updatedIds = List<String>.from(_allNotes[noteIndex].attachmentIds)
        ..remove(attachmentId);
      _allNotes[noteIndex] = _allNotes[noteIndex].copyWith(
        attachmentIds: updatedIds,
        updatedAt: DateTime.now(),
      );
      await NotesStorageService.saveNotes(_allNotes);
    }

    notifyListeners();
  }

  // ── Filters ──────────────────────────────────────────────────────
  void setFolder(String folder) {
    _activeFolder = folder;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
