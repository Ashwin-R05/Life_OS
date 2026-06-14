import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attachment_model.dart';

class AttachmentStorageService {
  static const String _keyAttachments = 'life_os_attachments';

  // ── File System Operations ───────────────────────────────────────

  /// Get (or create) the attachments directory for a specific note
  static Future<Directory> getAttachmentDir(String noteId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/attachments/$noteId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copy a picked file into the note's attachments directory.
  /// Returns the local path of the copied file.
  static Future<String> saveAttachmentFile(String noteId, File sourceFile) async {
    final dir = await getAttachmentDir(noteId);
    final fileName = sourceFile.path.split('/').last;

    // Ensure unique filename by prepending timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueName = '${timestamp}_$fileName';
    final destPath = '${dir.path}/$uniqueName';

    await sourceFile.copy(destPath);
    return destPath;
  }

  /// Delete a single attachment file from the filesystem
  static Future<void> deleteAttachmentFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Delete the entire attachments directory for a note
  static Future<void> deleteAllAttachmentsForNote(String noteId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/attachments/$noteId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  // ── Metadata Persistence (SharedPreferences) ────────────────────

  /// Save all attachment metadata to SharedPreferences
  static Future<void> saveAttachmentMetadata(List<AttachmentModel> attachments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = attachments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyAttachments, jsonList);
  }

  /// Load all attachment metadata from SharedPreferences
  static Future<List<AttachmentModel>> loadAttachmentMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyAttachments);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      return jsonList.map((item) {
        final Map<String, dynamic> decoded =
            jsonDecode(item) as Map<String, dynamic>;
        return AttachmentModel.fromJson(decoded);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
