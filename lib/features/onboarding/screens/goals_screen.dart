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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
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
                    Column(
                      children: List.generate(AppConstants.goals.length, (index) {
                        final goal = AppConstants.goals[index];
                        final goalId = goal['id']!;
                        final isSelected = selectedGoals.contains(goalId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SelectionTile(
                            title: goal['title']!,
                            subtitle: goal['subtitle']!,
                            icon: goal['icon']!,
                            isSelected: isSelected,
                            onTap: () {
                              if (!isSelected && selectedGoals.length >= 3) {
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
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: selectedGoals.isNotEmpty ? () => controller.nextStep(context) : null,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
