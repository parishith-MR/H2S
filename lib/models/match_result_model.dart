class MatchedScene {
  final int queryTimestamp;
  final int targetTimestamp;
  final double similarity;
  final String queryCaption;
  final String targetCaption;

  const MatchedScene({
    required this.queryTimestamp,
    required this.targetTimestamp,
    required this.similarity,
    required this.queryCaption,
    required this.targetCaption,
  });

  String get queryTimeLabel {
    final m = (queryTimestamp ~/ 60).toString().padLeft(2, '0');
    final s = (queryTimestamp % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get targetTimeLabel {
    final m = (targetTimestamp ~/ 60).toString().padLeft(2, '0');
    final s = (targetTimestamp % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> toMap() => {
        'query_timestamp': queryTimestamp,
        'target_timestamp': targetTimestamp,
        'similarity': similarity,
        'query_caption': queryCaption,
        'target_caption': targetCaption,
      };

  factory MatchedScene.fromMap(Map<String, dynamic> map) => MatchedScene(
        queryTimestamp: map['query_timestamp'] as int,
        targetTimestamp: map['target_timestamp'] as int,
        similarity: (map['similarity'] as num).toDouble(),
        queryCaption: map['query_caption'] as String,
        targetCaption: map['target_caption'] as String,
      );
}

class MatchResultModel {
  final String id;
  final String queryVideoId;
  final String queryVideoTitle;
  final String matchedVideoId;
  final String matchedVideoTitle;
  final double similarityScore;
  final String riskLevel; // 'Low' | 'Medium' | 'High'
  final List<MatchedScene> matchedScenes;
  final DateTime createdAt;

  const MatchResultModel({
    required this.id,
    required this.queryVideoId,
    required this.queryVideoTitle,
    required this.matchedVideoId,
    required this.matchedVideoTitle,
    required this.similarityScore,
    required this.riskLevel,
    required this.matchedScenes,
    required this.createdAt,
  });

  int get similarityPercent => (similarityScore * 100).round();

  bool get isHighRisk => riskLevel == 'High';
  bool get isMediumRisk => riskLevel == 'Medium';
  bool get isLowRisk => riskLevel == 'Low';

  Map<String, dynamic> toMap() => {
        'id': id,
        'query_video_id': queryVideoId,
        'query_video_title': queryVideoTitle,
        'matched_video_id': matchedVideoId,
        'matched_video_title': matchedVideoTitle,
        'similarity_score': similarityScore,
        'risk_level': riskLevel,
        'matched_scenes': matchedScenes.map((s) => s.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  factory MatchResultModel.fromMap(Map<String, dynamic> map) => MatchResultModel(
        id: map['id'] as String,
        queryVideoId: map['query_video_id'] as String,
        queryVideoTitle: map['query_video_title'] as String,
        matchedVideoId: map['matched_video_id'] as String,
        matchedVideoTitle: map['matched_video_title'] as String,
        similarityScore: (map['similarity_score'] as num).toDouble(),
        riskLevel: map['risk_level'] as String,
        matchedScenes: (map['matched_scenes'] as List<dynamic>)
            .map((s) => MatchedScene.fromMap(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
