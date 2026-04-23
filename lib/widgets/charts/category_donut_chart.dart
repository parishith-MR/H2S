import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:h2s/core/constants/app_constants.dart';

class CategoryDonutChart extends StatefulWidget {
  final Map<String, int> data;
  final double size;

  const CategoryDonutChart({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No data yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final entries = widget.data.entries.toList();
    final total = entries.fold(0, (s, e) => s + e.value);

    return Row(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.size * 0.28,
              sections: entries.asMap().entries.map((e) {
                final i = e.key;
                final category = e.value.key;
                final count = e.value.value;
                final isTouched = i == _touchedIndex;
                final color = AppColors.categoryColors[category] ??
                    AppColors.textSecondary;
                final pct = total > 0 ? (count / total * 100).round() : 0;

                return PieChartSectionData(
                  color: color,
                  value: count.toDouble(),
                  title: isTouched ? '$pct%' : '',
                  radius: isTouched ? widget.size * 0.22 : widget.size * 0.18,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  badgeWidget: null,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((e) {
              final color =
                  AppColors.categoryColors[e.key] ?? AppColors.textSecondary;
              final pct =
                  total > 0 ? (e.value / total * 100).round() : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '${e.value}  ($pct%)',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
