import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/onboarding/widgets/glass_card.dart';
import '../../features/onboarding/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<OnboardingController>(context);
    final profile = controller.profile;

    return Scaffold(
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header Card
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to LifeOS,',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profile.name.isNotEmpty ? profile.name : 'Workspace User',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            profile.role.isNotEmpty ? profile.role : 'Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'YOUR MODULES',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Modules list display
                  SizedBox(
                    height: 120,
                    child: profile.modules.isEmpty
                        ? Center(
                            child: Text(
                              'No modules selected.',
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: profile.modules.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final module = profile.modules[index];
                              return SizedBox(
                                width: 140,
                                child: GlassCard(
                                  borderRadius: 18,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getModuleIcon(module),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _getModuleTitle(module),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'CONFIGURATION DETAIL',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Selections details
                  Expanded(
                    child: ListView(
                      children: [
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(context, 'Primary Focus', profile.role),
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(context, 'Appearance Style', profile.appearance),
                              const Divider(height: 24, thickness: 0.5),
                              Text(
                                'Selected Targets',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: profile.goals.map((goalId) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getGoalTitle(goalId),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Reset Workspace',
                    icon: Icons.refresh,
                    onPressed: () => controller.resetOnboarding(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  String _getModuleIcon(String id) {
    switch (id) {
      case 'notes': return '📝';
      case 'tasks': return '✔️';
      case 'habits': return '🔄';
      case 'screentime': return '⏱️';
      default: return '📦';
    }
  }

  String _getModuleTitle(String id) {
    switch (id) {
      case 'notes': return 'Notes';
      case 'tasks': return 'Tasks';
      case 'habits': return 'Habits';
      case 'screentime': return 'Screen Time';
      default: return 'Module';
    }
  }

  String _getGoalTitle(String id) {
    switch (id) {
      case 'study': return '🎓 Study Better';
      case 'social': return '📱 Reduce Social Media';
      case 'consistency': return '⚡ Build Consistency';
      case 'projects': return '📂 Organize Projects';
      case 'coding': return '💻 Improve Coding';
      default: return 'Goal';
    }
  }
}
