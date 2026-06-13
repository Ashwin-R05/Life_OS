import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/selection_tile.dart';
import '../widgets/primary_button.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<OnboardingController>(context);
    final selectedModules = controller.profile.modules;

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
                    Text(
                      'WORKSPACE',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your workspace',
                      style: theme.textTheme.displayLarge?.copyWith(
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select which modular dashboards to activate in your LifeOS.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: List.generate(AppConstants.modules.length, (index) {
                        final module = AppConstants.modules[index];
                        final moduleId = module['id']!;
                        final isSelected = selectedModules.contains(moduleId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SelectionTile(
                            title: module['title']!,
                            subtitle: module['subtitle']!,
                            icon: module['icon']!,
                            isSelected: isSelected,
                            onTap: () => controller.toggleModule(moduleId),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: selectedModules.isNotEmpty ? () => controller.nextStep(context) : null,
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
