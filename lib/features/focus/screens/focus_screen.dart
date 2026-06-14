import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/focus_controller.dart';
import '../widgets/usage_card.dart';
import '../widgets/limit_editor.dart';
import 'focus_timer.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  String _selectedCategory = 'Study';
  int _selectedDuration = 25; // default 25 minutes pomodoro

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FocusController>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final controller = Provider.of<FocusController>(context);
    final today = controller.getTodayUsage();
    final insights = controller.getInsights();

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

    final cardBgColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.5);
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      body: Stack(
        children: [
          // Background Blobs
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

                // Header Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MINDFULNESS',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Focus & Control',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      
                      // Config Limits button
                      GestureDetector(
                        onTap: () => LimitEditor.show(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                            border: Border.all(color: cardBorderColor),
                          ),
                          child: Icon(Icons.settings_rounded, color: theme.colorScheme.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scrollable content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // 1. Session Launcher Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START A FOCUS SESSION',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Category chips row
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: FocusController.focusCategories.map((cat) {
                                      final isSelected = _selectedCategory == cat['name'];
                                      final Color catColor = cat['color'] as Color;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () => setState(() => _selectedCategory = cat['name'] as String),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? catColor.withValues(alpha: 0.12) 
                                                  : isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected ? catColor : cardBorderColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(cat['emoji'] as String, style: const TextStyle(fontSize: 15)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  cat['name'] as String,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                                    color: isSelected ? catColor : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Duration picker
                                Text(
                                  'Duration',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [5, 15, 25, 45, 60].map((mins) {
                                    final isSelected = _selectedDuration == mins;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedDuration = mins),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected ? theme.colorScheme.primary : cardBorderColor,
                                          ),
                                        ),
                                        child: Text(
                                          '${mins}m',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                            color: isSelected ? theme.colorScheme.primary : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                const SizedBox(height: 20),

                                // Action Start Button
                                GestureDetector(
                                  onTap: () {
                                    controller.startFocusSession(_selectedDuration, _selectedCategory);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const FocusTimer(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
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
                                        'Start Focus Sprint',
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
                      ),

                      const SizedBox(height: 20),

                      // 2. Insights Dashboard Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline_rounded, color: theme.colorScheme.primary, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MINDFULNESS INSIGHTS',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...insights.map((insight) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            insight,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: 12,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                
                                // Test tool section: simulation helper
                                const SizedBox(height: 12),
                                Container(
                                  height: 0.5,
                                  color: cardBorderColor,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Test Tools:',
                                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, color: Colors.grey),
                                    ),
                                    GestureDetector(
                                      onTap: () => controller.simulateUsage('Social', 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: cardBorderColor),
                                        ),
                                        child: const Text('+10m Social', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => controller.simulateUsage('Gaming', 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: cardBorderColor),
                                        ),
                                        child: const Text('+10m Gaming', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Weekly screen time + limits gauges
                      UsageCard(
                        logs: controller.usageLogs,
                        limits: controller.limits,
                        todayUsage: today,
                      ),
                      
                      const SizedBox(height: 40),
                    ],
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
