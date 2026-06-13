import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/selection_tile.dart';
import '../widgets/primary_button.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<OnboardingController>(context);
    final selectedGoals = controller.profile.goals;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGETS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${selectedGoals.length}/3 SELECTED',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: selectedGoals.length == 3 ? theme.colorScheme.secondary : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What matters most?',
            style: theme.textTheme.displayLarge?.copyWith(
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to 3 priority objectives to focus your dashboard.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: AppConstants.goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = AppConstants.goals[index];
                final goalId = goal['id']!;
                final isSelected = selectedGoals.contains(goalId);

                return SelectionTile(
                  title: goal['title']!,
                  subtitle: goal['subtitle']!,
                  icon: goal['icon']!,
                  isSelected: isSelected,
                  onTap: () {
                    if (!isSelected && selectedGoals.length >= 3) {
                      // Trigger a soft haptic response or subtle feedback if trying to select 4
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Maximum of 3 goals reached.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.9),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      controller.toggleGoal(goalId);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Continue',
            onPressed: selectedGoals.isNotEmpty ? () => controller.nextStep(context) : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
