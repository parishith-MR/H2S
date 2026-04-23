import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:h2s/models/frame_model.dart';
import 'package:h2s/models/match_result_model.dart';
import 'package:h2s/models/video_model.dart';
import 'package:h2s/services/frame_extractor_service.dart';
import 'package:h2s/services/mock_data_service.dart';
import 'package:h2s/services/similarity_service.dart';

enum VideoProcessingStatus {
  idle,
  uploading,
  extractingFrames,
  generatingCaptions,
  complete,
  error,
}

class VideoProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  final FrameExtractorService _extractor = FrameExtractorService();
  final _uuid = const Uuid();

  VideoProcessingStatus _processingStatus = VideoProcessingStatus.idle;
  double _processingProgress = 0.0;
  int _currentFrame = 0;
  int _totalFrames = 0;
  String? _currentVideoId;
  String? _lastMatchResultId;
  String? _error;
  final List<FrameModel> _processedFrames = [];
  List<String> _recentCaptions = [];

  VideoProcessingStatus get processingStatus => _processingStatus;
  double get processingProgress => _processingProgress;
  int get currentFrame => _currentFrame;
  int get totalFrames => _totalFrames;
  String? get currentVideoId => _currentVideoId;
  String? get lastMatchResultId => _lastMatchResultId;
  String? get error => _error;
  List<FrameModel> get processedFrames => List.unmodifiable(_processedFrames);
  List<String> get recentCaptions => _recentCaptions;
  bool get isProcessing => _processingStatus != VideoProcessingStatus.idle &&
      _processingStatus != VideoProcessingStatus.complete &&
      _processingStatus != VideoProcessingStatus.error;

  List<VideoModel> get allVideos => _dataService.allVideos;
  List<VideoModel> get readyVideos =>
      _dataService.allVideos.where((v) => v.isReady).toList();

  // ─── Upload & Process ───

  Future<String?> uploadAndProcess({
    required String userId,
    required String title,
    required String category,
    required List<String> tags,
    required int fileSizeBytes,
    String? fileName,
  }) async {
    _error = null;
    _processedFrames.clear();
    _recentCaptions = [];

    final videoId = _uuid.v4();
    _currentVideoId = videoId;

    final durationSec = FrameExtractorService.estimateDurationSeconds(fileSizeBytes);
    _totalFrames = durationSec;
    _currentFrame = 0;
    _processingProgress = 0.0;

    // Step 1: Create video record with 'processing' status
    _processingStatus = VideoProcessingStatus.uploading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final video = VideoModel(
      id: videoId,
      userId: userId,
      title: title,
      category: category,
      tags: tags,
      status: 'processing',
      uploadedAt: DateTime.now(),
      frameCount: durationSec,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
    );
    _dataService.addVideo(video);

    // Step 2: Extract frames
    _processingStatus = VideoProcessingStatus.extractingFrames;
    notifyListeners();

    await for (final frame in _extractor.extractFrames(
      durationSeconds: durationSec,
      category: category,
      videoId: videoId,
    )) {
      _currentFrame++;
      _processingProgress = _currentFrame / _totalFrames;

      final frameModel = frame.toFrameModel(
        id: _uuid.v4(),
        videoId: videoId,
      );
      _processedFrames.add(frameModel);
      _dataService.addFrame(frameModel);

      _recentCaptions = _processedFrames
          .map((f) => f.caption)
          .toList()
          .reversed
          .take(5)
          .toList();

      _processingStatus = VideoProcessingStatus.generatingCaptions;
      notifyListeners();
    }

    // Step 3: Mark as ready
    _dataService.updateVideo(video.copyWith(
      status: 'ready',
      frameCount: _processedFrames.length,
    ));
    _processingStatus = VideoProcessingStatus.complete;
    _processingProgress = 1.0;
    notifyListeners();

    return videoId;
  }

  // ─── Verify ───

  Future<String?> verifyVideo({
    required String userId,
    required String title,
    required String category,
    required int fileSizeBytes,
    String? fileName,
  }) async {
    _error = null;
    _processedFrames.clear();
    _recentCaptions = [];

    final queryVideoId = _uuid.v4();
    _currentVideoId = queryVideoId;

    final durationSec = FrameExtractorService.estimateDurationSeconds(fileSizeBytes);
    _totalFrames = durationSec;
    _currentFrame = 0;
    _processingProgress = 0.0;

    // Create query video record
    _processingStatus = VideoProcessingStatus.uploading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    final queryVideo = VideoModel(
      id: queryVideoId,
      userId: userId,
      title: title,
      category: category,
      tags: const [],
      status: 'processing',
      uploadedAt: DateTime.now(),
      frameCount: durationSec,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
    );
    _dataService.addVideo(queryVideo);

    // Extract frames from query video
    _processingStatus = VideoProcessingStatus.extractingFrames;
    notifyListeners();

    await for (final frame in _extractor.extractFrames(
      durationSeconds: durationSec,
      category: category,
      videoId: queryVideoId,
    )) {
      _currentFrame++;
      _processingProgress = _currentFrame / _totalFrames * 0.7;

      final frameModel = frame.toFrameModel(
        id: _uuid.v4(),
        videoId: queryVideoId,
      );
      _processedFrames.add(frameModel);
      _dataService.addFrame(frameModel);
      _recentCaptions = _processedFrames
          .map((f) => f.caption)
          .toList()
          .reversed
          .take(5)
          .toList();
      _processingStatus = VideoProcessingStatus.generatingCaptions;
      notifyListeners();
    }

    // Run similarity against all ready videos
    final queryCaptions = _processedFrames.map((f) => f.caption).toList();
    final readyVids = _dataService.allVideos
        .where((v) => v.isReady && v.id != queryVideoId)
        .toList();

    final targets = readyVids.map((v) => {
          'id': v.id,
          'title': v.title,
          'captions': _dataService.getCaptionsForVideo(v.id),
        }).toList();

    _processingProgress = 0.85;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    MatchResultModel? bestMatch;
    if (targets.isNotEmpty) {
      bestMatch = SimilarityService.findBestMatch(
        resultId: _uuid.v4(),
        queryVideoId: queryVideoId,
        queryVideoTitle: title,
        queryCaptions: queryCaptions,
        targetVideos: targets,
      );
    }

    if (bestMatch != null) {
      _dataService.addMatchResult(bestMatch);
      _lastMatchResultId = bestMatch.id;
    }

    // Update video status
    final finalStatus = (bestMatch?.isHighRisk ?? false) ? 'flagged' : 'ready';
    _dataService.updateVideo(queryVideo.copyWith(
      status: finalStatus,
      frameCount: _processedFrames.length,
    ));

    _processingStatus = VideoProcessingStatus.complete;
    _processingProgress = 1.0;
    notifyListeners();

    return bestMatch?.id;
  }

  void resetProcessing() {
    _processingStatus = VideoProcessingStatus.idle;
    _processingProgress = 0.0;
    _currentFrame = 0;
    _totalFrames = 0;
    _currentVideoId = null;
    _processedFrames.clear();
    _recentCaptions = [];
    _error = null;
    notifyListeners();
  }

  VideoModel? getVideoById(String id) => _dataService.getVideoById(id);
  MatchResultModel? getMatchResultById(String id) =>
      _dataService.getMatchResultById(id);
}
