import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_widget_model.dart';
import '../controller/dashboard_controller.dart';
import '../../onboarding/widgets/glass_card.dart';

class WidgetCard extends StatelessWidget {
  final DashboardWidgetModel widgetModel;

  const WidgetCard({
    super.key,
    required this.widgetModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<DashboardController>(context);
    final isEditMode = controller.isEditMode;

    // Get color accents based on widget type for premium glows
    final accents = _getWidgetAccents(context, widgetModel.type);
    final Color widgetAccentColor = accents.color;

    // Resolve card size height
    double cardHeight;
    final double heightOffset = isEditMode ? 55.0 : 0.0;
    switch (widgetModel.size) {
      case 'small':
        cardHeight = 180.0 + heightOffset;
        break;
      case 'medium':
        cardHeight = 180.0 + heightOffset; // Spans 2 columns, same height
        break;
      case 'large':
        cardHeight = 300.0 + heightOffset; // Spans 2 columns, double height
        break;
      default:
        cardHeight = 180.0 + heightOffset;
    }

    Widget cardContent = GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      customBorderColor: isEditMode 
          ? widgetAccentColor.withValues(alpha: 0.5) 
          : theme.brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.08) 
              : Colors.black.withValues(alpha: 0.06),
      customBackgroundColor: theme.brightness == Brightness.dark
          ? widgetAccentColor.withValues(alpha: 0.03)
          : widgetAccentColor.withValues(alpha: 0.05),
      customShadows: [
        BoxShadow(
          color: widgetAccentColor.withValues(alpha: isEditMode ? 0.15 : 0.05),
          blurRadius: isEditMode ? 20 : 12,
          offset: const Offset(0, 4),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Header (Title + Icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      accents.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        accents.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditMode)
                GestureDetector(
                  onTap: () => controller.removeWidget(widgetModel.id),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Widget Dynamic Body Placeholder
          Expanded(
            child: _buildWidgetBody(context, widgetModel.type, widgetModel.size),
          ),
          // Edit Mode Controls (Size selectors + Shift buttons)
          if (isEditMode) ...[
            const SizedBox(height: 8),
            const Divider(height: 16, thickness: 0.5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reorder Arrows
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.moveWidgetUp(widgetModel.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            child: const Icon(Icons.arrow_upward, size: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.moveWidgetDown(widgetModel.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            child: const Icon(Icons.arrow_downward, size: 14),
                          ),
                        ),
                      ],
                    ),
                    // Size Picker Toggles
                    Row(
                      children: ['small', 'medium', 'large'].map((s) {
                        final isSelected = widgetModel.size == s;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: GestureDetector(
                            onTap: () => controller.resizeWidget(widgetModel.id, s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected 
                                    ? widgetAccentColor.withValues(alpha: 0.15) 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected 
                                      ? widgetAccentColor 
                                      : Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Text(
                                s[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? widgetAccentColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );

    // If Edit Mode is enabled, wrap in Draggable
    if (isEditMode) {
      return Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        child: LongPressDraggable<DashboardWidgetModel>(
          data: widgetModel,
          feedback: Opacity(
            opacity: 0.75,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              height: cardHeight,
              child: Material(color: Colors.transparent, child: cardContent),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: cardContent,
          ),
          child: cardContent,
        ),
      );
    }

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.only(bottom: 16),
      child: cardContent,
    );
  }

  Widget _buildWidgetBody(BuildContext context, String type, String size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLarge = size == 'large';

    switch (type) {
      case 'notes':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Idea Sandbox',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '• Build clean architecture files for life...',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            if (isLarge) ...[
              const SizedBox(height: 6),
              Text(
                '• Outline presentation layout designs...',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '• Brainstorming core modules roadmap...',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ]
          ],
        );
      case 'tasks':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMockTask(context, 'Write LifeOS widget engine', true),
            const SizedBox(height: 8),
            _buildMockTask(context, 'Implement local preferences storage', false),
            if (isLarge) ...[
              const SizedBox(height: 8),
              _buildMockTask(context, 'Register provider controllers in main', false),
            ],
          ],
        );
      case 'habits':
        final showSevenDays = size != 'small';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Atomic Tracker',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildHabitDot(context, 'M', true),
                  const SizedBox(width: 8),
                  _buildHabitDot(context, 'T', true),
                  const SizedBox(width: 8),
                  _buildHabitDot(context, 'W', false),
                  const SizedBox(width: 8),
                  _buildHabitDot(context, 'T', true),
                  const SizedBox(width: 8),
                  _buildHabitDot(context, 'F', true),
                  if (showSevenDays) ...[
                    const SizedBox(width: 8),
                    _buildHabitDot(context, 'S', false),
                    const SizedBox(width: 8),
                    _buildHabitDot(context, 'S', true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current streak: 4 days 🔥',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 11,
              ),
            ),
          ],
        );
      case 'focus':
        final double progressSize = size == 'small'
            ? 56.0
            : size == 'medium'
                ? 64.0
                : 80.0;
        final showDetails = size != 'small';
        
        final progressCircle = Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                value: 0.7,
                strokeWidth: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            Text(
              '17:42',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: progressSize * 0.22,
              ),
            ),
          ],
        );

        if (!showDetails) {
          return Center(child: progressCircle);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            progressCircle,
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Session Active',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deep coding focus',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildMockTask(BuildContext context, String text, bool checked) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: checked ? accent : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked 
                  ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4) 
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitDot(BuildContext context, String day, bool checked) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked 
                ? theme.colorScheme.primary.withValues(alpha: 0.15) 
                : isDark 
                    ? Colors.white.withValues(alpha: 0.03) 
                    : Colors.black.withValues(alpha: 0.03),
            border: Border.all(
              color: checked 
                  ? theme.colorScheme.primary 
                  : isDark 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.black.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: checked
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: theme.colorScheme.primary,
                )
              : null,
        ),
      ],
    );
  }

  _WidgetAccents _getWidgetAccents(BuildContext context, String type) {
    final theme = Theme.of(context);
    
    switch (type) {
      case 'tasks':
        return _WidgetAccents(
          title: 'Tasks Queue',
          icon: '✔️',
          color: const Color(0xFFFFB300), // Amber
        );
      case 'notes':
        return _WidgetAccents(
          title: 'Notes Grid',
          icon: '📝',
          color: const Color(0xFF00E5FF), // Cyan
        );
      case 'habits':
        return _WidgetAccents(
          title: 'Habits Streaks',
          icon: '🔄',
          color: const Color(0xFF00E676), // Emerald
        );
      case 'focus':
        return _WidgetAccents(
          title: 'Focus Sphere',
          icon: '⏱️',
          color: const Color(0xFFD500F9), // Purple
        );
      default:
        return _WidgetAccents(
          title: 'Widget Card',
          icon: '📦',
          color: theme.colorScheme.primary,
        );
    }
  }
}

class _WidgetAccents {
  final String title;
  final String icon;
  final Color color;

  _WidgetAccents({
    required this.title,
    required this.icon,
    required this.color,
  });
}
