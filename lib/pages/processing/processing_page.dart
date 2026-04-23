import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/providers/video_provider.dart';
import 'package:h2s/widgets/common/app_progress_bar.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';

class ProcessingPage extends StatefulWidget {
  final String videoId;
  const ProcessingPage({super.key, required this.videoId});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _stages = [
    ProcessingStage('Uploading video metadata'),
    ProcessingStage('Extracting frames (1/sec)'),
    ProcessingStage('Generating AI captions'),
    ProcessingStage('Saving to database'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  int _getStageIndex(VideoProcessingStatus status) {
    switch (status) {
      case VideoProcessingStatus.uploading:
        return 0;
      case VideoProcessingStatus.extractingFrames:
        return 1;
      case VideoProcessingStatus.generatingCaptions:
        return 2;
      case VideoProcessingStatus.complete:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/upload',
      child: Consumer<VideoProvider>(
        builder: (_, vp, __) {
          final isComplete =
              vp.processingStatus == VideoProcessingStatus.complete;
          final stageIndex = _getStageIndex(vp.processingStatus);

          // Auto-navigate when done
          if (isComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) context.go('/dashboard');
              });
            });
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                children: [
                  // Icon
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: isComplete ? 1 : _pulseAnim.value,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isComplete
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: isComplete
                                  ? AppColors.success.withOpacity(0.25)
                                  : AppColors.primary.withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isComplete
                              ? Icons.check_circle_rounded
                              : Icons.smart_toy_rounded,
                          color: isComplete ? AppColors.success : AppColors.primary,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    isComplete
                        ? 'Processing Complete!'
                        : 'AI Processing In Progress',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isComplete
                        ? 'Your video has been fingerprinted and is now protected.'
                        : 'Analyzing your video frame by frame...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Main progress card
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frames Processed',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${vp.currentFrame} / ${vp.totalFrames}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppProgressBar(
                          progress: vp.processingProgress,
                          height: 10,
                          color: isComplete
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(height: 28),

                        ProcessingStageIndicator(
                          stages: _stages,
                          currentStageIndex: stageIndex,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Live captions feed
                  if (vp.recentCaptions.isNotEmpty)
                    Container(
                      width: 600,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.accent, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Live Caption Feed',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...vp.recentCaptions.asMap().entries.map(
                                (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: e.key == 0
                                          ? AppColors.primary.withOpacity(0.15)
                                          : AppColors.border,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: TextStyle(
                                          color: e.key == 0
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        color: e.key == 0
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: e.key == 0
                                            ? FontWeight.w500
                                            : FontWeight.w400,
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

                  if (isComplete) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded,
                              color: AppColors.success, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Redirecting to Dashboard in 2 seconds...',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Go to Dashboard Now'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
