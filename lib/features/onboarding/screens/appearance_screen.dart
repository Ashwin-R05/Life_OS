import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/selection_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/glass_card.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<OnboardingController>(context);
    final selectedTheme = controller.profile.appearance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'DESIGN',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How should LifeOS feel?',
            style: theme.textTheme.displayLarge?.copyWith(
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),

          // Live Preview visual mock widget
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interface Preview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary)),
                      ],
                    )
                  ],
                ),
                const Divider(height: 20, thickness: 0.5),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: theme.colorScheme.onSecondary.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: theme.colorScheme.onSecondary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                SelectionTile(
                  title: 'Dark Mode',
                  subtitle: 'Premium cyber-obsidian styling with high contrast',
                  icon: '🌌',
                  isSelected: selectedTheme == 'Dark',
                  onTap: () => controller.updateAppearance('Dark'),
                ),
                const SizedBox(height: 12),
                SelectionTile(
                  title: 'Light Mode',
                  subtitle: 'Clean ice-white workspace look',
                  icon: '☀️',
                  isSelected: selectedTheme == 'Light',
                  onTap: () => controller.updateAppearance('Light'),
                ),
                const SizedBox(height: 12),
                SelectionTile(
                  title: 'System Default',
                  subtitle: 'Matches your native operating system style',
                  icon: '⚙️',
                  isSelected: selectedTheme == 'System',
                  onTap: () => controller.updateAppearance('System'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Continue',
            onPressed: () => controller.nextStep(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
