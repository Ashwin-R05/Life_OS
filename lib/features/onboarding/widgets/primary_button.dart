import 'package:flutter/material.dart';
import 'glass_card.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Premium styling colors
    final Color buttonColor = isDark
        ? theme.colorScheme.primary.withValues(alpha: isDisabled ? 0.2 : 0.85)
        : theme.colorScheme.primary.withValues(alpha: isDisabled ? 0.3 : 1.0);

    final Color borderGlow = isDark
        ? theme.colorScheme.primary.withValues(alpha: isDisabled ? 0.05 : 0.4)
        : theme.colorScheme.primary.withValues(alpha: isDisabled ? 0.1 : 0.6);

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled
          ? null
          : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor,
                isDark
                    ? theme.colorScheme.secondary.withValues(alpha: isDisabled ? 0.1 : 0.7)
                    : theme.colorScheme.secondary.withValues(alpha: isDisabled ? 0.2 : 0.9),
              ],
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: borderGlow,
                      blurRadius: _isPressed ? 12 : 20,
                      offset: Offset(0, _isPressed ? 4 : 8),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight shimmer overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.isLoading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: isDark ? Colors.black : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
