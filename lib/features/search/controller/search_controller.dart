import 'package:flutter/material.dart' hide SearchController;
import 'package:shared_preferences/shared_preferences.dart';
import '../../notes/models/note_model.dart';
import '../../notes/models/attachment_model.dart';

class SearchController extends ChangeNotifier {
  String _searchQuery = '';
  String _folderFilter = 'All';
  String _attachmentFilter = 'All'; // 'All' | 'With Attachments' | 'No Attachments'
  String _dateFilter = 'All'; // 'All' | 'Today' | 'This Week' | 'This Month'
  List<String> _recentSearches = [];

  // Getters
  String get searchQuery => _searchQuery;
  String get folderFilter => _folderFilter;
  String get attachmentFilter => _attachmentFilter;
  String get dateFilter => _dateFilter;
  List<String> get recentSearches => _recentSearches;

  static const String _keyRecentSearches = 'life_os_recent_searches';
  static const int _maxRecentSearches = 5;

  SearchController() {
    _loadRecentSearches();
  }

  // Setters & Filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFolderFilter(String folder) {
    _folderFilter = folder;
    notifyListeners();
  }

  void setAttachmentFilter(String filter) {
    _attachmentFilter = filter;
    notifyListeners();
  }

  void setDateFilter(String filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  /// Reset all filters to default
  void clearFilters() {
    _folderFilter = 'All';
    _attachmentFilter = 'All';
    _dateFilter = 'All';
    notifyListeners();
  }

  /// Perform smart search on raw list of notes and attachments
  List<NoteModel> performSearch(List<NoteModel> notes, List<AttachmentModel> attachments) {
    List<NoteModel> result = List.from(notes);

    // 1. Filter by Search Query (title, content, folder, attachment name)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((note) {
        // Match title
        final matchTitle = note.title.toLowerCase().contains(query);
        // Match content
        final matchContent = note.content.toLowerCase().contains(query);
        // Match folder
        final matchFolder = note.folder.toLowerCase().contains(query);
        // Match attachment name
        final noteAttachments = attachments.where((a) => a.noteId == note.id);
        final matchAttachment = noteAttachments.any(
          (a) => a.fileName.toLowerCase().contains(query),
        );

        return matchTitle || matchContent || matchFolder || matchAttachment;
      }).toList();
    }

    // 2. Filter by Folder
    if (_folderFilter != 'All') {
      result = result.where((note) => note.folder == _folderFilter).toList();
    }

    // 3. Filter by Attachments status
    if (_attachmentFilter == 'With Attachments') {
      result = result.where((note) => note.attachmentIds.isNotEmpty).toList();
    } else if (_attachmentFilter == 'No Attachments') {
      result = result.where((note) => note.attachmentIds.isEmpty).toList();
    }

    // 4. Filter by Date range
    if (_dateFilter != 'All') {
      final now = DateTime.now();
      result = result.where((note) {
        final difference = now.difference(note.updatedAt);
        if (_dateFilter == 'Today') {
          return difference.inDays == 0 && note.updatedAt.day == now.day;
        } else if (_dateFilter == 'This Week') {
          return difference.inDays <= 7;
        } else if (_dateFilter == 'This Month') {
          return difference.inDays <= 30;
        }
        return true;
      }).toList();
    }

    // Sort: Pinned first, then by updatedAt desc
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  // ── Recent Searches Persistence ──────────────────────────────────
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_keyRecentSearches) ?? [];
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Remove if exists to push to front
    _recentSearches.remove(cleanQuery);
    _recentSearches.insert(0, cleanQuery);

    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }

    await prefs.setStringList(_keyRecentSearches, _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    await prefs.setStringList(_keyRecentSearches, _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.clear();
    await prefs.remove(_keyRecentSearches);
    notifyListeners();
  }
}
