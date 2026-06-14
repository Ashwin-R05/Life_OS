import 'dart:ui';
import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import '../controller/search_controller.dart';
import '../../notes/controller/notes_controller.dart';
import '../../notes/models/activity_model.dart';
import '../../notes/models/note_model.dart';
import '../../notes/services/activity_storage_service.dart';
import '../../notes/screens/note_editor.dart';
import '../widgets/result_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchFieldController;
  List<ActivityModel> _activities = [];
  bool _loadingActivities = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
    _fetchActivities();
    
    _searchFieldController.addListener(() {
      final searchCtrl = Provider.of<SearchController>(context, listen: false);
      if (searchCtrl.searchQuery != _searchFieldController.text) {
        searchCtrl.setSearchQuery(_searchFieldController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() => _loadingActivities = true);
    final list = await ActivityStorageService.loadActivities();
    if (mounted) {
      setState(() {
        _activities = list;
        _loadingActivities = false;
      });
    }
  }

  void _openNote(String noteId) async {
    // Navigate to note editor
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditor(noteId: noteId),
      ),
    );
    // Refresh activities when returning
    _fetchActivities();
  }

  String _getActivityActionLabel(String action) {
    switch (action) {
      case 'created':
        return 'Created';
      case 'updated':
        return 'Edited';
      case 'viewed':
        return 'Viewed';
      default:
        return 'Modified';
    }
  }

  IconData _getActivityActionIcon(String action) {
    switch (action) {
      case 'created':
        return Icons.add_circle_outline_rounded;
      case 'updated':
        return Icons.edit_note_rounded;
      case 'viewed':
        return Icons.visibility_outlined;
      default:
        return Icons.edit_rounded;
    }
  }

  Color _getActivityActionColor(String action, ThemeData theme) {
    switch (action) {
      case 'created':
        return Colors.greenAccent;
      case 'updated':
        return theme.colorScheme.primary;
      case 'viewed':
        return Colors.amberAccent;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final notesController = Provider.of<NotesController>(context);
    final searchController = Provider.of<SearchController>(context);

    final filteredResults = searchController.performSearch(
      notesController.allNotes,
      notesController.allAttachments,
    );

    // Background blobs
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
          // Background blobs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
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
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Smart Search',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Search Bar + Filter Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: TextField(
                                controller: _searchFieldController,
                                autofocus: false,
                                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                                  ),
                                  suffixIcon: _searchFieldController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                                          ),
                                          onPressed: () {
                                            _searchFieldController.clear();
                                            searchController.setSearchQuery('');
                                          },
                                        )
                                      : null,
                                  hintText: 'Search title, content, folders, attachments...',
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                onSubmitted: (value) {
                                  searchController.addRecentSearch(value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Advanced filter toggle button
                      GestureDetector(
                        onTap: () => setState(() => _showFilters = !_showFilters),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _showFilters
                                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _showFilters
                                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: _showFilters
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters Drawer
                if (_showFilters) _buildFiltersDrawer(searchController, theme, isDark),

                const SizedBox(height: 16),

                // Main body area (Recent Searches & Activity VS Search Results)
                Expanded(
                  child: _searchFieldController.text.trim().isEmpty
                      ? _buildDashboardState(searchController, theme, isDark)
                      : _buildSearchResults(filteredResults, searchController.searchQuery, theme, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersDrawer(SearchController searchController, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ADVANCED FILTERS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              GestureDetector(
                onTap: () => searchController.clearFilters(),
                child: Text(
                  'Reset All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Folder Filters
          Text('Folder', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: NotesController.folders.map((f) {
                final isSelected = searchController.folderFilter == f['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('${f['emoji']} ${f['name']}'),
                    selected: isSelected,
                    onSelected: (_) => searchController.setFolderFilter(f['name']!),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Attachment filter
          Text('Attachments', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: ['All', 'With Attachments', 'No Attachments'].map((opt) {
                final isSelected = searchController.attachmentFilter == opt;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(opt),
                    selected: isSelected,
                    onSelected: (_) => searchController.setAttachmentFilter(opt),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Date filter
          Text('Updated Date', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: ['All', 'Today', 'This Week', 'This Month'].map((opt) {
                final isSelected = searchController.dateFilter == opt;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(opt),
                    selected: isSelected,
                    onSelected: (_) => searchController.setDateFilter(opt),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardState(SearchController searchController, ThemeData theme, bool isDark) {
    return RefreshIndicator(
      onRefresh: _fetchActivities,
      color: theme.colorScheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // Recent Searches section
          if (searchController.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT SEARCHES',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                GestureDetector(
                  onTap: () => searchController.clearRecentSearches(),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchController.recentSearches.map((query) {
                return Chip(
                  label: Text(query),
                  onDeleted: () => searchController.removeRecentSearch(query),
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  deleteIconColor: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Activity logs section
          Row(
            children: [
              Text(
                'RECENT ACTIVITY',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                ),
              ),
              const Spacer(),
              if (_loadingActivities)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 44,
                      color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent note activity logged',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _activities.map((act) {
                final actionColor = _getActivityActionColor(act.actionType, theme);
                final actionIcon = _getActivityActionIcon(act.actionType);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openNote(act.noteId),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: actionColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(actionIcon, size: 16, color: actionColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  act.noteTitle.isEmpty ? 'Untitled Note' : act.noteTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_getActivityActionLabel(act.actionType)} • ${_timeAgo(act.timestamp)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<NoteModel> results, String query, ThemeData theme, bool isDark) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
              Text(
                'No match found',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Try adjusting your keywords or search filters',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final notesController = Provider.of<NotesController>(context, listen: false);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ResultTile(
          note: note,
          attachments: notesController.allAttachments,
          searchQuery: query,
          onTap: () {
            // Save search history on result tap
            Provider.of<SearchController>(context, listen: false).addRecentSearch(query);
            _openNote(note.id);
          },
        );
      },
    );
  }
}
