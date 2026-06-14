import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/focus_controller.dart';

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // 8-second breathing cycle: 4s inhale, 4s exhale
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Study': return const Color(0xFF6366F1);
      case 'Work': return const Color(0xFF3B82F6);
      case 'Coding': return const Color(0xFF10B981);
      default: return const Color(0xFFF59E0B);
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Study': return '📚';
      case 'Work': return '💼';
      case 'Coding': return '💻';
      default: return '📖';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final controller = Provider.of<FocusController>(context);

    // If session finished, show celebratory overlay
    if (controller.justCompletedSession) {
      return Scaffold(
        body: Stack(
          children: [
            // Dark backdrop blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            ),
                            child: Icon(Icons.celebration_rounded, size: 54, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Session Completed!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Great job focusing on ${_getCategoryEmoji(controller.activeCategory)} ${controller.activeCategory}.\nYour Second Brain thanks you.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          GestureDetector(
                            onTap: () {
                              controller.resetCompletionFlag();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'Back to Dashboard',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final categoryColor = _getCategoryColor(controller.activeCategory);
    final progress = controller.durationSeconds > 0 
        ? (controller.remainingSeconds / controller.durationSeconds) 
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black, // Dark focus environment
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          
          Positioned(
            bottom: 150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Exit button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 28),
                      onPressed: () {
                        // Show warning before exiting
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E2E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('End Focus Session?', style: TextStyle(color: Colors.white)),
                            content: const Text('Your current progress will not be saved.', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.cancelFocusSession();
                                  Navigator.of(ctx).pop(); // pop dialog
                                  Navigator.of(context).pop(); // pop timer screen
                                },
                                child: const Text('Stop Session', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const Spacer(),

                // Category Title
                Text(
                  '${_getCategoryEmoji(controller.activeCategory)}  ${controller.activeCategory.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  controller.isPaused ? 'SESSION PAUSED' : 'STAY FOCUSED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 48),

                // Center Timer & Breathing animation
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: CustomPaint(
                      painter: TimerPainter(
                        progress: progress,
                        progressColor: categoryColor,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _breathingAnimation,
                          builder: (context, child) {
                            // Scale breathing circle based on active/paused timer status
                            final scale = controller.isPaused ? 1.0 : _breathingAnimation.value;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: categoryColor.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: categoryColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatTime(controller.remainingSeconds),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Immersive Controls row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Play / Pause button
                      GestureDetector(
                        onTap: () {
                          if (controller.isPaused) {
                            controller.resumeFocusSession();
                            _breathingController.repeat(reverse: true);
                          } else {
                            controller.pauseFocusSession();
                            _breathingController.stop();
                          }
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: categoryColor.withValues(alpha: 0.15),
                            border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Icon(
                            controller.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  TimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    canvas.drawCircle(center, radius, paint);

    // Draw progress arc starting from top (-pi / 2)
    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
