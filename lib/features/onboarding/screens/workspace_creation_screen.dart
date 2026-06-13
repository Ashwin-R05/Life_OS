import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/glass_card.dart';

class WorkspaceCreationScreen extends StatefulWidget {
  const WorkspaceCreationScreen({super.key});

  @override
  State<WorkspaceCreationScreen> createState() => _WorkspaceCreationScreenState();
}

class _WorkspaceCreationScreenState extends State<WorkspaceCreationScreen> {
  int _currentPhraseIndex = 0;
  double _progress = 0.0;
  late Timer _phraseTimer;
  late Timer _progressTimer;

  final List<String> _loadingPhrases = [
    'Initializing local database...',
    'Writing encrypted keys...',
    'Customizing UI widgets layout...',
    'Optimizing modular dashboards...',
    'Generating markdown vault links...',
    'Workspace ready!',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    const totalDuration = Duration(milliseconds: 2800);
    const progressInterval = Duration(milliseconds: 28);
    final totalSteps = totalDuration.inMilliseconds / progressInterval.inMilliseconds;
    final increment = 1.0 / totalSteps;

    // Progress bar animation
    _progressTimer = Timer.periodic(progressInterval, (timer) {
      if (mounted) {
        setState(() {
          if (_progress >= 1.0) {
            _progress = 1.0;
            _progressTimer.cancel();
          } else {
            _progress += increment;
          }
        });
      }
    });

    // Phrase switching animation
    final phraseInterval = Duration(milliseconds: (totalDuration.inMilliseconds / _loadingPhrases.length).round());
    _phraseTimer = Timer.periodic(phraseInterval, (timer) async {
      if (mounted) {
        if (_currentPhraseIndex < _loadingPhrases.length - 1) {
          setState(() {
            _currentPhraseIndex++;
          });
        } else {
          _phraseTimer.cancel();
          // Finalize onboarding and navigate home
          final controller = Provider.of<OnboardingController>(context, listen: false);
          await controller.saveProfileAndComplete();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _phraseTimer.cancel();
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background glowing spheres
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassCard(
                borderRadius: 28,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    // Glass circular loader with breathing animation
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            backgroundColor: isDark 
                                ? Colors.white.withValues(alpha: 0.05) 
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        // Inner pulsing core
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(
                              '${(_progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Creating your workspace...',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Animated switching text phrase
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _loadingPhrases[_currentPhraseIndex],
                        key: ValueKey<int>(_currentPhraseIndex),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
