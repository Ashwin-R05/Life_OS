class LinkParser {
  // Regex to match [[note_id]] or [[note_id|display_name]]
  // note_id matches word characters, hyphens, and underscores: [a-zA-Z0-9_-]+
  static final RegExp linkRegExp = RegExp(r'\[\[([a-zA-Z0-9_-]+)(?:\|([^\]]+))?\]\]');

  /// Parse text into list of segments (ordinary text vs wiki-link)
  static List<LinkSegment> parse(String text) {
    if (text.isEmpty) return [];

    final List<LinkSegment> segments = [];
    int lastIndex = 0;

    final matches = linkRegExp.allMatches(text);
    for (final match in matches) {
      // Add text leading up to the match
      if (match.start > lastIndex) {
        segments.add(LinkSegment(
          text: text.substring(lastIndex, match.start),
          isLink: false,
        ));
      }

      final noteId = match.group(1)!;
      final customLabel = match.group(2);

      segments.add(LinkSegment(
        text: customLabel != null && customLabel.trim().isNotEmpty
            ? customLabel.trim()
            : noteId,
        isLink: true,
        noteId: noteId,
      ));

      lastIndex = match.end;
    }

    // Add remaining trailing text
    if (lastIndex < text.length) {
      segments.add(LinkSegment(
        text: text.substring(lastIndex),
        isLink: false,
      ));
    }

    return segments;
  }

  /// Extracts all unique referenced note IDs from note content
  static List<String> extractLinkIds(String content) {
    if (content.isEmpty) return [];

    final Set<String> noteIds = {};
    final matches = linkRegExp.allMatches(content);
    for (final match in matches) {
      noteIds.add(match.group(1)!);
    }
    return noteIds.toList();
  }
}

class LinkSegment {
  final String text;
  final bool isLink;
  final String? noteId;

  LinkSegment({
    required this.text,
    required this.isLink,
    this.noteId,
  });
}
