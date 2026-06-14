import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/notes_controller.dart';
import '../widgets/folder_card.dart';
import '../widgets/notes_search_bar.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_empty_state.dart';
import 'note_editor.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesController>(context, listen: false).initNotes();
    });
  }

  void _createNote(NotesController controller) async {
    final noteId = await controller.createNote(controller.activeFolder);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditor(noteId: noteId),
      ),
    );
  }

  void _openNote(String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditor(noteId: noteId),
      ),
    );
  }

  void _showDeleteDialog(NotesController controller, String noteId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Note',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
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
              controller.deleteNote(noteId);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<NotesController>(context);
    final filteredNotes = controller.filteredNotes;

    // Background blob colors
    final blobColors = isDark
        ? [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ]
        : [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.04),
          ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Blob 1 (Top Left)
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0],
              ),
            ),
          ),
          // Background Blob 2 (Bottom Right)
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[1],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MY NOTES',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Second Brain',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      // Note count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '${controller.allNotes.length} notes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Folder row
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: NotesController.folders.length,
                    itemBuilder: (context, index) {
                      final folder = NotesController.folders[index];
                      return FolderCard(
                        name: folder['name']!,
                        emoji: folder['emoji']!,
                        noteCount: controller
                            .noteCountForFolder(folder['name']!),
                        isActive:
                            controller.activeFolder == folder['name'],
                        onTap: () =>
                            controller.setFolder(folder['name']!),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: NotesSearchBar(
                    currentQuery: controller.searchQuery,
                    onChanged: controller.setSearchQuery,
                  ),
                ),

                const SizedBox(height: 16),

                // Notes list
                Expanded(
                  child: filteredNotes.isEmpty
                      ? SingleChildScrollView(
                          child: NotesEmptyState(
                            isSearching: controller.searchQuery.isNotEmpty,
                            onCreateNote: () => _createNote(controller),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return NoteTile(
                              note: note,
                              onTap: () => _openNote(note.id),
                              onLongPress: () =>
                                  _showDeleteDialog(controller, note.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating action button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _createNote(controller),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
