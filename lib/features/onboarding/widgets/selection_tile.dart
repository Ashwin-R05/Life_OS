import 'package:flutter/material.dart';
import 'glass_card.dart';

class SelectionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectionTile> createState() => _SelectionTileState();
}

class _SelectionTileState extends State<SelectionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryGlow = theme.colorScheme.primary;

    // Glowing border styling
    final Color borderColor = widget.isSelected
        ? primaryGlow
        : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06);

    // Selected state background color overlay
    final Color? backgroundColor = widget.isSelected
        ? isDark
            ? primaryGlow.withValues(alpha: 0.08)
            : primaryGlow.withValues(alpha: 0.05)
        : null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.98 : (widget.isSelected ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: primaryGlow.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            customBorderColor: borderColor,
            customBackgroundColor: backgroundColor,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Text(
                    widget.icon!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: widget.isSelected
                              ? primaryGlow
                              : isDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isSelected
                          ? primaryGlow
                          : isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.2),
                      width: 2.0,
                    ),
                    color: widget.isSelected ? primaryGlow : Colors.transparent,
                  ),
                  child: widget.isSelected
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: isDark ? Colors.black : Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
