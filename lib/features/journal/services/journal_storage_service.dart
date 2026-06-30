import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/journal_entry_model.dart';

class JournalStorageService {
  static const _storage = FlutterSecureStorage();
  static const _entriesKey = 'journal_entries_data';

  static Future<List<JournalEntryModel>> loadEntries() async {
    try {
      final jsonString = await _storage.read(key: _entriesKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded
            .map((item) => JournalEntryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Return empty list on error or if not found
    }
    return [];
  }

  static Future<void> saveEntries(List<JournalEntryModel> entries) async {
    final List<Map<String, dynamic>> mapped =
        entries.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(mapped);
    await _storage.write(key: _entriesKey, value: jsonString);
  }
}
