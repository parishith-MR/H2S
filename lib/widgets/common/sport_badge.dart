import 'package:flutter/material.dart';
import 'package:h2s/core/constants/app_constants.dart';

/// Colored badge showing sport category.
class SportBadge extends StatelessWidget {
  final String category;
  final bool small;

  const SportBadge({
    super.key,
    required this.category,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[category] ?? AppColors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 5 : 6,
            height: small ? 5 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge for video status.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'flagged':
        color = AppColors.danger;
        icon = Icons.flag_rounded;
        label = 'Flagged';
        break;
      case 'processing':
        color = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
        label = 'Processing';
        break;
      default:
        color = AppColors.success;
        icon = Icons.shield_rounded;
        label = 'Protected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Risk level pill badge.
class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final bool large;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = RiskLevel.getColor(riskLevel);
    final icon = RiskLevel.getIcon(riskLevel);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: large ? 18 : 14),
          const SizedBox(width: 6),
          Text(
            '$riskLevel Risk',
            style: TextStyle(
              color: color,
              fontSize: large ? 14 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
