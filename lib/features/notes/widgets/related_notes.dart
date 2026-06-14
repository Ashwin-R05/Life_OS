import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/notes_controller.dart';
import '../models/note_model.dart';
import '../services/link_parser.dart';

class RelatedNotes extends StatelessWidget {
  final String currentNoteId;
  final Function(String noteId) onNoteTap;

  const RelatedNotes({
    super.key,
    required this.currentNoteId,
    required this.onNoteTap,
  });

  String _getFolderEmoji(String folder) {
    switch (folder) {
      case 'Study':
        return '📚';
      case 'Ideas':
        return '💡';
      case 'Knowledge':
        return '🧠';
      case 'Projects':
        return '🚀';
      default:
        return '📂';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final notesController = Provider.of<NotesController>(context);
    final currentNote = notesController.getNoteById(currentNoteId);

    if (currentNote == null) return const SizedBox.shrink();

    final allNotes = notesController.allNotes;

    // 1. Outgoing Links (parsed from current note)
    final outgoingIds = LinkParser.extractLinkIds(currentNote.content);
    final List<NoteModel> outgoingNotes = [];
    for (final id in outgoingIds) {
      final note = notesController.getNoteById(id);
      if (note != null && note.id != currentNoteId) {
        outgoingNotes.add(note);
      }
    }

    // 2. Backlinks (other notes linking to this note)
    final List<NoteModel> backlinks = [];
    for (final note in allNotes) {
      if (note.id == currentNoteId) continue;
      final links = LinkParser.extractLinkIds(note.content);
      if (links.contains(currentNoteId)) {
        backlinks.add(note);
      }
    }

    // 3. Similar / Suggested Notes (same folder, excluding outgoing/backlinks/current)
    final excludeIds = {currentNoteId, ...outgoingIds, ...backlinks.map((b) => b.id)};
    final List<NoteModel> suggestedNotes = allNotes
        .where((n) => n.folder == currentNote.folder && !excludeIds.contains(n.id))
        .take(3) // Limit to 3 suggestions
        .toList();

    final hasContent = outgoingNotes.isNotEmpty || backlinks.isNotEmpty || suggestedNotes.isNotEmpty;

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          height: 1,
          color: borderColor,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Icon(
              Icons.hub_outlined,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Second Brain Graph',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Backlinks Section
        if (backlinks.isNotEmpty) ...[
          _buildSubHeader(theme, 'BACKLINKS (${backlinks.length})', Icons.arrow_back_rounded),
          const SizedBox(height: 6),
          ...backlinks.map((note) => _buildRelatedNoteTile(context, note, theme, isDark)),
          const SizedBox(height: 12),
        ],

        // Outgoing Links Section
        if (outgoingNotes.isNotEmpty) ...[
          _buildSubHeader(theme, 'LINKED NOTES (${outgoingNotes.length})', Icons.arrow_forward_rounded),
          const SizedBox(height: 6),
          ...outgoingNotes.map((note) => _buildRelatedNoteTile(context, note, theme, isDark)),
          const SizedBox(height: 12),
        ],

        // Suggestions Section
        if (suggestedNotes.isNotEmpty) ...[
          _buildSubHeader(theme, 'RECOMMENDED IN "${currentNote.folder.toUpperCase()}"', Icons.lightbulb_outline_rounded),
          const SizedBox(height: 6),
          ...suggestedNotes.map((note) => _buildRelatedNoteTile(context, note, theme, isDark)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSubHeader(ThemeData theme, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 11, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedNoteTile(
    BuildContext context,
    NoteModel note,
    ThemeData theme,
    bool isDark,
  ) {
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : Colors.black.withValues(alpha: 0.01);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onNoteTap(note.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Row(
            children: [
              Text(
                _getFolderEmoji(note.folder),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'Untitled Note' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
