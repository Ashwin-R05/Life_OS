import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? customBorderColor;
  final Color? customBackgroundColor;
  final List<BoxShadow>? customShadows;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.blur = 20.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.customBorderColor,
    this.customBackgroundColor,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBackground = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.4);

    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: customShadows ??
            [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: customBackgroundColor ?? defaultBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: customBorderColor ?? defaultBorder,
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (customBackgroundColor ?? defaultBackground).withValues(
                    alpha: (customBackgroundColor ?? defaultBackground).a * 1.5,
                  ),
                  (customBackgroundColor ?? defaultBackground).withValues(
                    alpha: (customBackgroundColor ?? defaultBackground).a * 0.5,
                  ),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
