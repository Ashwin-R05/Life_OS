import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/focus_controller.dart';

class LimitEditor extends StatefulWidget {
  const LimitEditor({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LimitEditor(),
    );
  }

  @override
  State<LimitEditor> createState() => _LimitEditorState();
}

class _LimitEditorState extends State<LimitEditor> {
  // Local temporary edits
  final Map<String, int> _tempMinutes = {};
  final Map<String, bool> _tempActives = {};

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<FocusController>(context, listen: false);
    for (final limit in controller.limits) {
      _tempMinutes[limit.category] = limit.limitMinutes;
      _tempActives[limit.category] = limit.isActive;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Social': return '💬';
      case 'Entertainment': return '🎬';
      case 'Gaming': return '🎮';
      default: return '⏳';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final controller = Provider.of<FocusController>(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                'Edit Daily App Limits',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Categories list
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: ['Social', 'Entertainment', 'Gaming', 'Distraction'].map((cat) {
                    // Check local temp state or default from controller
                    final minutes = _tempMinutes[cat] ?? 30;
                    final isActive = _tempActives[cat] ?? true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_getCategoryEmoji(cat)}  $cat',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const Spacer(),
                              Text(
                                '$minutes min',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isActive ? theme.colorScheme.primary : theme.disabledColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Switch.adaptive(
                                value: isActive,
                                activeThumbColor: theme.colorScheme.primary,
                                onChanged: (val) {
                                  setState(() {
                                    _tempActives[cat] = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 8),
                            Slider(
                              value: minutes.toDouble(),
                              min: 5,
                              max: 180,
                              divisions: 35, // 5 min intervals from 5 to 180
                              activeColor: theme.colorScheme.primary,
                              inactiveColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                              onChanged: (val) {
                                setState(() {
                                  _tempMinutes[cat] = val.toInt();
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Save Action Button
              GestureDetector(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  // Save all edits to controller
                  for (final cat in _tempMinutes.keys) {
                    final minutes = _tempMinutes[cat] ?? 30;
                    final active = _tempActives[cat] ?? true;
                    await controller.updateCategoryLimit(cat, minutes, active);
                  }
                  navigator.pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Apply Limits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
