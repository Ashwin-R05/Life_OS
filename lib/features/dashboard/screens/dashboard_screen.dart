import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/dashboard_controller.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../widgets/widget_grid.dart';
import '../widgets/widget_picker.dart';
import '../../onboarding/widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize active dashboard layout state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false).initDashboard();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Read user profile details from OnboardingController
    final onboardingController = Provider.of<OnboardingController>(context);
    final userName = onboardingController.profile.name.isNotEmpty 
        ? onboardingController.profile.name 
        : 'User';

    final dashboardController = Provider.of<DashboardController>(context);
    final isEditMode = dashboardController.isEditMode;

    // Futuristic glowing mesh blob gradient backgrounds
    final blobColors = isDark ? [
      theme.colorScheme.primary.withValues(alpha: 0.2), // increased opacity for futuristic feel
      theme.colorScheme.secondary.withValues(alpha: 0.15),
    ] : [
      theme.colorScheme.primary.withValues(alpha: 0.1),
      theme.colorScheme.secondary.withValues(alpha: 0.08),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Blob 1 (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0],
              ),
            ),
          ),
          // Background Blob 2 (Bottom Left)
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[1],
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Dashboard Greeting Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: theme.colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Glass Edit Mode Toggle Action Button
                          Row(
                            children: [
                              if (isEditMode) ...[
                                GestureDetector(
                                  onTap: () => WidgetPicker.show(context),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              GestureDetector(
                                onTap: dashboardController.toggleEditMode,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isEditMode 
                                        ? theme.colorScheme.secondary.withValues(alpha: 0.15) 
                                        : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: isEditMode 
                                          ? theme.colorScheme.secondary.withValues(alpha: 0.4) 
                                          : isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Icon(
                                    isEditMode ? Icons.check : Icons.edit,
                                    color: isEditMode ? theme.colorScheme.secondary : theme.textTheme.bodyMedium?.color,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Active Mode Banner Helper
                      if (isEditMode) ...[
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          customBorderColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                          child: Row(
                            children: [
                              Text('🛠️', style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Edit Mode active. Long-press to drag and reorder, or resize using the S/M/L controls.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Custom Reorderable Widget Grid
                      const WidgetGrid(),
                      
                      if (isEditMode) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Provider.of<OnboardingController>(context, listen: false).resetOnboarding(context),
                            icon: const Icon(Icons.refresh, size: 16, color: Colors.redAccent),
                            label: const Text(
                              'Reset LifeOS Workspace',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
