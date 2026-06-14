import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/dashboard_controller.dart';
import '../../onboarding/widgets/glass_card.dart';
import '../../onboarding/widgets/primary_button.dart';

class WidgetPicker extends StatefulWidget {
  const WidgetPicker({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const WidgetPicker(),
    );
  }

  @override
  State<WidgetPicker> createState() => _WidgetPickerState();
}

class _WidgetPickerState extends State<WidgetPicker> {
  String? _selectedType;
  String _selectedSize = 'medium';

  final List<Map<String, String>> _availableTypes = [
    {'type': 'notes', 'title': 'Notes Workspace', 'icon': '📝', 'desc': 'Ideation canvas & markdown vaults'},
    {'type': 'tasks', 'title': 'Tasks Queue', 'icon': '✔️', 'desc': 'Personal backlog & board tracker'},
    {'type': 'habits', 'title': 'Habit Streaks', 'icon': '🔄', 'desc': 'Streak map & routines builder'},
    {'type': 'focus', 'title': 'Focus Sphere', 'icon': '⏱️', 'desc': 'Pomodoro timer & session keeper'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<DashboardController>(context);
    
    // Filter out types that are already on the dashboard
    final activeTypes = controller.activeWidgets.map((w) => w.type).toSet();
    final inactiveTypes = _availableTypes.where((item) => !activeTypes.contains(item['type'])).toList();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F141F).withValues(alpha: 0.95) : const Color(0xFFF1F5F9).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add Workspace Widget',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select an inactive workspace module and choose its grid layout size.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          if (inactiveTypes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'All widgets are active!',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You have already activated all available workspace modules on your dashboard.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // List of choices
            Text(
              'CHOOSE WIDGET TYPE',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: inactiveTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = inactiveTypes[index];
                  final isSelected = _selectedType == item['type'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = item['type'];
                      });
                    },
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      customBorderColor: isSelected 
                          ? theme.colorScheme.primary 
                          : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      customBackgroundColor: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha: 0.08) 
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Text(item['icon']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected ? theme.colorScheme.primary : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['desc']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            // Size selection
            Text(
              'SELECT GRID SIZE',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSizeChoice('small', 'Small', 'Spans 1 column. Compact stats.'),
                const SizedBox(width: 12),
                _buildSizeChoice('medium', 'Medium', 'Spans 2 columns. Balanced feed.'),
                const SizedBox(width: 12),
                _buildSizeChoice('large', 'Large', 'Spans 2 columns. Extended view.'),
              ],
            ),
            
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Add Widget',
              onPressed: _selectedType == null 
                  ? null 
                  : () async {
                      await controller.addWidget(_selectedType!, _selectedSize);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSizeChoice(String value, String title, String subtitle) {
    final theme = Theme.of(context);
    final isSelected = _selectedSize == value;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSize = value;
          });
        },
        child: GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          customBorderColor: isSelected 
              ? theme.colorScheme.primary 
              : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          customBackgroundColor: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.05) 
              : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 9,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
