import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/models/match_result_model.dart';
import 'package:h2s/models/video_model.dart';
import 'package:h2s/providers/dashboard_provider.dart';
import 'package:h2s/widgets/charts/category_donut_chart.dart';
import 'package:h2s/widgets/common/glass_card.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';
import 'package:h2s/widgets/common/sport_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/dashboard',
      child: Consumer<DashboardProvider>(
        builder: (_, dash, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, dash),
                const SizedBox(height: 24),
                _buildStats(context, dash),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 5,
                                child: _buildRecentAlerts(context, dash)),
                            const SizedBox(width: 20),
                            Expanded(
                                flex: 4,
                                child: _buildCategoryChart(context, dash)),
                          ],
                        )
                      : Column(children: [
                          _buildRecentAlerts(context, dash),
                          const SizedBox(height: 20),
                          _buildCategoryChart(context, dash),
                        ]);
                }),
                const SizedBox(height: 24),
                _buildVideosTable(context, dash),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardProvider dash) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: Theme.of(context).textTheme.headlineLarge),
              Text('Overview of your protected content and alerts',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => context.go('/upload'),
          icon: const Icon(Icons.upload_rounded, size: 16),
          label: const Text('Upload Video'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/verify'),
          icon: const Icon(Icons.manage_search_rounded, size: 16),
          label: const Text('Verify Video'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warning,
            side: const BorderSide(color: AppColors.warning),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, DashboardProvider dash) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _statCardSized(
            constraints,
            StatCard(
              label: 'Videos Protected',
              value: '${dash.totalVideos}',
              icon: Icons.shield_rounded,
              accentColor: AppColors.primary,
              subtitle: '${dash.protectedVideos} ready',
            ),
          ),
          _statCardSized(
            constraints,
            StatCard(
              label: 'Flagged Videos',
              value: '${dash.flaggedVideos}',
              icon: Icons.flag_rounded,
              accentColor: AppColors.danger,
              subtitle: 'Needs review',
            ),
          ),
          _statCardSized(
            constraints,
            StatCard(
              label: 'Verification Scans',
              value: '${dash.totalScans}',
              icon: Icons.manage_search_rounded,
              accentColor: AppColors.accent,
              subtitle: 'Total runs',
            ),
          ),
          _statCardSized(
            constraints,
            StatCard(
              label: 'High Risk Alerts',
              value: '${dash.highRiskResults.length}',
              icon: Icons.warning_rounded,
              accentColor: AppColors.warning,
              subtitle: 'Action required',
            ),
          ),
        ],
      );
    });
  }

  Widget _statCardSized(BoxConstraints constraints, Widget child) {
    final cols = constraints.maxWidth > 900
        ? 4
        : constraints.maxWidth > 600
            ? 2
            : 1;
    final w = (constraints.maxWidth - (cols - 1) * 16) / cols;
    return SizedBox(width: w, child: child);
  }

  Widget _buildRecentAlerts(BuildContext context, DashboardProvider dash) {
    final alerts = dash.recentAlerts.take(5).toList();
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.danger, size: 18),
                const SizedBox(width: 10),
                Text('Recent Alerts',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No alerts yet. Run verifications to see results.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...alerts.map((a) => _AlertRow(result: a)),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, DashboardProvider dash) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 10),
              Text('By Category',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 20),
          CategoryDonutChart(data: dash.videosByCategory, size: 160),
        ],
      ),
    );
  }

  Widget _buildVideosTable(BuildContext context, DashboardProvider dash) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.video_library_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text('Protected Videos',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                // Search
                SizedBox(
                  width: 200,
                  child: TextField(
                    onChanged: dash.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 16, color: AppColors.textSecondary),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                // Category filter
                _FilterButton(
                  label: dash.categoryFilter,
                  options: ['All', ...AppCategories.all],
                  onSelect: dash.setCategoryFilter,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (dash.allVideos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No videos found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            _VideoTable(videos: dash.allVideos),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final MatchResultModel result;
  const _AlertRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = RiskLevel.getColor(result.riskLevel);
    return InkWell(
      onTap: () => context.go('/match/${result.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(RiskLevel.getIcon(result.riskLevel),
                  color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.queryVideoTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Matched: ${result.matchedVideoTitle}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.similarityPercent}%',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd').format(result.createdAt),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _VideoTable extends StatelessWidget {
  final List<VideoModel> videos;
  const _VideoTable({required this.videos});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface),
        dataRowColor:
            WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.cardHover;
          }
          return Colors.transparent;
        }),
        border: const TableBorder(
          horizontalInside:
              BorderSide(color: AppColors.divider, width: 1),
        ),
        columns: const [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Frames')),
          DataColumn(label: Text('Uploaded')),
          DataColumn(label: Text('Actions')),
        ],
        rows: videos.map((v) {
          return DataRow(cells: [
            DataCell(
              SizedBox(
                width: 200,
                child: Text(
                  v.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(SportBadge(category: v.category, small: true)),
            DataCell(StatusBadge(status: v.status)),
            DataCell(Text(
              '${v.frameCount}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            )),
            DataCell(Text(
              DateFormat('MMM dd, yyyy').format(v.uploadedAt),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            )),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search_rounded,
                      size: 16, color: AppColors.primary),
                  tooltip: 'Verify',
                  onPressed: () => context.go('/verify'),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _FilterButton({
    required this.label,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelect,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => options
          .map((o) => PopupMenuItem(
                value: o,
                child: Text(o,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ))
          .toList(),
    );
  }
}
