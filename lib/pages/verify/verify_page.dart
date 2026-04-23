import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/providers/auth_provider.dart';
import 'package:h2s/providers/video_provider.dart';
import 'package:h2s/widgets/common/app_progress_bar.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _titleCtrl = TextEditingController();
  String _selectedCategory = AppCategories.all.first;
  PlatformFile? _pickedFile;
  bool _isVerifying = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _verify() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video to verify.')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final auth = context.read<AuthProvider>();
    final videoProvider = context.read<VideoProvider>();

    final matchResultId = await videoProvider.verifyVideo(
      userId: auth.user!.id,
      title: _titleCtrl.text.isEmpty
          ? 'Untitled Verification'
          : _titleCtrl.text.trim(),
      category: _selectedCategory,
      fileSizeBytes: _pickedFile!.size,
      fileName: _pickedFile!.name,
    );

    if (mounted) {
      if (matchResultId != null) {
        context.go('/match/$matchResultId');
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/verify',
      child: Consumer<VideoProvider>(
        builder: (_, vp, __) {
          final isRunning = vp.isProcessing && _isVerifying;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.manage_search_rounded,
                          color: AppColors.warning),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Suspected Video',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Upload a suspected video to check for unauthorized media use',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 800;
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildDropZone(context)),
                            const SizedBox(width: 24),
                            Expanded(flex: 3, child: _buildPanel(context, vp, isRunning)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildDropZone(context),
                            const SizedBox(height: 24),
                            _buildPanel(context, vp, isRunning),
                          ],
                        );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return GestureDetector(
      onTap: _pickedFile == null ? _pickFile : null,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: _pickedFile != null
              ? AppColors.warning.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pickedFile != null ? AppColors.warning : AppColors.border,
            width: _pickedFile != null ? 1.5 : 1,
          ),
        ),
        child: _pickedFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search_rounded,
                        color: AppColors.warning, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Select video to verify',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click to browse files',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_file_rounded,
                        color: AppColors.warning, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      _pickedFile!.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_pickedFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: const Text('Change File'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPanel(
      BuildContext context, VideoProvider vp, bool isRunning) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRunning ? 'Running Verification...' : 'Verification Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          if (!isRunning) ...[
            const _FieldLabel('Optional Title'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Suspected pirated copy',
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Sport Category'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.card,
              decoration: const InputDecoration(),
              items: AppCategories.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 20),

            // How it works
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.manage_search_rounded,
                          color: AppColors.warning, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Verification Process',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Extract frames from suspect video\n'
                    '2. Generate AI captions per frame\n'
                    '3. Compare against all protected videos\n'
                    '4. Produce similarity score & risk assessment',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.manage_search_rounded, size: 18),
                label: const Text(
                  'Start Verification',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ] else ...[
            // Progress display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _statusLabel(vp.processingStatus),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${vp.currentFrame}/${vp.totalFrames} frames',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppProgressBar(
                  progress: vp.processingProgress,
                  height: 10,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 20),
                if (vp.recentCaptions.isNotEmpty) ...[
                  Text(
                    'Recent Captions',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...vp.recentCaptions.take(3).map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(VideoProcessingStatus status) {
    switch (status) {
      case VideoProcessingStatus.uploading:
        return 'Uploading...';
      case VideoProcessingStatus.extractingFrames:
        return 'Extracting frames...';
      case VideoProcessingStatus.generatingCaptions:
        return 'Generating AI descriptions...';
      default:
        return 'Comparing with database...';
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
}
