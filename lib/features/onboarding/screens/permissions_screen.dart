import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  static const _platform = MethodChannel('com.example.life_os/permissions');
  
  bool _notificationGranted = false;
  bool _usageStatsOpened = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificationGranted = status.isGranted;
      });
      final controller = Provider.of<OnboardingController>(context, listen: false);
      controller.updateNotificationPermission(status.isGranted);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() {
        _notificationGranted = status.isGranted;
      });
      final controller = Provider.of<OnboardingController>(context, listen: false);
      controller.updateNotificationPermission(status.isGranted);
    }
  }

  Future<void> _openUsageStatsSettings() async {
    try {
      await _platform.invokeMethod('openUsageAccessSettings');
      if (mounted) {
        setState(() {
          _usageStatsOpened = true;
        });
        final controller = Provider.of<OnboardingController>(context, listen: false);
        controller.updateUsageAccessPermission(true);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to launch usage access settings: '${e.message}'.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open settings: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Provider.of<OnboardingController>(context);

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
                      'PERMISSIONS',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'System integration',
                      style: theme.textTheme.displayLarge?.copyWith(
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enable integrations to unlock automated workspace trackers.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Notifications Permission Panel
                    GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      customBorderColor: _notificationGranted 
                          ? theme.colorScheme.primary.withValues(alpha: 0.5) 
                          : null,
                      child: Row(
                        children: [
                          const Text('🔔', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Push Notifications',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Habit reminders, task alerts & smart digests.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _notificationGranted ? null : _requestNotificationPermission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _notificationGranted 
                                  ? Colors.transparent 
                                  : theme.colorScheme.primary.withValues(alpha: 0.1),
                              shadowColor: Colors.transparent,
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(
                                color: _notificationGranted ? Colors.transparent : theme.colorScheme.primary,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _notificationGranted ? 'Active' : 'Enable',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Usage Access Permission Panel (Android only feel)
                    GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      customBorderColor: _usageStatsOpened 
                          ? theme.colorScheme.secondary.withValues(alpha: 0.5) 
                          : null,
                      child: Row(
                        children: [
                          const Text('⏱️', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usage Access',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Read app usage stats to block screens and manage distraction tracking.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _openUsageStatsSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _usageStatsOpened 
                                  ? Colors.transparent 
                                  : theme.colorScheme.secondary.withValues(alpha: 0.1),
                              shadowColor: Colors.transparent,
                              foregroundColor: theme.colorScheme.secondary,
                              side: BorderSide(
                                color: _usageStatsOpened ? Colors.transparent : theme.colorScheme.secondary,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _usageStatsOpened ? 'Opened' : 'Configure',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Finish Configuration',
                      onPressed: () => controller.nextStep(context),
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
