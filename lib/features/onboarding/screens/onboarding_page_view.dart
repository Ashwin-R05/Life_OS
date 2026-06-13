import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/progress_bar.dart';
import 'welcome_screen.dart';
import 'name_screen.dart';
import 'role_screen.dart';
import 'goals_screen.dart';
import 'modules_screen.dart';
import 'appearance_screen.dart';
import 'permissions_screen.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<OnboardingController>(context);

    // Glowing mesh blob gradient background positions
    final blobColors = isDark ? [
      theme.colorScheme.primary.withValues(alpha: 0.12),
      theme.colorScheme.secondary.withValues(alpha: 0.08),
    ] : [
      theme.colorScheme.primary.withValues(alpha: 0.08),
      theme.colorScheme.secondary.withValues(alpha: 0.05),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Blob 1 (Top Left)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0],
              ),
            ),
          ),
          // Background Blob 2 (Middle Right)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[1],
              ),
            ),
          ),
          // Background Blob 3 (Bottom Left)
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColors[0],
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: Column(
              children: [
                // Top Header (Progress + Back button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Back Button (hidden on Welcome Screen)
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: controller.currentStep > 0
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Material(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  child: InkWell(
                                    onTap: controller.previousStep,
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Progress Bar
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: controller.currentStep > 0
                              ? ProgressBar(
                                  currentStep: controller.currentStep - 1, // Exclude welcome screen in percentage
                                  totalSteps: OnboardingController.totalSteps - 1,
                                )
                              : const SizedBox(height: 36), // Empty spacing placeholder on Welcome Screen
                        ),
                      ),
                    ],
                  ),
                ),

                // Page view holding onboarding pages
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(), // Enforce button validations
                    children: const [
                      WelcomeScreen(),
                      NameScreen(),
                      RoleScreen(),
                      GoalsScreen(),
                      ModulesScreen(),
                      AppearanceScreen(),
                      PermissionsScreen(),
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
