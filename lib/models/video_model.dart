class VideoModel {
  final String id;
  final String userId;
  final String title;
  final String category;
  final List<String> tags;
  final String? fileUrl;
  final String status; // 'processing' | 'ready' | 'flagged'
  final DateTime uploadedAt;
  final int frameCount;
  final String? fileName;
  final int? fileSizeBytes;

  const VideoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.tags = const [],
    this.fileUrl,
    required this.status,
    required this.uploadedAt,
    this.frameCount = 0,
    this.fileName,
    this.fileSizeBytes,
  });

  bool get isProcessing => status == 'processing';
  bool get isReady => status == 'ready';
  bool get isFlagged => status == 'flagged';

  String get statusLabel {
    switch (status) {
      case 'flagged':
        return 'Flagged';
      case 'processing':
        return 'Processing';
      default:
        return 'Protected';
    }
  }

  String get fileSizeLabel {
    if (fileSizeBytes == null) return 'Unknown';
    final mb = fileSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  VideoModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    List<String>? tags,
    String? fileUrl,
    String? status,
    DateTime? uploadedAt,
    int? frameCount,
    String? fileName,
    int? fileSizeBytes,
  }) {
    return VideoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      frameCount: frameCount ?? this.frameCount,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'category': category,
        'tags': tags,
        'file_url': fileUrl,
        'status': status,
        'uploaded_at': uploadedAt.toIso8601String(),
        'frame_count': frameCount,
        'file_name': fileName,
        'file_size_bytes': fileSizeBytes,
      };

  factory VideoModel.fromMap(Map<String, dynamic> map) => VideoModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        fileUrl: map['file_url'] as String?,
        status: map['status'] as String? ?? 'processing',
        uploadedAt: DateTime.parse(map['uploaded_at'] as String),
        frameCount: map['frame_count'] as int? ?? 0,
        fileName: map['file_name'] as String?,
        fileSizeBytes: map['file_size_bytes'] as int?,
      );
}
