import 'package:flutter/material.dart';
import 'package:h2s/core/constants/app_constants.dart';

/// Glassmorphism card with optional gradient border.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool hasGradientBorder;
  final bool hoverable;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.hasGradientBorder = false,
    this.hoverable = false,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ??
        BorderRadius.circular(AppSizes.borderRadius);

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _hovering && widget.hoverable
            ? AppColors.cardHover
            : AppColors.card,
        borderRadius: br,
        border: widget.hasGradientBorder
            ? null
            : Border.all(color: AppColors.border, width: 1),
        boxShadow: _hovering && widget.hoverable
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: widget.padding ??
            const EdgeInsets.all(AppSizes.cardPadding),
        child: widget.child,
      ),
    );

    if (widget.hasGradientBorder) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: br,
          gradient: AppColors.primaryGradient,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: br.subtract(const BorderRadius.all(Radius.circular(1.5))),
          child: card,
        ),
      );
    }

    if (widget.hoverable || widget.onTap != null) {
      card = ScaleTransition(
        scale: _scaleAnim,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _hovering = true);
            if (widget.hoverable) _ctrl.forward();
          },
          onExit: (_) {
            setState(() => _hovering = false);
            if (widget.hoverable) _ctrl.reverse();
          },
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: GestureDetector(
            onTap: widget.onTap,
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

/// Gradient-filled stat card for dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverable: true,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accentColor,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
