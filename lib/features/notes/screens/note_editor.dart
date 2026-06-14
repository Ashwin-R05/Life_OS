import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/notes_controller.dart';
import '../models/note_model.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<NotesController>(context, listen: false);
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

                        // Title
                        TextField(
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

                        // Content
                        TextField(
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
}
