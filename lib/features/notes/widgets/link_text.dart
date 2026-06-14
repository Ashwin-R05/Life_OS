import 'package:flutter/material.dart';
import '../services/link_parser.dart';

class LinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final Function(String noteId) onLinkTap;

  const LinkText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final segments = LinkParser.parse(text);

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return RichText(
      text: TextSpan(
        style: style ?? theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          height: 1.6,
          color: theme.textTheme.bodyLarge?.color,
        ),
        children: segments.map((segment) {
          if (segment.isLink) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => onLinkTap(segment.noteId!),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          segment.text,
                          style: linkStyle ?? TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return TextSpan(
              text: segment.text,
              style: style ?? theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
