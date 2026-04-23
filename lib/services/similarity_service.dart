import 'package:h2s/core/constants/app_constants.dart';
import 'package:h2s/models/match_result_model.dart';

class SimilarityService {
  SimilarityService._();

  /// Jaccard similarity between two texts based on word tokens.
  static double computeSimilarity(String text1, String text2) {
    final set1 = _tokenize(text1);
    final set2 = _tokenize(text2);

    if (set1.isEmpty && set2.isEmpty) return 1.0;
    if (set1.isEmpty || set2.isEmpty) return 0.0;

    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;

    return intersection / union;
  }

  static Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toSet();
  }

  /// Compare a query video's captions against a target video's captions.
  /// Returns a [MatchResultModel] with similarity score and matched scenes.
  static MatchResultModel compareVideos({
    required String resultId,
    required String queryVideoId,
    required String queryVideoTitle,
    required List<String> queryCaptions,
    required String targetVideoId,
    required String targetVideoTitle,
    required List<String> targetCaptions,
  }) {
    if (queryCaptions.isEmpty || targetCaptions.isEmpty) {
      return MatchResultModel(
        id: resultId,
        queryVideoId: queryVideoId,
        queryVideoTitle: queryVideoTitle,
        matchedVideoId: targetVideoId,
        matchedVideoTitle: targetVideoTitle,
        similarityScore: 0.0,
        riskLevel: RiskLevel.low,
        matchedScenes: [],
        createdAt: DateTime.now(),
      );
    }

    double totalScore = 0;
    final matchedScenes = <MatchedScene>[];

    for (int i = 0; i < queryCaptions.length; i++) {
      double bestScore = 0;
      int bestJ = 0;

      for (int j = 0; j < targetCaptions.length; j++) {
        final score = computeSimilarity(queryCaptions[i], targetCaptions[j]);
        if (score > bestScore) {
          bestScore = score;
          bestJ = j;
        }
      }

      totalScore += bestScore;

      if (bestScore > 0.3) {
        matchedScenes.add(MatchedScene(
          queryTimestamp: i,
          targetTimestamp: bestJ,
          similarity: bestScore,
          queryCaption: queryCaptions[i],
          targetCaption: targetCaptions[bestJ],
        ));
      }
    }

    final avgScore = totalScore / queryCaptions.length;
    final riskLevel = RiskLevel.fromScore(avgScore);

    return MatchResultModel(
      id: resultId,
      queryVideoId: queryVideoId,
      queryVideoTitle: queryVideoTitle,
      matchedVideoId: targetVideoId,
      matchedVideoTitle: targetVideoTitle,
      similarityScore: avgScore,
      riskLevel: riskLevel,
      matchedScenes: matchedScenes,
      createdAt: DateTime.now(),
    );
  }

  /// Find the best matching video across multiple targets.
  /// Returns the match result with the highest similarity score.
  static MatchResultModel? findBestMatch({
    required String resultId,
    required String queryVideoId,
    required String queryVideoTitle,
    required List<String> queryCaptions,
    required List<Map<String, dynamic>> targetVideos,
    // targetVideos: [{'id', 'title', 'captions': List<String>}]
  }) {
    if (targetVideos.isEmpty) return null;

    MatchResultModel? best;

    for (final target in targetVideos) {
      final result = compareVideos(
        resultId: resultId,
        queryVideoId: queryVideoId,
        queryVideoTitle: queryVideoTitle,
        queryCaptions: queryCaptions,
        targetVideoId: target['id'] as String,
        targetVideoTitle: target['title'] as String,
        targetCaptions: (target['captions'] as List<dynamic>).cast<String>(),
      );

      if (best == null || result.similarityScore > best.similarityScore) {
        best = result;
      }
    }

    return best;
  }
}
