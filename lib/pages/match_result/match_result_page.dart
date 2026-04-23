import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/models/match_result_model.dart';
import 'package:h2s/providers/video_provider.dart';
import 'package:h2s/services/pdf_export_service.dart';
import 'package:h2s/widgets/charts/timeline_bar_chart.dart';
import 'package:h2s/widgets/common/glass_card.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';
import 'package:h2s/widgets/common/sport_badge.dart';

class MatchResultPage extends StatelessWidget {
  final String matchId;
  const MatchResultPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final vp = context.read<VideoProvider>();
    final result = vp.getMatchResultById(matchId);

    if (result == null) {
      return AppShell(
        currentPath: '/dashboard',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded,
                  color: AppColors.textSecondary, size: 64),
              const SizedBox(height: 16),
              Text('Match result not found',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return AppShell(
      currentPath: '/dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, result),
            const SizedBox(height: 28),
            _buildScoreSection(context, result),
            const SizedBox(height: 24),
            if (result.riskLevel == 'High') _buildWarningBanner(context),
            if (result.riskLevel == 'High') const SizedBox(height: 24),
            if (result.matchedScenes.isNotEmpty) ...[
              _buildTimeline(context, result),
              const SizedBox(height: 24),
              _buildMatchedScenesTable(context, result),
            ] else
              _buildNoMatchInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MatchResultModel result) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Match Analysis Report',
                  style: Theme.of(context).textTheme.headlineLarge),
              Text(
                '${result.queryVideoTitle}  →  ${result.matchedVideoTitle}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await PdfExportService.exportMatchReport(result);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF export: $e')),
                );
              }
            }
          },
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
          label: const Text('Export PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection(BuildContext context, MatchResultModel result) {
    final riskColor = RiskLevel.getColor(result.riskLevel);
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 700;
      final scoreWidget = Column(
        children: [
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 12,
            percent: result.similarityScore.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.similarityPercent}%',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Match',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            progressColor: riskColor,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 20),
          RiskBadge(riskLevel: result.riskLevel, large: true),
        ],
      );

      final infoWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.video_file_rounded,
            label: 'Query Video',
            value: result.queryVideoTitle,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.copy_all_rounded,
            label: 'Matched Against',
            value: result.matchedVideoTitle,
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.layers_rounded,
            label: 'Matched Scenes',
            value: '${result.matchedScenes.length} frames matched',
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.query_stats_rounded,
            label: 'Similarity Score',
            value: '${result.similarityPercent}% (${result.riskLevel} Risk)',
            color: riskColor,
          ),
          const SizedBox(height: 24),
          _buildThresholdBar(context, result.similarityScore, result.riskLevel),
        ],
      );

      return GlassCard(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  scoreWidget,
                  const SizedBox(width: 48),
                  Expanded(child: infoWidget),
                ],
              )
            : Column(children: [scoreWidget, const SizedBox(height: 24), infoWidget]),
      );
    });
  }

  Widget _buildThresholdBar(BuildContext context, double score, String riskLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risk Threshold',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
        const SizedBox(height: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.warning, AppColors.danger],
                  stops: [0.0, 0.4, 0.65],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Score marker
            Positioned(
              left: (score * 100).clamp(0, 100) / 100 *
                  (MediaQuery.of(context).size.width - 200).clamp(100, 500),
              top: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: RiskLevel.getColor(riskLevel),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: AppColors.success, fontSize: 11)),
            Text('40%', style: TextStyle(color: AppColors.warning, fontSize: 11)),
            Text('65%+', style: TextStyle(color: AppColors.danger, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded,
                color: AppColors.danger, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠ Possible unauthorized sports media detected.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.danger,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This video shows a high similarity to protected content. '
                  'Manual review and legal action may be required.',
                  style: TextStyle(
                      color: AppColors.danger, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, MatchResultModel result) {
    final scores = result.matchedScenes
        .map((s) => s.similarity)
        .toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Text('Similarity Timeline',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Per-frame similarity scores. Red = High risk, Yellow = Medium, Green = Low.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SimilarityBarChart(scores: scores),
        ],
      ),
    );
  }

  Widget _buildMatchedScenesTable(
      BuildContext context, MatchResultModel result) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.compare_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 10),
                Text('Matched Scenes',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.matchedScenes.length} matches',
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppColors.surface),
              columns: const [
                DataColumn(label: Text('Time (Query)')),
                DataColumn(label: Text('AI Description — Query')),
                DataColumn(label: Text('Time (Match)')),
                DataColumn(label: Text('AI Description — Matched')),
                DataColumn(label: Text('Score')),
              ],
              rows: result.matchedScenes.map((scene) {
                final scoreColor = scene.similarity >= 0.65
                    ? AppColors.danger
                    : scene.similarity >= 0.4
                        ? AppColors.warning
                        : AppColors.success;
                return DataRow(cells: [
                  DataCell(Text(scene.queryTimeLabel,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13))),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(scene.queryCaption,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  DataCell(Text(scene.targetTimeLabel,
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13))),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(scene.targetCaption,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(scene.similarity * 100).round()}%',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchInfo(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 56),
          const SizedBox(height: 16),
          Text('No Significant Matches Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.success,
                  )),
          const SizedBox(height: 8),
          Text(
            'The similarity score is below detection thresholds. '
            'This video is unlikely to contain unauthorized sports media.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
