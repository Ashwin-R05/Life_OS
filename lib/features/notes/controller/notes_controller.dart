import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_storage_service.dart';

class NotesController extends ChangeNotifier {
  List<NoteModel> _allNotes = [];
  String _activeFolder = 'All';
  String _searchQuery = '';

  // ── Getters ──────────────────────────────────────────────────────
  List<NoteModel> get allNotes => _allNotes;
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
    notifyListeners();
  }

  // ── CRUD ─────────────────────────────────────────────────────────
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

  /// Delete a note by id
  Future<void> deleteNote(String id) async {
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
