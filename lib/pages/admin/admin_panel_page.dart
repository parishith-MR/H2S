import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/models/user_model.dart';
import 'package:h2s/providers/auth_provider.dart';
import 'package:h2s/providers/dashboard_provider.dart';
import 'package:h2s/widgets/common/glass_card.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';
import 'package:h2s/widgets/common/sport_badge.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (!auth.isAdmin) {
      return AppShell(
        currentPath: '/admin',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded,
                  color: AppColors.danger, size: 64),
              const SizedBox(height: 16),
              Text('Access Denied',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'You need admin privileges to access this panel.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return AppShell(
      currentPath: '/admin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Panel',
                            style:
                                Theme.of(context).textTheme.headlineLarge),
                        Text('Moderate content and manage users',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabCtrl,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Video Moderation'),
                    Tab(text: 'User Management'),
                    Tab(text: 'System Stats'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (_, dash, __) => TabBarView(
                controller: _tabCtrl,
                children: [
                  _VideoModerationTab(dash: dash),
                  _UserManagementTab(users: dash.allUsers.cast<UserModel>()),
                  _SystemStatsTab(dash: dash),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoModerationTab extends StatelessWidget {
  final DashboardProvider dash;
  const _VideoModerationTab({required this.dash});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('All Videos (${dash.totalVideos})',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            const Divider(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surface),
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Frames')),
                  DataColumn(label: Text('Uploaded')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: dash.allVideos.map((v) {
                  return DataRow(cells: [
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(v.title,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    DataCell(SportBadge(category: v.category, small: true)),
                    DataCell(StatusBadge(status: v.status)),
                    DataCell(Text('${v.frameCount}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13))),
                    DataCell(Text(
                        DateFormat('MMM dd, yyyy').format(v.uploadedAt),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Row(
                      children: [
                        if (!v.isFlagged)
                          _ActionButton(
                            icon: Icons.flag_rounded,
                            color: AppColors.danger,
                            tooltip: 'Flag',
                            onTap: () {
                              dash.flagVideo(v.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Video flagged.')),
                              );
                            },
                          ),
                        _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.textSecondary,
                          tooltip: 'Delete',
                          onTap: () {
                            dash.deleteVideo(v.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Video deleted.')),
                            );
                          },
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  final List<UserModel> users;
  const _UserManagementTab({required this.users});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Registered Users (${users.length})',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const Divider(height: 1),
            ...users.map(
              (u) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        u.name.isEmpty
                            ? u.email[0].toUpperCase()
                            : u.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name.isEmpty ? 'Unknown' : u.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            u.email,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: u.isAdmin
                            ? AppColors.accent.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: u.isAdmin
                              ? AppColors.accent.withOpacity(0.3)
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        u.role.toUpperCase(),
                        style: TextStyle(
                          color: u.isAdmin
                              ? AppColors.accent
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy').format(u.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatsTab extends StatelessWidget {
  final DashboardProvider dash;
  const _SystemStatsTab({required this.dash});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _SystemStatCard(
            'Total Users',
            '${dash.allUsers.length}',
            Icons.people_rounded,
            AppColors.primary,
          ),
          _SystemStatCard(
            'Total Videos',
            '${dash.totalVideos}',
            Icons.video_library_rounded,
            AppColors.accent,
          ),
          _SystemStatCard(
            'Flagged Videos',
            '${dash.flaggedVideos}',
            Icons.flag_rounded,
            AppColors.danger,
          ),
          _SystemStatCard(
            'Total Scans',
            '${dash.totalScans}',
            Icons.manage_search_rounded,
            AppColors.warning,
          ),
          _SystemStatCard(
            'High Risk',
            '${dash.highRiskResults.length}',
            Icons.warning_rounded,
            AppColors.danger,
          ),
          _SystemStatCard(
            'Protected',
            '${dash.protectedVideos}',
            Icons.shield_rounded,
            AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _SystemStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SystemStatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onTap,
      ),
    );
  }
}
