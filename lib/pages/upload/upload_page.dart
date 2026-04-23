import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/providers/auth_provider.dart';
import 'package:h2s/providers/video_provider.dart';
import 'package:h2s/widgets/common/nav_sidebar.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = AppCategories.all.first;
  PlatformFile? _pickedFile;
  bool _isUploading = false;
  bool _isDragOver = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
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

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file first.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final auth = context.read<AuthProvider>();
    final videoProvider = context.read<VideoProvider>();

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final videoId = await videoProvider.uploadAndProcess(
      userId: auth.user!.id,
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      tags: tags,
      fileSizeBytes: _pickedFile!.size,
      fileName: _pickedFile!.name,
    );

    if (mounted) {
      context.go('/processing/$videoId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/upload',
      child: SingleChildScrollView(
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Official Video',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Register your sports content for AI protection',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            LayoutBuilder(builder: (context, constraints) {
              final wideLayout = constraints.maxWidth > 800;
              final formWidget = _buildForm(context);
              final dropWidget = _buildDropZone(context);

              return wideLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: formWidget),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: dropWidget),
                      ],
                    )
                  : Column(children: [dropWidget, const SizedBox(height: 24), formWidget]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isDragOver = true),
      onExit: (_) => setState(() => _isDragOver = false),
      child: GestureDetector(
        onTap: _pickedFile == null ? _pickFile : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _pickedFile == null ? 280 : null,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDragOver
                ? AppColors.primary.withOpacity(0.07)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragOver
                  ? AppColors.primary
                  : (_pickedFile != null
                      ? AppColors.success
                      : AppColors.border),
              width: _isDragOver ? 2 : 1,
              style: _pickedFile == null
                  ? BorderStyle.solid
                  : BorderStyle.solid,
            ),
          ),
          child: _pickedFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primary, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drop your video here',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'or click to browse',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const _InfoPill('MP4, MOV, AVI, MKV'),
                    const SizedBox(height: 6),
                    const _InfoPill('Max recommended: 500 MB'),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.video_file_rounded,
                              color: AppColors.success, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFile!.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _fileSizeLabel(_pickedFile!.size),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 18),
                          onPressed: () => setState(() => _pickedFile = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'Ready to process ~${_estimateDuration(_pickedFile!.size)} frames',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            _FieldLabel('Title *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. FIFA World Cup Highlights 2024',
                prefixIcon: Icon(Icons.title_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
              validator: (v) => v!.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            _FieldLabel('Sport Category *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.card,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sports_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
              items: AppCategories.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),

            _FieldLabel('Tags (comma-separated)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. World Cup, Official, 2024',
                prefixIcon: Icon(Icons.label_outline,
                    size: 18, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy_rounded,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'AI Processing Pipeline',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 1 frame extracted per second\n'
                    '• AI caption generated for each frame\n'
                    '• Captions stored as content fingerprints\n'
                    '• Used for future similarity matching',
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
                onPressed: _isUploading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Icon(Icons.rocket_launch_rounded, size: 18),
                label: Text(
                  _isUploading ? 'Starting...' : 'Upload & Process',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fileSizeLabel(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  int _estimateDuration(int bytes) {
    final mb = bytes / (1024 * 1024);
    return mb.clamp(5, 60).round();
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
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
