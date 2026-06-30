import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/focus/screens/focus_screen.dart';
import '../../features/journal/screens/journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SearchScreen(),
    FocusScreen(),
    NotesScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF050505).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15) // more visible border
                      : Colors.black.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.space_dashboard_rounded,
                      label: 'Home',
                      index: 0,
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: Icons.search_rounded,
                      label: 'Search',
                      index: 1,
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: Icons.hourglass_empty_rounded,
                      label: 'Focus',
                      index: 2,
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: Icons.note_alt_rounded,
                      label: 'Notes',
                      index: 3,
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: Icons.book_rounded,
                      label: 'Journal',
                      index: 4,
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? theme.colorScheme.primary
                  : isDark
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.35),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
