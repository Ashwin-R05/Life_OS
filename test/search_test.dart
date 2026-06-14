import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/features/notes/models/note_model.dart';
import 'package:life_os/features/notes/models/attachment_model.dart';
import 'package:life_os/features/notes/services/link_parser.dart';
import 'package:life_os/features/search/controller/search_controller.dart' as smart_search;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LinkParser Tests', () {
    test('extractLinkIds parses brackets correctly', () {
      const text = 'Hello world [[note_123]] and [[note_abc|Custom Label]]';
      final links = LinkParser.extractLinkIds(text);

      expect(links.length, 2);
      expect(links[0], 'note_123');
      expect(links[1], 'note_abc');
    });

    test('parse splits segments correctly into normal text and links', () {
      const text = 'Welcome [[note_1]] to our [[note_2|Project Tab]] page.';
      final segments = LinkParser.parse(text);

      expect(segments.length, 5);
      
      expect(segments[0].isLink, false);
      expect(segments[0].text, 'Welcome ');

      expect(segments[1].isLink, true);
      expect(segments[1].noteId, 'note_1');
      expect(segments[1].text, 'note_1');

      expect(segments[2].isLink, false);
      expect(segments[2].text, ' to our ');

      expect(segments[3].isLink, true);
      expect(segments[3].noteId, 'note_2');
      expect(segments[3].text, 'Project Tab');

      expect(segments[4].isLink, false);
      expect(segments[4].text, ' page.');
    });
  });

  group('SearchController Tests', () {
    final note1 = NoteModel(
      id: 'note_1',
      title: 'Study Guide',
      content: 'This note is about flutter programming guide',
      folder: 'Study',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final note2 = NoteModel(
      id: 'note_2',
      title: 'Idea Board',
      content: 'Creative brain storming ideas for app',
      folder: 'Ideas',
      attachmentIds: ['att_1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    final attachment = AttachmentModel(
      id: 'att_1',
      noteId: 'note_2',
      fileName: 'sketch_design.png',
      filePath: '/path/sketch_design.png',
      fileType: 'png',
      fileSize: 1024,
      addedAt: DateTime.now(),
    );

    test('search query matches title, content, and folder', () {
      final controller = smart_search.SearchController();
      final allNotes = [note1, note2];
      final allAttachments = [attachment];

      // Query "creative" matches content of note2
      controller.setSearchQuery('creative');
      var results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      expect(results.first.id, 'note_2');

      // Query "study" matches title and folder of note1
      controller.setSearchQuery('study');
      results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      expect(results.first.id, 'note_1');
    });

    test('search query matches attachment names', () {
      final controller = smart_search.SearchController();
      final allNotes = [note1, note2];
      final allAttachments = [attachment];

      // Query "sketch" matches attachment fileName of note2
      controller.setSearchQuery('sketch');
      final results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      expect(results.first.id, 'note_2');
    });

    test('advanced filters filter folder, attachments, and dates correctly', () {
      final controller = smart_search.SearchController();
      final allNotes = [note1, note2];
      final allAttachments = [attachment];

      // Filter: folder = "Ideas"
      controller.setFolderFilter('Ideas');
      var results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      expect(results.first.id, 'note_2');

      // Filter: With Attachments
      controller.clearFilters();
      controller.setAttachmentFilter('With Attachments');
      results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      expect(results.first.id, 'note_2');

      // Filter: Date filter (Today)
      controller.clearFilters();
      controller.setDateFilter('Today');
      results = controller.performSearch(allNotes, allAttachments);
      expect(results.length, 1);
      // note1 is today, note2 was 5 days ago
      expect(results.first.id, 'note_1');
    });
  });
}
