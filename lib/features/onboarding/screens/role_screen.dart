import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/selection_tile.dart';
import '../widgets/primary_button.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<OnboardingController>(context);
    final selectedRole = controller.profile.role;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'FOCUS',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your role',
            style: theme.textTheme.displayLarge?.copyWith(
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize LifeOS to fit your daily focus areas.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                SelectionTile(
                  title: 'Student',
                  subtitle: 'Optimized for study tracker, notes, and habits',
                  icon: '🎓',
                  isSelected: selectedRole == 'Student',
                  onTap: () => controller.updateRole('Student'),
                ),
                const SizedBox(height: 16),
                SelectionTile(
                  title: 'Developer',
                  subtitle: 'Focused on project boards, tasks, and screen limits',
                  icon: '💻',
                  isSelected: selectedRole == 'Developer',
                  onTap: () => controller.updateRole('Developer'),
                ),
                const SizedBox(height: 16),
                SelectionTile(
                  title: 'Both',
                  subtitle: 'Hybrid workspace featuring all modules',
                  icon: '🚀',
                  isSelected: selectedRole == 'Both',
                  onTap: () => controller.updateRole('Both'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Continue',
            onPressed: selectedRole.isNotEmpty ? () => controller.nextStep(context) : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
