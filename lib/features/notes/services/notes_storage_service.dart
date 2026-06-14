import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NotesStorageService {
  static const String _keyNotes = 'life_os_notes';

  static Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_keyNotes, jsonList);
  }

  static Future<List<NoteModel>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyNotes);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      return jsonList.map((item) {
        final Map<String, dynamic> decoded =
            jsonDecode(item) as Map<String, dynamic>;
        return NoteModel.fromJson(decoded);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
