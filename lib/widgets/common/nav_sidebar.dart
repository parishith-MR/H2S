import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/providers/auth_provider.dart';

/// Top-level app shell that wraps authenticated pages with the sidebar.
class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavSidebar(currentPath: currentPath),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class NavSidebar extends StatelessWidget {
  final String currentPath;

  const NavSidebar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      width: AppSizes.navWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logo section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SportShield',
                      style: GoogleFonts.exo2(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'AI',
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: '/dashboard',
                  currentPath: currentPath,
                ),
                _NavItem(
                  icon: Icons.upload_rounded,
                  label: 'Upload Video',
                  route: '/upload',
                  currentPath: currentPath,
                ),
                _NavItem(
                  icon: Icons.manage_search_rounded,
                  label: 'Verify Video',
                  route: '/verify',
                  currentPath: currentPath,
                  accentColor: AppColors.warning,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: Text(
                    'ANALYSIS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                if (auth.isAdmin)
                  _NavItem(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Admin Panel',
                    route: '/admin',
                    currentPath: currentPath,
                    accentColor: AppColors.accent,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // User section
          if (auth.user != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      auth.user!.name.isNotEmpty
                          ? auth.user!.name[0].toUpperCase()
                          : auth.user!.email[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user!.name.isNotEmpty
                              ? auth.user!.name
                              : 'User',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: auth.isAdmin
                                ? AppColors.accent.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            auth.isAdmin ? 'Admin' : 'User',
                            style: TextStyle(
                              color: auth.isAdmin
                                  ? AppColors.accent
                                  : AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        size: 16, color: AppColors.textSecondary),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      auth.logout();
                      context.go('/');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentPath;
  final Color? accentColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentPath,
    this.accentColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentPath == widget.route ||
        widget.currentPath.startsWith(widget.route + '/');
    final color = widget.accentColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.12)
                : _hovering
                    ? AppColors.cardHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: isActive ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color:
                      isActive ? color : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
