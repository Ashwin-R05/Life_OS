import 'package:flutter/material.dart';
import '../models/journal_entry_model.dart';
import '../services/journal_storage_service.dart';

class JournalController extends ChangeNotifier {
  List<JournalEntryModel> _entries = [];
  bool _isLoading = true;

  List<JournalEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  JournalController() {
    _init();
  }

  Future<void> _init() async {
    _entries = await JournalStorageService.loadEntries();

    // Sort by date descending (newest first)
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(String content, String mood) async {
    final entry = JournalEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      mood: mood,
      createdAt: DateTime.now(),
    );

    _entries.insert(0, entry);
    await JournalStorageService.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await JournalStorageService.saveEntries(_entries);
    notifyListeners();
  }

  JournalEntryModel? getTodayEntry() {
    final today = DateTime.now();
    try {
      return _entries.firstWhere((entry) =>
        entry.createdAt.year == today.year &&
        entry.createdAt.month == today.month &&
        entry.createdAt.day == today.day
      );
    } catch (e) {
      return null; // No entry for today
    }
  }
}
