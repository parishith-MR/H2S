class FrameModel {
  final String id;
  final String videoId;
  final int timestampSeconds;
  final String caption;
  final String? frameUrl;
  final DateTime createdAt;

  const FrameModel({
    required this.id,
    required this.videoId,
    required this.timestampSeconds,
    required this.caption,
    this.frameUrl,
    required this.createdAt,
  });

  String get timeLabel {
    final m = (timestampSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (timestampSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  FrameModel copyWith({
    String? id,
    String? videoId,
    int? timestampSeconds,
    String? caption,
    String? frameUrl,
    DateTime? createdAt,
  }) {
    return FrameModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      caption: caption ?? this.caption,
      frameUrl: frameUrl ?? this.frameUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'video_id': videoId,
        'timestamp_seconds': timestampSeconds,
        'caption': caption,
        'frame_url': frameUrl,
        'created_at': createdAt.toIso8601String(),
      };

  factory FrameModel.fromMap(Map<String, dynamic> map) => FrameModel(
        id: map['id'] as String,
        videoId: map['video_id'] as String,
        timestampSeconds: map['timestamp_seconds'] as int,
        caption: map['caption'] as String,
        frameUrl: map['frame_url'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
