import 'dart:ui';
import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int noteCount;
  final bool isActive;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.noteCount,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.primary.withValues(alpha: 0.08);
    final inactiveBg = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.5);
    final activeBorder = theme.colorScheme.primary.withValues(alpha: 0.4);
    final inactiveBorder = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? activeBg : inactiveBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? activeBorder : inactiveBorder,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$noteCount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
