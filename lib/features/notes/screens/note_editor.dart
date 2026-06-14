import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/notes_controller.dart';
import '../models/attachment_model.dart';
import '../widgets/attachment_picker.dart';
import '../widgets/attachment_tile.dart';
import '../widgets/link_text.dart';
import '../widgets/related_notes.dart';
import 'attachment_preview.dart';

class NoteEditor extends StatefulWidget {
  final String noteId;

  const NoteEditor({super.key, required this.noteId});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Timer? _autoSaveTimer;
  String? _currentFolder;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<NotesController>(context, listen: false);
      controller.logViewActivity(widget.noteId);
      final note = controller.getNoteById(widget.noteId);
      if (note != null) {
        _titleController.text = note.title;
        _contentController.text = note.content;
        setState(() {
          _currentFolder = note.folder;
        });
      }
    });
  }

  @override
  void dispose() {
    // Flush any pending auto-save
    _autoSaveTimer?.cancel();
    _saveNow();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveNow();
    });
  }

  void _saveNow() {
    final controller = Provider.of<NotesController>(context, listen: false);
    controller.updateNote(
      widget.noteId,
      title: _titleController.text,
      content: _contentController.text,
      folder: _currentFolder,
    );
  }

  void _showFolderPicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Move to Folder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Skip 'All' folder — only show real folders
                  ...NotesController.folders
                      .where((f) => f['name'] != 'All')
                      .map((folder) {
                    final isSelected = _currentFolder == folder['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _currentFolder = folder['name'];
                            });
                            _saveNow();
                            Navigator.of(ctx).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.3)
                                    : isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black
                                            .withValues(alpha: 0.04),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(folder['emoji']!,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    folder['name']!,
                                    style:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

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

  void _showInsertLinkDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesController = Provider.of<NotesController>(context, listen: false);
    
    // Get all other notes
    final otherNotes = notesController.allNotes.where((n) => n.id != widget.noteId).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Link Another Note',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (otherNotes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No other notes found to link',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: otherNotes.length,
                        itemBuilder: (context, index) {
                          final note = otherNotes[index];
                          final displayTitle = note.title.isEmpty ? 'Untitled Note' : note.title;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  final text = _contentController.text;
                                  final selection = _contentController.selection;
                                  final linkString = '[[${note.id}|${note.title.isEmpty ? 'Note' : note.title}]]';

                                  if (selection.isValid) {
                                    final newText = text.replaceRange(selection.start, selection.end, linkString);
                                    _contentController.text = newText;
                                    _contentController.selection = TextSelection.collapsed(
                                      offset: selection.start + linkString.length,
                                    );
                                  } else {
                                    _contentController.text = '$text $linkString';
                                  }
                                  _onTextChanged(); // Trigger auto-save
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('📄', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          displayTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        note.folder,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: 11,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditorToolbar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Preview / Edit Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isPreviewMode
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : theme.cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isPreviewMode
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPreviewMode ? Icons.edit_rounded : Icons.visibility_rounded,
                    size: 14,
                    color: _isPreviewMode ? theme.colorScheme.primary : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPreviewMode ? 'Editing Mode' : 'Preview Link Spans',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isPreviewMode ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Insert Link button (only show when not in preview mode)
          if (!_isPreviewMode)
            GestureDetector(
              onTap: _showInsertLinkDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Link Note',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<NotesController>(context);
    final note = controller.getNoteById(widget.noteId);

    if (note == null) {
      return Scaffold(
        body: Center(
          child: Text('Note not found',
              style: theme.textTheme.bodyLarge),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background blob
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.06 : 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Folder chip (tappable)
                      GestureDetector(
                        onTap: _showFolderPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getFolderEmoji(_currentFolder ?? note.folder),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentFolder ?? note.folder,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Attach file button
                      GestureDetector(
                        onTap: () => AttachmentPicker.show(context, widget.noteId),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Pin toggle
                      GestureDetector(
                        onTap: () => controller.togglePin(widget.noteId),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: note.isPinned
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.12)
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            note.isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            size: 18,
                            color: note.isPinned
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Delete
                      GestureDetector(
                        onTap: () {
                          controller.deleteNote(widget.noteId);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Editor body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Editor Toolbar (Edit/Preview modes, Link note)
                        _buildEditorToolbar(theme, isDark),
                        const SizedBox(height: 8),

                        // Title Field or Text Preview
                        _isPreviewMode
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  note.title.isEmpty ? 'Untitled Note' : note.title,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                  ),
                                ),
                              )
                            : TextField(
                                controller: _titleController,
                                onChanged: (_) => _onTextChanged(),
                                maxLines: null,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  hintStyle:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.2),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                ),
                              ),

                        const SizedBox(height: 4),

                        // Timestamp
                        Text(
                          'Last edited ${_timeAgo(note.updatedAt)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.25),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtle divider
                        Container(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                        ),

                        const SizedBox(height: 16),

                        // Content Field or Clickable Link Spans Preview
                        _isPreviewMode
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: LinkText(
                                  text: note.content.isEmpty ? 'No content' : note.content,
                                  onLinkTap: (linkedNoteId) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => NoteEditor(noteId: linkedNoteId),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : TextField(
                                controller: _contentController,
                                onChanged: (_) => _onTextChanged(),
                                maxLines: null,
                                minLines: 20,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Start writing...',
                                  hintStyle:
                                      theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.2),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                ),
                              ),

                        // ── Attachments Section ──────────────────────
                        _buildAttachmentsSection(context, controller, theme, isDark),

                        // ── Related Notes & Backlinks (Second Brain) ─
                        RelatedNotes(
                          currentNoteId: widget.noteId,
                          onNoteTap: (linkedNoteId) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NoteEditor(noteId: linkedNoteId),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    NotesController controller,
    ThemeData theme,
    bool isDark,
  ) {
    final attachments = controller.getAttachmentsForNote(widget.noteId);

    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // Divider
        Container(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        const SizedBox(height: 16),

        // Header
        Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Attachments',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${attachments.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => AttachmentPicker.show(context, widget.noteId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Attachment tiles
        ...attachments.map((attachment) => AttachmentTile(
              attachment: attachment,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AttachmentPreview(attachment: attachment),
                  ),
                );
              },
              onDelete: () {
                _showDeleteAttachmentDialog(
                    context, controller, attachment);
              },
            )),
      ],
    );
  }

  void _showDeleteAttachmentDialog(
    BuildContext context,
    NotesController controller,
    AttachmentModel attachment,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Attachment',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Delete "${attachment.fileName}"? This cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.removeAttachment(widget.noteId, attachment.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
