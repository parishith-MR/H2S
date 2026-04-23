import 'package:h2s/models/frame_model.dart';
import 'package:h2s/services/mock_ai_service.dart';

class ExtractedFrame {
  final int timestamp;
  final String caption;
  final String frameUrl;

  const ExtractedFrame({
    required this.timestamp,
    required this.caption,
    required this.frameUrl,
  });

  FrameModel toFrameModel({
    required String id,
    required String videoId,
  }) {
    return FrameModel(
      id: id,
      videoId: videoId,
      timestampSeconds: timestamp,
      caption: caption,
      frameUrl: frameUrl,
      createdAt: DateTime.now(),
    );
  }
}

/// Simulates video frame extraction at 1 frame per second.
/// In production, replace with real canvas-based extraction via dart:js_interop.
class FrameExtractorService {
  /// Extract frames from a video, yielding one per second.
  /// [durationSeconds] — how many seconds to simulate (use file size heuristic)
  /// [category] — sport category for mock caption selection
  /// [videoId] — used for frame URL generation
  Stream<ExtractedFrame> extractFrames({
    required int durationSeconds,
    required String category,
    required String videoId,
  }) async* {
    for (int i = 0; i < durationSeconds; i++) {
      // Simulate processing delay (200ms per frame in mock mode)
      await Future.delayed(const Duration(milliseconds: 200));
      yield ExtractedFrame(
        timestamp: i,
        caption: MockAIService.generateCaption(category, i),
        frameUrl: 'mock://frame_${videoId}_$i',
      );
    }
  }

  /// Estimate video duration from file size (rough approximation).
  /// Assumes ~1 MB per second for standard sports footage.
  static int estimateDurationSeconds(int fileSizeBytes) {
    final mb = fileSizeBytes / (1024 * 1024);
    // Clamp between 5 and 60 seconds for demo purposes
    return (mb.clamp(5, 60)).round();
  }

  /// Returns a fixed count if file size not available.
  static int defaultDurationSeconds = 15;
}
