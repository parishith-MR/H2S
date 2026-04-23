import 'package:flutter/material.dart';
import 'package:h2s/core/constants/app_constants.dart';

/// Animated processing progress bar with stage label.
class AppProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final bool showPercentage;
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.showPercentage = true,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.primary;
    final pct = (progress * 100).clamp(0, 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                if (showPercentage)
                  Text(
                    '$pct%',
                    style: TextStyle(
                      color: barColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            AnimatedFractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor, barColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Processing stage indicator with step list.
class ProcessingStageIndicator extends StatelessWidget {
  final List<ProcessingStage> stages;
  final int currentStageIndex;

  const ProcessingStageIndicator({
    super.key,
    required this.stages,
    required this.currentStageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stages.asMap().entries.map((e) {
        final i = e.key;
        final stage = e.value;
        final isDone = i < currentStageIndex;
        final isActive = i == currentStageIndex;

        Color dotColor;
        if (isDone) {
          dotColor = AppColors.success;
        } else if (isActive) {
          dotColor = AppColors.primary;
        } else {
          dotColor = AppColors.border;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded, color: dotColor, size: 16)
                      : isActive
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: dotColor,
                              ),
                            )
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                stage.label,
                style: TextStyle(
                  color: isActive || isDone
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ProcessingStage {
  final String label;
  const ProcessingStage(this.label);
}
