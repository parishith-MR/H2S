import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:h2s/core/constants/app_constants.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background orbs
          _AnimatedBackground(controller: _bgCtrl),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildNav(context),
                _buildHero(context),
                _buildFeatures(context),
                _buildStats(context),
                _buildHowItWorks(context),
                _buildCTA(context),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Row(
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
              Text(
                AppStrings.appName,
                style: GoogleFonts.exo2(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ).createShader(
                        const Rect.fromLTWH(0, 0, 200, 30)),
                ),
              ),
            ],
          ),
          const Spacer(),
          _NavLink(label: 'Features', onTap: () {}),
          const SizedBox(width: 24),
          _NavLink(label: 'How It Works', onTap: () {}),
          const SizedBox(width: 32),
          OutlinedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Log in'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
          child: Column(
            children: [
              // Chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Powered Sports Media Protection',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Headline
              SizedBox(
                width: 800,
                child: Column(
                  children: [
                    Text(
                      'Shield Every Frame.',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            fontSize: 64,
                            height: 1.1,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Protect Every Play.',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                              fontSize: 64,
                              height: 1.1,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Animated subtitle
              SizedBox(
                height: 28,
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Detect unauthorized media reuse in seconds.',
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      'Protect your sports content with AI precision.',
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                      speed: const Duration(milliseconds: 50),
                    ),
                    TypewriterAnimatedText(
                      'Flag piracy before it spreads.',
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                      speed: const Duration(milliseconds: 50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // CTA buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GlowButton(
                    label: 'Upload Video',
                    icon: Icons.upload_rounded,
                    onTap: () => context.go('/signup'),
                    isPrimary: true,
                  ),
                  const SizedBox(width: 16),
                  _GlowButton(
                    label: 'View Dashboard',
                    icon: Icons.dashboard_rounded,
                    onTap: () => context.go('/signup'),
                    isPrimary: false,
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_circle_outline_rounded,
                        size: 18),
                    label: const Text('Learn More'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Preview mockup
              _buildDashboardPreview(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPreview(BuildContext context) {
    return Container(
      width: 900,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Mini sidebar
            Container(
              width: 56,
              color: AppColors.card,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        [
                          Icons.dashboard_rounded,
                          Icons.upload_rounded,
                          Icons.manage_search_rounded,
                          Icons.analytics_rounded,
                          Icons.admin_panel_settings_rounded,
                        ][i],
                        color: i == 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.exo2(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _MiniStatCard(
                            '48', 'Videos Protected', AppColors.primary),
                        const SizedBox(width: 12),
                        _MiniStatCard('3', 'Flagged', AppColors.danger),
                        const SizedBox(width: 12),
                        _MiniStatCard('12', 'Scans Run', AppColors.accent),
                        const SizedBox(width: 12),
                        _MiniStatCard('99%', 'Accuracy', AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Alerts',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    3,
                                    (i) => _MiniAlertRow(i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'By Category',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...['Football', 'Cricket', 'Tennis',
                                      'Basketball']
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: [
                                                    AppColors.primary,
                                                    AppColors.success,
                                                    AppColors.warning,
                                                    AppColors.danger,
                                                  ][e.key],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  e.value,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${[18, 12, 9, 6][e.key]}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildFeatures(BuildContext context) {
    final features = [
      _FeatureData(
        Icons.upload_file_rounded,
        'Smart Upload',
        'Upload any sports video and let our pipeline process it automatically.',
        AppColors.primary,
      ),
      _FeatureData(
        Icons.smart_toy_rounded,
        'AI Frame Analysis',
        'Every second is analyzed and described using next-gen AI vision.',
        AppColors.accent,
      ),
      _FeatureData(
        Icons.compare_rounded,
        'Similarity Engine',
        'Jaccard-based text similarity detects even subtle content reuse.',
        AppColors.success,
      ),
      _FeatureData(
        Icons.warning_amber_rounded,
        'Instant Alerts',
        'Receive immediate risk assessments: Low, Medium, or High.',
        AppColors.warning,
      ),
      _FeatureData(
        Icons.analytics_rounded,
        'Rich Dashboard',
        'Charts, stats, and reports at a glance with category breakdowns.',
        AppColors.danger,
      ),
      _FeatureData(
        Icons.picture_as_pdf_rounded,
        'PDF Reports',
        'Export detailed match reports for legal and compliance documentation.',
        AppColors.primaryDark,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      child: Column(
        children: [
          _SectionLabel('FEATURES'),
          const SizedBox(height: 12),
          Text(
            'Everything You Need to\nProtect Your Content',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 800 ? 3 : 2;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: features.map((f) {
                return SizedBox(
                  width: (constraints.maxWidth - (cols - 1) * 20) / cols,
                  child: _FeatureCard(feature: f),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        border: const Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCounter('10K+', 'Videos Protected'),
          _StatDivider(),
          _StatCounter('99.2%', 'Detection Accuracy'),
          _StatDivider(),
          _StatCounter('< 30s', 'Processing Time'),
          _StatDivider(),
          _StatCounter('10+', 'Sports Categories'),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      ('1', 'Upload Official Video',
          'Register your sports footage with title, category, and tags.'),
      ('2', 'AI Frame Processing',
          'We extract 1 frame per second and generate AI descriptions.'),
      ('3', 'Store Fingerprints',
          'Frame captions are stored as a unique content fingerprint.'),
      ('4', 'Verify Suspected Content',
          'Upload any suspect video to run similarity comparison.'),
      ('5', 'Get Risk Assessment',
          'Receive a detailed match report with similarity score and flagged scenes.'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      child: Column(
        children: [
          _SectionLabel('HOW IT WORKS'),
          const SizedBox(height: 12),
          Text(
            'From Upload to Protection\nin Minutes',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _StepRow(
                number: s.$1,
                title: s.$2,
                description: s.$3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.accent.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Protect\nYour Sports Content?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 40,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of sports organizations using SportShield AI.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GlowButton(
                label: 'Start Free Trial',
                icon: Icons.rocket_launch_rounded,
                onTap: () => context.go('/signup'),
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.appName,
                style: GoogleFonts.exo2(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.version,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            '© 2026 SportShield AI. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _OrbPainter(controller.value),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final pi = 3.14159265;
    void drawOrb(double cx, double cy, double r, Color c) {
      final paint = Paint()
        ..color = c
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    final dx = sin(t * 2 * pi) * size.width * 0.08;
    final dy = cos(t * 2 * pi) * size.height * 0.08;

    drawOrb(size.width * 0.15 + dx, size.height * 0.2 + dy, 260,
        AppColors.primary.withOpacity(0.07));
    drawOrb(size.width * 0.85 - dx, size.height * 0.7 - dy, 300,
        AppColors.accent.withOpacity(0.07));
    drawOrb(size.width * 0.5, size.height * 0.1, 200,
        AppColors.primary.withOpacity(0.04));
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hov ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppColors.primaryGradient : null,
            color: widget.isPrimary ? null : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : AppColors.border,
            ),
            boxShadow: _hov && widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.white : AppColors.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color:
                      widget.isPrimary ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _FeatureData(this.icon, this.title, this.description, this.color);
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hov ? AppColors.cardHover : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hov
                ? widget.feature.color.withOpacity(0.3)
                : AppColors.border,
          ),
          boxShadow: _hov
              ? [
                  BoxShadow(
                    color: widget.feature.color.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.feature.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.feature.icon,
                  color: widget.feature.color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              widget.feature.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.feature.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _StatCounter extends StatelessWidget {
  final String value;
  final String label;
  const _StatCounter(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            value,
            style: GoogleFonts.exo2(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 60,
        color: AppColors.border,
      );
}

class _StepRow extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  const _StepRow(
      {required this.number,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStatCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAlertRow extends StatelessWidget {
  final int index;
  const _MiniAlertRow(this.index);

  @override
  Widget build(BuildContext context) {
    final risks = ['High', 'Medium', 'Low'];
    final titles = ['World Cup Video', 'IPL Finals', 'NBA Game 7'];
    final colors = [AppColors.danger, AppColors.warning, AppColors.success];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              titles[index],
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors[index].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              risks[index],
              style: TextStyle(
                  fontSize: 9,
                  color: colors[index],
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
