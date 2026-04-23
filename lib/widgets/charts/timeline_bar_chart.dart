import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:h2s/core/constants/app_constants.dart';

class SimilarityBarChart extends StatelessWidget {
  final List<double> scores; // 0.0 to 1.0 per frame
  final double height;

  const SimilarityBarChart({
    super.key,
    required this.scores,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No frames analyzed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          minY: 0.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.cardHover,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final pct = (rod.toY * 100).round();
                return BarTooltipItem(
                  'Frame ${groupIndex + 1}\n$pct% match',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (scores.length / 5).ceilToDouble().clamp(1, 20),
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${value.toInt() + 1}s',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: scores.asMap().entries.map((e) {
            final score = e.value;
            Color barColor;
            if (score >= 0.65) {
              barColor = AppColors.danger;
            } else if (score >= 0.40) {
              barColor = AppColors.warning;
            } else {
              barColor = AppColors.success;
            }

            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: score,
                  color: barColor,
                  width: (600 / scores.length.clamp(5, 60)).clamp(4, 20),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1.0,
                    color: AppColors.border.withOpacity(0.3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
