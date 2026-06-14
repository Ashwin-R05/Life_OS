import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/usage_log_model.dart';
import '../models/focus_limit_model.dart';

class UsageCard extends StatelessWidget {
  final List<UsageLogModel> logs;
  final List<FocusLimitModel> limits;
  final UsageLogModel todayUsage;

  const UsageCard({
    super.key,
    required this.logs,
    required this.limits,
    required this.todayUsage,
  });

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Social': return Colors.pinkAccent;
      case 'Entertainment': return Colors.cyanAccent;
      case 'Gaming': return Colors.purpleAccent;
      default: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.5);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    // 1. Calculate max minutes for bar height scaling
    int maxMinutes = 60; // minimum scale
    for (final log in logs) {
      if (log.totalMinutes > maxMinutes) {
        maxMinutes = log.totalMinutes;
      }
    }

    return Column(
      children: [
        // A. Bar Chart Card
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY SUMMARY',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bar heights layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: logs.map((log) {
                      final total = log.totalMinutes;
                      final barRatio = maxMinutes > 0 ? (total / maxMinutes) : 0.0;
                      final barHeight = 90.0 * barRatio; // Cap at 90px max height
                      
                      final isToday = log.date.day == todayUsage.date.day;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${total}m',
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.bold,
                              color: isToday ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 14,
                            height: 90,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: 14,
                                  height: barHeight.clamp(4.0, 90.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isToday
                                          ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                                          : [theme.colorScheme.primary.withValues(alpha: 0.6), theme.colorScheme.primary.withValues(alpha: 0.3)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getDayName(log.date),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? theme.colorScheme.primary : null,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // B. Active Daily Limits bars
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY LIMITS GAUGE',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...limits.map((limit) {
                    final used = todayUsage.categoryMinutes[limit.category] ?? 0;
                    final ratio = limit.limitMinutes > 0 ? (used / limit.limitMinutes) : 0.0;
                    final isOver = used >= limit.limitMinutes;
                    final color = _getCategoryColor(limit.category);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                limit.category,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              Text(
                                '${used}m / ${limit.limitMinutes}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isOver 
                                      ? Colors.redAccent 
                                      : limit.isActive ? null : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                                ),
                              ),
                              if (isOver) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 12),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth * ratio.clamp(0.0, 1.0);
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: width,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isOver ? Colors.redAccent : limit.isActive ? color : Colors.grey,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
